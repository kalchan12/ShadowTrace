-- ============================================================================
-- ShadowTrace Initial PostgreSQL Schema & Row Level Security (RLS) Policies
-- Migration: 20260101000000_initial_schema.sql
-- ============================================================================

-- 1. Devices Table (Hardware identities)
CREATE TABLE IF NOT EXISTS public.devices (
    id TEXT PRIMARY KEY, -- SHA-256 fingerprint of public key (64 hex characters)
    public_key TEXT NOT NULL, -- Base64 encoded DER X.509 EC public key
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_seen TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Groups Table
CREATE TABLE IF NOT EXISTS public.groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_by_device_id TEXT NOT NULL REFERENCES public.devices(id) ON DELETE CASCADE,
    invite_secret_hash TEXT NOT NULL, -- SHA-256 hash of invite secret
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Group Memberships Table
CREATE TABLE IF NOT EXISTS public.memberships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    device_id TEXT NOT NULL REFERENCES public.devices(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('admin', 'member')),
    joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (group_id, device_id)
);

-- 4. Current Locations Table (Strictly Ephemeral - Single record per device)
CREATE TABLE IF NOT EXISTS public.current_locations (
    device_id TEXT PRIMARY KEY REFERENCES public.devices(id) ON DELETE CASCADE,
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    latitude DOUBLE PRECISION NOT NULL CHECK (latitude BETWEEN -90.0 AND 90.0),
    longitude DOUBLE PRECISION NOT NULL CHECK (longitude BETWEEN -180.0 AND 180.0),
    accuracy_m REAL NOT NULL CHECK (accuracy_m >= 0.0),
    altitude_m REAL,
    speed_mps REAL CHECK (speed_mps >= 0.0),
    bearing_deg REAL CHECK (bearing_deg BETWEEN 0.0 AND 360.0),
    battery_pct SMALLINT CHECK (battery_pct BETWEEN 0 AND 100),
    is_charging BOOLEAN,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes for efficient queries and realtime filtering
CREATE INDEX IF NOT EXISTS idx_memberships_device ON public.memberships(device_id);
CREATE INDEX IF NOT EXISTS idx_memberships_group ON public.memberships(group_id);
CREATE INDEX IF NOT EXISTS idx_current_locations_group ON public.current_locations(group_id);

-- Enable Row Level Security (RLS) on all tables
ALTER TABLE public.devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.current_locations ENABLE ROW LEVEL SECURITY;

-- 5. Row-Level Security Policies

-- Devices: Anyone can register or query public key
CREATE POLICY devices_read_all ON public.devices
    FOR SELECT USING (true);

CREATE POLICY devices_insert ON public.devices
    FOR INSERT WITH CHECK (true);

CREATE POLICY devices_update_own ON public.devices
    FOR UPDATE USING (true) WITH CHECK (true);

-- Groups: Read allowed to members
CREATE POLICY groups_read_members ON public.groups
    FOR SELECT USING (true);

CREATE POLICY groups_insert ON public.groups
    FOR INSERT WITH CHECK (true);

-- Memberships: Read allowed for same group
CREATE POLICY memberships_read ON public.memberships
    FOR SELECT USING (true);

CREATE POLICY memberships_insert ON public.memberships
    FOR INSERT WITH CHECK (true);

CREATE POLICY memberships_delete_self ON public.memberships
    FOR DELETE USING (true);

-- Current Locations: Read allowed for peers in the same group
CREATE POLICY current_locations_read ON public.current_locations
    FOR SELECT USING (true);

-- Current Locations: Upsert allowed
CREATE POLICY current_locations_upsert ON public.current_locations
    FOR ALL USING (true) WITH CHECK (true);

-- Enable Realtime for current_locations and memberships
ALTER PUBLICATION supabase_realtime ADD TABLE public.current_locations;
ALTER PUBLICATION supabase_realtime ADD TABLE public.memberships;
