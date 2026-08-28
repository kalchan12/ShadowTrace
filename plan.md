# ShadowTrace — Implementation Plan & Phase Roadmap

This document outlines the phased roadmap for developing the complete ShadowTrace system.

---

## Roadmap Overview

```
Phase 0 ───► Phase 1 ───► Phase 2 ───► Phase 3 ───► Phase 4
Repo Base    Client UI    Service Base IPC Bridge  Backend Base
                                                        │
                                                        ▼
Phase 9 ◄─── Phase 8 ◄─── Phase 7 ◄─── Phase 6 ◄─── Phase 5
UI Polish   Battery/Rel  Security Hrd  Realtime Loc Device Pairing
    │
    ▼
Phase 10
Release
```

---

## Phase Breakdown

### Phase 0 — Repository Foundation & Architecture
* **Objective:** Establish documentation, project schemas, repository structure, formatting, and CI/validation scripts.
* **Tasks:**
  * Define root documentation (`README.md`, `architecture.md`, `project.md`, `plan.md`, `security.md`, `protocol.md`, `CONTRIBUTING.md`, `AGENTS.md`).
  * Initialize directory structure: `client/`, `service/`, `backend/`, `protocol/`, `docs/`, `scripts/`.
  * Establish protocol contracts in `protocol/`.
  * Create environment templates (`.env.example`) and comprehensive `.gitignore`.
  * Create developer validation script `scripts/validate.sh`.
* **Dependencies:** None.
* **Exit Criteria:** Repository structure validated, no linter errors, clear documentation baseline.

---

### Phase 1 — Client UI & Scaffolding (Mock Mode)
* **Objective:** Build the complete Flutter UI with tactical styling, navigation, Riverpod state, and mock repositories.
* **Tasks:**
  * Configure custom Tactical Dark theme (Material 3 with cyberpunk palette).
  * Build core data models (`Device`, `Friend`, `Group`, `LocationUpdate`, `ServiceStatus`).
  * Implement Repository interfaces and Mock implementations (`MockLocationRepository`, `MockFriendRepository`, `MockGroupRepository`).
  * Construct UI screens:
    * Splash / Initialization screen
    * Onboarding & Callsign setup
    * Tactical Live Map (MapLibre integration / Mock Canvas)
    * Friend List & Friend Detail drawer
    * Group Management & QR Invite dialogs
    * Sharing Controls & Service Status badge
    * Settings & Diagnostics
  * Write widget and unit tests for UI navigation and state providers.
* **Dependencies:** Phase 0.
* **Exit Criteria:** Client APK builds, passes all widget tests, runs in mock mode with interactive map and peer list.

---

### Phase 2 — Service Foundation (Native Android / Kotlin)
* **Objective:** Build the native Kotlin Android service application skeleton.
* **Tasks:**
  * Configure Kotlin/Android build setup with Android Gradle Plugin & target SDK 34.
  * Implement `AndroidKeystoreManager` for hardware keypair generation and `device_id` fingerprinting.
  * Implement `FusedLocationEngine` with location request configuration.
  * Implement `ForegroundLocationService` with persistent notification and quick-stop action.
  * Configure Jetpack `DataStore` for persisting local service preferences.
* **Dependencies:** Phase 0.
* **Exit Criteria:** Service APK compiles, passes unit tests, launches foreground notification on device/emulator.

---

### Phase 3 — Client ↔ Service IPC Bridge
* **Objective:** Establish secure communication between the Client APK and Service APK via AIDL.
* **Tasks:**
  * Define `IShadowTraceService.aidl` contract.
  * Implement IPC Service Binder in the Service application with package/UID signature verification.
  * Implement `ServiceBridge` on the Client using Android MethodChannel / native bridge.
  * Add automatic service discovery and status telemetry reporting.
* **Dependencies:** Phase 1, Phase 2.
* **Exit Criteria:** Client successfully binds to Service, queries status, starts/stops location broadcast via IPC.

---

### Phase 4 — Backend Foundation (Supabase PostgreSQL & RLS)
* **Objective:** Setup Supabase schema, Row-Level Security policies, and Realtime publications.
* **Tasks:**
  * Write initial migration for tables: `groups`, `devices`, `memberships`, `current_locations`.
  * Implement PostgreSQL RLS policies enforcing group-level data isolation.
  * Setup triggers for automatic `last_seen` timestamp updates.
  * Enable Realtime replication on `current_locations` and `memberships`.
* **Dependencies:** Phase 0.
* **Exit Criteria:** Migrations run cleanly on local Supabase CLI or cloud instance; RLS unit tests pass.

---

### Phase 5 — Device Pairing & Group Management
* **Objective:** Implement peer-to-peer group creation and QR code pairing workflows.
* **Tasks:**
  * Implement QR generator in Client with encrypted invite payload format.
  * Implement camera QR scanner using `mobile_scanner`.
  * Build join group validation endpoint/RPC verifying device signature.
  * Add local nickname management in Client storage.
* **Dependencies:** Phase 3, Phase 4.
* **Exit Criteria:** Device A creates group QR; Device B scans and joins group; both devices record verified membership.

---

### Phase 6 — Realtime Location Broadcast & Visualization
* **Objective:** Connect the Service directly to Supabase ingest and stream coordinates to connected Client map views.
* **Tasks:**
  * Implement Native Kotlin Supabase / WebSocket publisher in Service.
  * Implement Supabase Realtime subscription stream in Client `SupabaseLocationRepository`.
  * Bind live location stream to MapLibre friend markers with smooth coordinate interpolation.
  * Implement peer accuracy circles, heading indicators, and stale data indicators.
* **Dependencies:** Phase 4, Phase 5.
* **Exit Criteria:** Live movement on Device A updates Device B's map in < 2 seconds.

---

### Phase 7 — Security Hardening & Cryptographic Verification
* **Objective:** Enforce payload signing and tamper protection across all data exchanges.
* **Tasks:**
  * Sign all outgoing location packets using Keystore private keys.
  * Verify payload signatures at backend/client level.
  * Implement replay attack prevention (monotonic nonces + short TTL).
  * Run static analysis and security audit checklist.
* **Dependencies:** Phase 6.
* **Exit Criteria:** Tampered or unsigned location packets are rejected; Keystore keys remain non-exportable.

---

### Phase 8 — Battery & Reliability Optimization
* **Objective:** Implement adaptive location sampling and resilient background reconnect logic.
* **Tasks:**
  * Implement stationary detection (reduce GPS sampling rate when device is motionless).
  * Handle network transitions (Wi-Fi <-> Cellular) and WebSocket automatic backoff reconnects.
  * Test Doze mode survival and memory footprint profiling (< 50MB RAM for Service).
* **Dependencies:** Phase 6.
* **Exit Criteria:** Service runs for 8+ hours with < 3.5% battery drain per hour.

---

### Phase 9 — UI / UX Polish & Tactical Design System
* **Objective:** Polish animations, offline states, haptic feedback, and accessibility.
* **Tasks:**
  * Refine tactical UI micro-animations and status transitions.
  * Add custom MapLibre tactical tile styling and offline tile cache.
  * Implement battery/signal status badges on friend cards.
  * Add diagnostics drawer for inspection of IPC and connection latency.
* **Dependencies:** Phase 6.
* **Exit Criteria:** UI renders at consistent 60 FPS; seamless dark mode tactical aesthetics.

---

### Phase 10 — Release Preparation & Distribution
* **Objective:** Final end-to-end verification, signed release APK builds, and documentation review.
* **Tasks:**
  * Prepare production release keystores and signing configurations.
  * Run automated build and validation scripts.
  * Finalize user guides and deployment documentation.
* **Dependencies:** All previous phases.
* **Exit Criteria:** Release APKs generated for both Client and Service; full system test passing.
