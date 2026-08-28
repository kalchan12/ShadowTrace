# Backend Architecture Specification

The ShadowTrace Backend is built entirely on **Supabase (PostgreSQL + Supabase Realtime + Row-Level Security)**.

---

## 1. Relational Schema Design

```
+----------------------------------------------------------------------+
|                           groups Table                               |
+------------------------------------+---------------------------------+
| Column                             | Type                            |
+------------------------------------+---------------------------------+
| id (PK)                            | UUID (gen_random_uuid())        |
| created_by_device_id               | TEXT NOT NULL                   |
| invite_secret_hash                 | TEXT NOT NULL                   |
| created_at                         | TIMESTAMPTZ DEFAULT now()       |
+------------------------------------+---------------------------------+

                                     | 1
                                     |
                                     | N
+------------------------------------+---------------------------------+
|                        memberships Table                             |
+------------------------------------+---------------------------------+
| id (PK)                            | UUID (gen_random_uuid())        |
| group_id (FK -> groups.id)         | UUID NOT NULL                   |
| device_id (FK -> devices.id)       | TEXT NOT NULL                   |
| role                               | TEXT CHECK in ('admin','member')|
| joined_at                          | TIMESTAMPTZ DEFAULT now()       |
| UNIQUE (group_id, device_id)       |                                 |
+------------------------------------+---------------------------------+

                                     | N
                                     |
                                     | 1
+------------------------------------+---------------------------------+
|                           devices Table                              |
+------------------------------------+---------------------------------+
| id (PK) (device_id)                | TEXT (SHA-256 fingerprint)      |
| public_key                         | TEXT NOT NULL                   |
| created_at                         | TIMESTAMPTZ DEFAULT now()       |
| last_seen                          | TIMESTAMPTZ DEFAULT now()       |
+------------------------------------+---------------------------------+

                                     | 1
                                     |
                                     | 1
+------------------------------------+---------------------------------+
|                      current_locations Table                         |
+------------------------------------+---------------------------------+
| device_id (PK, FK -> devices.id)   | TEXT PRIMARY KEY                |
| group_id (FK -> groups.id)         | UUID NOT NULL                   |
| latitude                           | DOUBLE PRECISION NOT NULL       |
| longitude                          | DOUBLE PRECISION NOT NULL       |
| accuracy_m                         | REAL NOT NULL                   |
| altitude_m                         | REAL                            |
| speed_mps                          | REAL                            |
| bearing_deg                        | REAL                            |
| battery_pct                        | SMALLINT                        |
| is_charging                        | BOOLEAN                         |
| updated_at                         | TIMESTAMPTZ DEFAULT now()       |
+------------------------------------+---------------------------------+
```

---

## 2. Row-Level Security (RLS) Strategy

* **Data Isolation:** Devices can only query rows from `current_locations` where `group_id` belongs to a group they are actively registered in within `memberships`.
* **Atomic Upserts:** The `current_locations` table strictly permits devices to upsert their own `device_id` record.
* **No Historical Persistence:** Updates overwrite the existing record for each `device_id`. No historical telemetry accumulates.

---

## 3. Realtime Subscription Channels

* **Channel Pattern:** `realtime:group:<group_id>`
* **Event:** `postgres_changes` on table `current_locations` filtering on `group_id=eq.<group_id>`.
* **Payload:** Emits updated coordinates instantly to all subscribed group peers.
