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
Release Preparation & Build
```

---

## Phase Status Summary

| Phase | Description | Status | Verification & Deliverables |
|---|---|---|---|
| **Phase 0** | Repository Foundation & Architecture | **COMPLETED** | Contracts, schemas, documentation suite, validation scripts |
| **Phase 1** | Client UI & Scaffolding (Neon Protocol) | **COMPLETED** | Flutter 3 tactical HUD, MapLibre GL, Riverpod state |
| **Phase 2** | Service Foundation (Native Android / Kotlin) | **COMPLETED** | Foreground service, AIDL interface, Fused Location, Keystore |
| **Phase 3** | Client ↔ Service IPC Bridge | **COMPLETED** | AIDL binding, platform channels, Dart `ServiceBridge` |
| **Phase 4** | Local Database Foundation (SQLite / DataStore) | **COMPLETED** | `AppDatabase` SQLite, Group/Peer/Location repositories |
| **Phase 5** | Device Pairing & Direct Exchange | **COMPLETED** | Dynamic QR code generator, camera scanner, pairing payloads |
| **Phase 6** | Direct Realtime Location Telemetry | **COMPLETED** | UDP datagram dispatcher/receiver, P2P telemetry pipeline |
| **Phase 7** | Security Hardening & Cryptographic Signing | **COMPLETED** | Keystore ECDSA SHA256 signing, `CryptoVerifier`, anti-tamper |
| **Phase 8** | Battery & Reliability Optimization | **COMPLETED** | Adaptive GPS polling, stationary filter, power optimization |
| **Phase 9** | UI / UX Polish & Tactical Styling | **COMPLETED** | Cyberpunk theme, tactical HUD, animations, offline states |
| **Phase 10**| Release Preparation & Distribution | **READY TO BUILD** | Dual APK compilation (`client` + `service`) on target machine |

---

## Phase Breakdown & Detailed Progress

### Phase 0 — Repository Foundation & Architecture — [x] COMPLETED
* **Objective:** Establish documentation, project schemas, local database models, repository structure, formatting, and validation scripts.
* **Deliverables:**
  - `README.md`, `architecture.md`, `project.md`, `plan.md`, `security.md`, `protocol.md`, `AGENTS.md`.
  - JSON schemas in `protocol/contracts/` (`device.json`, `group.json`, `location_update.json`, `service_status.json`, `ipc_commands.json`).
  - Validation scripts in `scripts/validate.sh`.

### Phase 1 — Client UI & Scaffolding (Neon Protocol) — [x] COMPLETED
* **Objective:** Build complete Flutter UI with tactical styling, navigation, Riverpod state, and local repository abstractions.
* **Deliverables:**
  - Tactical Cyberpunk HUD theme (`AppColors`, `AppTypography`, `AppTheme`).
  - Welcome, Onboarding, Live Map, Squad / Peer list, Group details, and Settings screens.
  - MapLibre GL interactive map integration and tactical radar/marker widgets.

### Phase 2 — Service Foundation (Native Android / Kotlin) — [x] COMPLETED
* **Objective:** Build the native Kotlin Android service application skeleton with Keystore identity, Fused Location, and Foreground Service lifecycle.
* **Deliverables:**
  - Multi-project Gradle setup targeting Android SDK 34 with AIDL support.
  - `IShadowTraceService.aidl` interface contract.
  - `KeystoreManager.kt` hardware-backed EC NIST P-256 key generation.
  - `ForegroundLocationService.kt` with persistent sticky HUD notification.

### Phase 3 — Client ↔ Service IPC Bridge — [x] COMPLETED
* **Objective:** Establish secure communication between Client APK and Service APK via AIDL and Android Binder.
* **Deliverables:**
  - `MainActivity.kt` AIDL ServiceConnection and Flutter `MethodChannel` bridge.
  - Dart `ServiceBridge` class exposing start/stop tracking, status queries, and config updates.

### Phase 4 — Local Database Foundation (SQLite / DataStore) — [x] COMPLETED
* **Objective:** Implement local SQLite tables on Client (`local_groups`, `local_peers`, `cached_peer_locations`) and DataStore preferences on Service.
* **Deliverables:**
  - Client-side SQLite helper `AppDatabase.dart` with schema migrations.
  - `SqliteGroupRepository`, `SqliteFriendRepository`, `SqliteLocationRepository`.
  - Service-side `ServicePreferences.kt` via Jetpack DataStore.

### Phase 5 — Device Pairing & Direct Exchange — [x] COMPLETED
* **Objective:** Peer-to-peer QR pairing and direct device key exchange.
* **Deliverables:**
  - `PairingPayload.dart` supporting `GroupInvitePayload` and `PeerPairingPayload`.
  - `TacticalQrWidget.dart` with HUD styling and clipboard export.
  - `QrScannerScreen.dart` with camera barcode scanner, tactical laser HUD animation, torch toggle, and manual input.
  - Integration into group creation and joining workflows.

### Phase 6 — Direct Realtime Location Telemetry — [x] COMPLETED
* **Objective:** Direct low-latency telemetry transmission between devices (Local Subnet UDP datagrams / P2P sockets).
* **Deliverables:**
  - Kotlin `DirectPeerDispatcher.kt` for subnet broadcast dispatch (UDP 48550).
  - Kotlin `DirectPeerReceiver.kt` background datagram listener.
  - Dart `P2pTelemetryService.dart` for local packet listening, parsing, and dispatching.
  - Direct ingestion into `SqliteLocationRepository` and live Riverpod map state.

### Phase 7 — Security Hardening & Cryptographic Signing — [x] COMPLETED
* **Objective:** Enforce Keystore payload signing and tamper protection.
* **Deliverables:**
  - ECDSA SHA256 canonical payload signing in `KeystoreManager.kt`.
  - Digital signature verification in `CryptoVerifier.dart` (clock skew protection, coordinate bounds verification).
  - Rejection of tampered, expired, or out-of-bounds telemetry packets.

### Phase 8 — Battery & Reliability Optimization — [x] COMPLETED
* **Objective:** Adaptive location polling and stationary power reduction.
* **Deliverables:**
  - `FusedLocationEngine.kt` adaptive intervals (30s / 20m stationary vs 5s / 5m active movement).
  - `LocationFilter.kt` stationary activity and jitter elimination.
  - Unit tests in `LocationFilterTest.kt`.

### Phase 9 — UI / UX Polish & Tactical Styling — [x] COMPLETED
* **Objective:** Polish animations, offline states, and telemetry cards.
* **Deliverables:**
  - Cyberpunk tactical styling across all components.
  - Glassmorphic panels, corner accents, signal indicators, and telemetry badges.

### Phase 10 — Release Preparation & Compilation Guide — [ ] IN PROGRESS / READY TO COMPILE
* **Objective:** Compile, test, and package both APKs on target environment.
* **Compilation Instructions for Target Machine:**
  1. **Prerequisites:**
     - Flutter SDK 3.19+ / Dart SDK 3.3+
     - Android SDK 34 / Build Tools 34.0.0
     - Java JDK 17
  2. **Build Client APK:**
     ```bash
     cd client
     flutter pub get
     flutter analyze
     flutter test
     flutter build apk --release
     ```
  3. **Build Service APK:**
     ```bash
     cd service
     ./gradlew test
     ./gradlew assembleRelease
     ```
  4. **Run Full Verification:**
     ```bash
     ./scripts/validate.sh
     ```

