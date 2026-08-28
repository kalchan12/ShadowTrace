# ShadowTrace

> **Private, high-integrity realtime location sharing for trusted groups.**

ShadowTrace is a decentralized, privacy-first location sharing system designed specifically for trusted friend circles. Unlike conventional consumer location applications, ShadowTrace is built from the ground up without accounts, email addresses, phone numbers, advertising identifiers, or cloud user profiles.

---

## 1. Core Architecture Philosophy

ShadowTrace decouples user interaction from background location telemetry by separating the system into **two distinct Android applications (APKs)** running on each participant's device:

```
┌────────────────────────────────────────────────────────┐
│               ShadowTrace Client (APK 1)               │
│  - Modern Flutter UI (Cyberpunk / Tactical Theme)      │
│  - Live Map (MapLibre), Friend List & Nicknames        │
│  - Group & Pairing Management (QR Invite Scanner)      │
│  - Service Control & Settings                          │
└───────────────────────────┬────────────────────────────┘
                            │
                            │ Android IPC (AIDL / Binder)
                            ▼
┌────────────────────────────────────────────────────────┐
│               ShadowTrace Service (APK 2)              │
│  - Native Kotlin Android Application                   │
│  - Persistent Android Foreground Service + Sticky Notif│
│  - Fused Location Provider (GPS/Cell/Wi-Fi)            │
│  - Hardware-Backed Device Identity (Android Keystore)  │
│  - Battery-Aware Publishing to Supabase Realtime       │
└───────────────────────────┬────────────────────────────┘
                            │
                            │ Direct Location Ingest
                            ▼
┌────────────────────────────────────────────────────────┐
│                  Supabase PostgreSQL                   │
│  - Row-Level Security (RLS) policies                   │
│  - Realtime WebSocket Channel Dispatch                 │
│  - Ephemeral "Current Location" Model (No History)     │
└───────────────────────────┬────────────────────────────┘
                            │
                            │ Realtime Subscriptions
                            ▼
                  [Other Group Clients]
```

### Why Two Separate Applications?
1. **Uncompromising Background Reliability:** Flutter runtimes are optimized for rendering UI, not for zero-crash, low-overhead 24/7 background location services. A dedicated Native Kotlin foreground service guarantees Android OS lifecycle compliance, battery optimization, and crash isolation.
2. **Explicit User Control & Transparency:** The background service runs as an explicit, user-authorized foreground service with a visible persistent notification. The user always knows when telemetry is active.
3. **Clean Security Boundaries:** The Service owns hardware-backed cryptographic keys (in Android Keystore) and raw location updates. The Client owns UI state, group visualization, and presentation nicknames.

---

## 2. No-Account Identity Model

Conventional location platforms require phone numbers, Google accounts, or central user databases that can be breached, tracked, or aggregated. ShadowTrace replaces this with:

* **Hardware Device Identity:** Each installation generates a cryptographic keypair stored in the device's hardware-backed Android Keystore.
* **Ephemeral Group Tokens:** Groups are created ad-hoc with high-entropy cryptographic invite tokens.
* **Zero Registration:** Pairing occurs via peer-to-peer QR code scanning or secure invite strings.
* **Client-Side Presentation:** Human-readable names ("Alice", "Bob") are local nicknames stored solely on the client device—the backend only knows public keys and group memberships.

---

## 3. Technology Stack

| Layer | Technologies |
|---|---|
| **Client** | Flutter 3.x, Dart 3.x, Riverpod (State Management), MapLibre GL, Material 3 with Tactical Theme |
| **Service** | Kotlin 1.9+, Android SDK 34, Android Foreground Service, Google Play Services Fused Location, Android Keystore, Jetpack DataStore |
| **IPC** | Android AIDL (Android Interface Definition Language) / Bound Services |
| **Backend** | Supabase PostgreSQL, Supabase Realtime (WebSockets), Row-Level Security (RLS) |
| **Tooling** | Gradle, Flutter CLI, Bash development scripts |

---

## 4. Repository Structure

```
shadowtrace/
├── client/                 # Flutter UI Application
│   ├── lib/
│   │   ├── core/           # Constants, Theme, Routing, Utils
│   │   ├── models/         # Device, Friend, Group, Location models
│   │   ├── data/           # Repository interfaces & Mock data
│   │   ├── features/       # Onboarding, Map, Friends, Group, Sharing, Settings
│   │   ├── services/       # ServiceBridge IPC client
│   │   └── widgets/        # Tactical UI components & markers
│   └── test/               # Unit, widget, and mock tests
│
├── service/                # Native Kotlin Background Service
│   ├── app/src/main/
│   │   ├── aidl/           # IPC AIDL interfaces
│   │   └── kotlin/com/shadowtrace/service/
│   │       ├── identity/   # Keystore device identity manager
│   │       ├── location/   # FusedLocation engine & policies
│   │       ├── ipc/        # AIDL Service implementation
│   │       ├── network/    # Supabase publisher
│   │       ├── storage/    # DataStore settings
│   │       └── service/    # Foreground service lifecycle
│   └── build.gradle.kts
│
├── backend/                # Supabase configuration & migrations
│   └── supabase/migrations/# SQL schema with RLS policies
│
├── protocol/               # Data contracts & IPC JSON schemas
├── docs/                   # Exhaustive architecture & security docs
├── scripts/                # Validation & format scripts
├── README.md               # Main repository overview
├── architecture.md         # System architecture specification
├── project.md              # Functional & non-functional requirements
├── plan.md                 # 11-phase implementation roadmap
├── security.md             # Threat model & cryptographic boundaries
├── protocol.md             # Data and IPC contracts
├── CONTRIBUTING.md         # Developer guidelines & conventions
└── AGENTS.md               # Rules for AI coding agents
```

---

## 5. Current Development Status

> **Current Phase:** Phase 0 (Repository Foundation) & Phase 1 Scaffolding

- [x] Repository architecture and documentation foundation established.
- [x] Client Flutter application scaffolded with tactical dark theme, Riverpod state, mock repositories, and all core feature screens.
- [x] Service Native Kotlin application scaffolded with AIDL IPC interface, Foreground Service lifecycle structure, Fused Location wrapper, and Keystore identity manager.
- [x] Backend database schema and Row-Level Security (RLS) migration defined.
- [ ] Realtime Supabase live connection (Planned in Phase 4/6).
- [ ] End-to-end device QR pairing (Planned in Phase 5).
- [ ] Production cryptographic signature verification (Planned in Phase 7).

---

## 6. Quick Start & Development Setup

### Prerequisites
- Flutter SDK (>= 3.19.0)
- Android SDK (API 34) & JDK 17+
- Android device or emulator with Google Play Services (for Fused Location)

### Building the Client
```bash
cd client
flutter pub get
flutter test
flutter run
```

### Building the Service
```bash
cd service
./gradlew test
./gradlew assembleDebug
```

---

## 7. Security & Privacy Philosophy
- **Current Location Only:** The default data schema retains only the latest known location packet for each device in an active group. Historical traces are not logged to disk on the backend.
- **Explicit Foreground Visibility:** The service never tracks stealthily. An ongoing notification informs the user of active broadcast status.
- **Fail-Closed Security:** Unauthenticated or unauthorized group tokens cannot subscribe to realtime location streams.

See [security.md](security.md) and [architecture.md](architecture.md) for full specifications.
