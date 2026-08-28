# ShadowTrace Backend Foundation

The backend provides real-time location synchronization, device registry, and group membership authorization powered by Supabase and PostgreSQL.

---

## Structure
```
backend/
├── supabase/
│   ├── config.toml           # Supabase local development configuration
│   └── migrations/
│       └── 20260101000000_initial_schema.sql # Initial schema + RLS policies
└── README.md
```

---

## Applying Migrations
With the Supabase CLI installed:
```bash
cd backend
supabase db reset
```
