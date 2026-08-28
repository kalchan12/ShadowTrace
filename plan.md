# ShadowTrace — Implementation Plan & Phase Roadmap (Local Database Architecture)

---

## Roadmap Overview

```
Phase 0 ───► Phase 1 ───► Phase 2 ───► Phase 3 ───► Phase 4
Repo Base    Client UI    Service Base IPC Bridge  Local DB Foundation
                                                        │
                                                        ▼
Phase 9 ◄─── Phase 8 ◄─── Phase 7 ◄─── Phase 6 ◄─── Phase 5
UI Polish   Battery/Rel  Security Hrd  Direct P2P  Device Pairing
    │
    ▼
Phase 10
Release
```

---

## Phase Breakdown

### Phase 0 — Repository Foundation & Architecture
* **Objective:** Establish documentation, project schemas, local database models, repository structure, formatting, and validation scripts.
* **Exit Criteria:** Repository structure validated, no linter errors, clear documentation baseline.

### Phase 1 — Client UI & Scaffolding (Mock Mode)
* **Objective:** Build complete Flutter UI with tactical styling, navigation, Riverpod state, and mock repositories.
* **Exit Criteria:** Client APK builds, passes all widget/unit tests, runs interactive map and peer list.

### Phase 2 — Service Foundation (Native Android / Kotlin)
* **Objective:** Build the native Kotlin Android service application skeleton with Keystore identity, Fused Location, and Foreground Service lifecycle.
* **Exit Criteria:** Service APK compiles, passes unit tests, launches foreground notification.

### Phase 3 — Client ↔ Service IPC Bridge
* **Objective:** Establish secure communication between Client APK and Service APK via AIDL.
* **Exit Criteria:** Client successfully binds to Service, queries status, starts/stops location broadcast via IPC.

### Phase 4 — Local Database Foundation (SQLite / Drift / DataStore)
* **Objective:** Implement local SQLite tables on Client (`local_groups`, `local_peers`, `cached_peer_locations`) and DataStore preferences on Service.
* **Exit Criteria:** Local database stores and retrieves groups, peer keys, and aliases on-device without remote servers.

### Phase 5 — Device Pairing & Direct Exchange
* **Objective:** Peer-to-peer QR pairing and direct device key exchange.
* **Exit Criteria:** Device A generates QR invite; Device B scans and saves peer key to local database.

### Phase 6 — Direct Realtime Location Telemetry
* **Objective:** Direct low-latency telemetry transmission between devices (Local WiFi / P2P socket / mesh).
* **Exit Criteria:** Live movement on Device A updates Device B's local database and tactical map view.

### Phase 7 — Security Hardening & Cryptographic Signing
* **Objective:** Enforce Keystore payload signing and tamper protection.
* **Exit Criteria:** Unsigned or tampered location packets are rejected on receiving devices.

### Phase 8 — Battery & Reliability Optimization
* **Objective:** Adaptive location polling and stationary power reduction.
* **Exit Criteria:** < 3.5% battery drain per hour during active broadcast.

### Phase 9 — UI / UX Polish & Tactical Styling
* **Objective:** Polish animations, offline states, and telemetry cards.
* **Exit Criteria:** Smooth 60 FPS performance with tactical cyberpunk theme.

### Phase 10 — Release Preparation & Distribution
* **Objective:** Final end-to-end verification and signed release APK builds.
* **Exit Criteria:** Release APKs generated for both Client and Service.
