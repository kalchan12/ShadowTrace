# ShadowTrace

> **Private, zero-cloud realtime location sharing for trusted groups.**

ShadowTrace is a 100% decentralized, privacy-first location sharing system designed specifically for trusted friend circles. ShadowTrace operates with **zero central cloud backend, zero accounts, zero cloud databases, and zero tracking servers**. All data resides strictly on the participating local devices.

---

## 1. Core Architecture Philosophy

ShadowTrace decouples user interaction from background location telemetry by separating the system into **two distinct Android applications (APKs)** running on each participant's device:

```
┌────────────────────────────────────────────────────────┐
│               ShadowTrace Client (APK 1)               │
│  - Modern Flutter UI (Cyberpunk / Tactical Theme)      │
│  - Live Map (MapLibre), Friend List & Nicknames        │
│  - Group & Pairing Management (QR Invite Scanner)      │
│  - Local Database (SQLite / Local Persistence)         │
│  - Service Control & Settings                          │
└───────────────────────────┬────────────────────────────┘
                            │
                            │ Android IPC (AIDL / Binder)
                            ▼
┌────────────────────────────────────────────────────────┐
│               ShadowTrace Service (APK 2)              │
│  - Native Kotlin Android Application                   │
│  - Persistent Android Foreground Service + Sticky Notif│
│  - Fused Location Provider (GPS/Sensors)               │
│  - Hardware-Backed Device Identity (Android Keystore)  │
│  - Local DataStore & Direct Peer Telemetry Dispatch    │
└───────────────────────────┬────────────────────────────┘
                            │
                            │ Direct Peer-to-Peer / Local Network
                            ▼
                  [Peer Group Devices]
```

### Key Architectural Tenets:
1. **Zero Cloud Backend:** There is no remote SaaS database, no Supabase server, no Firebase, and no central host. Data is stored solely on local device storage.
2. **Two Separate Applications:**
   - The **Client** owns the user experience, tactical map visualization, group keys, and local nicknames.
   - The **Service** owns Android background execution, hardware Keystore cryptographic keys, and raw GPS telemetry harvesting.
3. **Hardware Device Identity:** Identification is anchored directly to hardware-backed keys in the Android Keystore. No emails, phone numbers, or passwords.
4. **Local Ephemeral Telemetry:** Only current coordinates are kept in local storage. No movement history logs are generated.

---

## 2. Technology Stack

| Layer | Technologies |
|---|---|
| **Client** | Flutter 3.x, Dart 3.x, Riverpod (State Management), MapLibre GL, Local SQLite Storage, Material 3 Tactical Theme |
| **Service** | Kotlin 1.9+, Android SDK 34, Android Foreground Service, Google Play Services Fused Location, Android Keystore, Jetpack DataStore / Room |
| **IPC** | Android AIDL (Android Interface Definition Language) / Bound Services |
| **Backend / DB** | **NONE (100% Local Device Database & Direct Peer Exchanges)** |
| **Tooling** | Gradle, Flutter CLI, Bash development scripts |

---

## 3. Repository Structure

```
shadowtrace/
├── client/                 # Flutter UI Application
│   ├── lib/
│   │   ├── core/           # Constants, Theme, Routing, Utils, Providers
│   │   ├── models/         # Device, Friend, Group, Location models
│   │   ├── data/           # Repository interfaces, Local DB & Mock data
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
│   │       ├── network/    # Direct Peer Dispatcher
│   │       ├── storage/    # Local DataStore & Room DB
│   │       └── service/    # Foreground service lifecycle
│   └── build.gradle.kts
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

## 4. Current Development Status

> **Current Phase:** Phase 0 (Repository Foundation) & Phase 1 (Client UI Foundation)

- [x] 100% Local-First Architecture established (No cloud backend).
- [x] Client Flutter application built with tactical dark theme, Riverpod state, local repository abstractions, and core tactical screens.
- [x] Service Native Kotlin application scaffolded with AIDL IPC interface, Foreground Service lifecycle, Fused Location wrapper, and Keystore identity manager.
- [x] Repository validation suite passing with zero warnings and all unit/widget tests verified.
