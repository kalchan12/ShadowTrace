# Local Database & Storage Architecture

ShadowTrace uses **100% on-device local storage** with no cloud database instances.

---

## 1. Client Local Database (SQLite)

The Flutter Client uses an on-device SQLite database stored in the application's private sandbox directory.

### Schema:

```sql
-- Local groups table
CREATE TABLE IF NOT EXISTS local_groups (
    id TEXT PRIMARY KEY,
    invite_secret TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'member',
    created_at INTEGER NOT NULL
);

-- Local peer contacts table (with user-defined local nicknames)
CREATE TABLE IF NOT EXISTS local_peers (
    device_id TEXT NOT NULL,
    group_id TEXT NOT NULL REFERENCES local_groups(id) ON DELETE CASCADE,
    nickname TEXT NOT NULL,
    public_key TEXT NOT NULL,
    joined_at INTEGER NOT NULL,
    PRIMARY KEY (group_id, device_id)
);

-- Cached peer latest coordinates (Overwritten on update - No History)
CREATE TABLE IF NOT EXISTS cached_peer_locations (
    device_id TEXT PRIMARY KEY,
    group_id TEXT NOT NULL REFERENCES local_groups(id) ON DELETE CASCADE,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    accuracy_m REAL NOT NULL,
    speed_mps REAL,
    bearing_deg REAL,
    altitude_m REAL,
    battery_pct INTEGER,
    updated_at INTEGER NOT NULL
);
```

---

## 2. Service Local Preferences (Jetpack DataStore)

The Native Kotlin Service persists configuration using Android Jetpack DataStore:
* `last_active_group_id`: String (currently active broadcast group)
* `auto_start_on_boot`: Boolean
* `adaptive_sampling_enabled`: Boolean
