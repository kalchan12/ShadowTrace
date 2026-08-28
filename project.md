# ShadowTrace — Product & Technical Specifications (Local Database Architecture)

---

## 1. Project Vision & Goals

ShadowTrace is designed to provide real-time location visibility among tightly-knit, trusted circles **without any cloud servers, central database instances, user accounts, or cloud history tracking**.

### Goals
* Deliver low-latency peer location updates directly across participating local devices.
* Eliminate traditional account creation and cloud database infrastructure.
* Maintain 100% on-device local database storage for groups, contacts, and latest coordinates.
* Provide high-precision tactical dark-themed interface with clear user broadcast controls.

### Non-Goals
* Central cloud servers or hosted SaaS backends.
* Historical location logs or movement tracking databases.
* Public discovery, social feeds, or global user registries.

---

## 2. Requirements Index

### 2.1 Functional Requirements (FR)
* **`FR-001` (Two-App Architecture):** System consists of a user-facing Client APK and background Service APK.
* **`FR-002` (Hardware Device Identity):** Device identity derived deterministically from Android Keystore asymmetric keypairs.
* **`FR-003` (Local Group Storage):** Group memberships and invite secrets stored purely inside the local on-device database.
* **`FR-004` (QR Pairing):** High-entropy invite QR codes scanned directly device-to-device.
* **`FR-005` (Local Nicknames):** Custom peer nicknames stored strictly on the local client device.
* **`FR-006` (Live Map Visualization):** Tactical map rendering current local position and active peer coordinates.
* **`FR-007` (Peer Status Indication):** Online (<30s), Stale (30s–5m), and Offline (>5m) status indicators.
* **`FR-008` (Foreground Service Control):** Foreground Service with persistent notification and kill switch.

### 2.2 Security & Privacy Requirements (SEC & PRIV)
* **`SEC-001` (Zero Cloud Credential Store):** No cloud databases, passwords, phone numbers, or emails.
* **`SEC-002` (Keystore Key Storage):** Non-exportable EC P-256 keys inside Android Keystore TEE.
* **`SEC-003` (IPC Caller Validation):** Service AIDL validates caller UID and signature.
* **`PRIV-001` (Ephemeral State):** Local database overwrites previous coordinates; no historical trail is saved.
* **`PRIV-002` (Local Alias Secrecy):** Nicknames never leave local device storage.
