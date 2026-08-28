# ShadowTrace — Product & Technical Specifications

---

## 1. Project Vision & Goals

ShadowTrace is designed to provide real-time location visibility among tightly-knit, trusted circles (friends, family, convoy teams) without relying on advertising networks, account registration, data brokering, or cloud history retention.

### Goals
* Deliver low-latency (<2s) peer location updates across active mobile devices.
* Eliminate traditional account creation (no emails, phone numbers, passwords, or Google SSO).
* Provide a high-precision, tactical dark-themed interface optimized for rapid situational awareness.
* Guarantee clear user control over background location collection with zero hidden tracking.
* Maximize device battery efficiency through adaptive location polling.

### Non-Goals
* Cloud-based historical trip logging, path replays, or heatmaps.
* Public discovery, social feeds, friend search, or global user registries.
* Cross-platform desktop/web client (ShadowTrace is mobile Android-first).
* Turn-by-turn navigation or routing engine.

---

## 2. Requirements Index

### 2.1 Functional Requirements (FR)

* **`FR-001` (Two-App Architecture):** System must consist of a user-facing Client APK and a background Service APK.
* **`FR-002` (Hardware Device Identity):** Device identity must be derived deterministically from an asymmetric keypair generated inside Android Keystore without requiring user registration.
* **`FR-003` (Group Creation):** Client must allow any user to create a new private group with an auto-generated high-entropy cryptographic token.
* **`FR-004` (QR Pairing):** Client must render an invite QR code containing group connection material and provide a camera-based scanner to join groups.
* **`FR-005` (Local Nicknames):** Client must allow users to assign and edit local aliases/nicknames for paired devices. Nicknames must remain strictly on-device.
* **`FR-006` (Live Map Visualization):** Client must render a vector map showing current user position and all active group peer positions with tactical visual styling.
* **`FR-007` (Peer Status Indication):** Client must visually distinguish between online (live updates <30s), stale (30s–5m), and offline (>5m) peers.
* **`FR-008` (Peer Telemetry Details):** Client must display distance, heading, accuracy radius, and last update timestamp upon selecting a peer marker.
* **`FR-009` (Foreground Service Broadcast Control):** User must be able to start, pause, and stop location broadcasting directly from the Client or via the Service notification.
* **`FR-010` (Emergency Killswitch):** The Service notification must provide an immediate single-tap action to terminate location broadcasting and purge active in-memory coordinates.

### 2.2 Non-Functional Requirements (NFR)

* **`NFR-001` (Latency):** Location updates from the Service must reflect on connected peer maps within 2000ms under standard 4G/5G/Wi-Fi conditions.
* **`NFR-002` (Battery Consumption):** Background service must consume less than 3.5% battery per hour during active moving broadcast.
* **`NFR-003` (Crash Isolation):** A crash in the Client UI must not terminate or corrupt the background Service location broadcasting loop, and vice-versa.
* **`NFR-004` (Offline Gracefulness):** Client must seamlessly queue reconnection attempts and clearly indicate connection dropouts without freezing UI rendering.
* **`NFR-005` (Startup Time):** Cold launch time of the Client UI to live map display must be under 1.2 seconds on modern mid-range Android devices.

### 2.3 Security & Privacy Requirements (SEC & PRIV)

* **`SEC-001` (No Central Credential Store):** No passwords, phone numbers, or emails stored on servers.
* **`SEC-002` (Keystore Key Storage):** Cryptographic keys used for identity and signing must be marked non-exportable within Android Keystore.
* **`SEC-003` (IPC Caller Validation):** Service AIDL interface must verify the UID and signature of the connecting Client package before fulfilling commands.
* **`SEC-004` (Row-Level Security):** Supabase database tables must enforce RLS ensuring devices can only read/write records for groups in which they hold verified membership.
* **`PRIV-001` (Ephemeral State):** Location database must only hold the current latest coordinate per device. No location history records or breadcrumbs.
* **`PRIV-002` (Local Alias Secrecy):** Custom names given to friends must never leave the local device storage.
* **`PRIV-003` (Explicit Notification):** Android Foreground Service must run with a non-dismissible notification while broadcasting, adhering to Android 14+ location foreground service requirements.

---

## 3. Core User Flows

### Flow 1: First Run & Device Setup
1. User opens ShadowTrace Client.
2. System checks if ShadowTrace Service APK is installed.
   - If not installed: Prompts user to install the Service APK.
3. System verifies location & notification permissions.
4. Client connects to Service via IPC; Service initializes Keystore device identity.
5. User enters a local display handle (or auto-generates a tactical callsign).
6. User arrives at the Main Tactical Dashboard (Live Map).

### Flow 2: Group Creation & Pairing
1. User taps "Create Group".
2. System generates a UUID group ID and high-entropy invite token.
3. Client displays a QR Code.
4. Friend opens Client, taps "Join Group", and scans the QR code.
5. Friend's device registers membership with backend using the invite token.
6. Both users see each other on their respective Live Maps in real-time.

### Flow 3: Live Tactical Location Sharing
1. User toggles "Broadcast: ACTIVE".
2. Client sends IPC command to Service.
3. Service transitions to active high-accuracy Fused Location mode and displays foreground notification.
4. Service transmits updates to Supabase; connected group members receive websocket updates.
5. When user stops broadcast, Service transitions to dormant standby mode.

---

## 4. UI / UX Design Principles

* **Cyberpunk / Tactical Aesthetic:** Dark charcoal backgrounds (`#0D1117`, `#161B22`), subtle borders (`#30363D`), cyan active accents (`#00F0FF`), violet auxiliary accents (`#8A2BE2`), warning amber (`#FFB800`), error crimson (`#FF3B30`).
* **Monospace for Data Only:** Standard clean sans-serif (Inter / Roboto) for general UI labels; Monospace (JetBrains Mono / Roboto Mono) reserved strictly for coordinates, timestamps, hashes, and distances.
* **High Contrast Map:** Dark vector basemap styling with prominent high-contrast glow rings for friend markers and accuracy envelopes.

---

## 5. Success Criteria

1. Both Client and Service APKs install and run concurrently without permission conflicts.
2. QR pairing completes in < 5 seconds between two physical devices.
3. Service maintains persistent location updates without being killed by Android Doze/battery managers for at least 8 consecutive hours.
4. Client UI runs consistently at 60+ FPS during active map panning and marker interpolation.
