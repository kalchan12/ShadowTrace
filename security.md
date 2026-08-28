# ShadowTrace — Security & Privacy Model (Zero-Cloud, Local-First)

---

## 1. Core Security Philosophy

ShadowTrace operates without any centralized cloud database or hosted servers. All security relies on:
1. **Hardware-Backed Device Identity:** Android Keystore non-exportable EC NIST P-256 keys.
2. **Local Sandbox Encryption & Isolation:** Data stored strictly inside local app-private SQLite databases and DataStore.
3. **OS-Level IPC Verification:** AIDL caller UID and package signature validation.
4. **Peer Cryptographic Verification:** Packets signed with device private keys.

---

## 2. Threat Model & Assets

### 2.1 Protected Assets
* **Local Location Coordinates:** Ephemeral current coordinates on-device (no historical log).
* **Local Groups & Peers:** Saved peer public keys and local nicknames in local SQLite.
* **Device Private Keys:** Keymaster/StrongBox TEE non-exportable private key.

### 2.2 Attack Vectors & Mitigations
* **Unauthorized IPC:** Service AIDL validates caller certificate signature against trusted Client package.
* **Data Harvest on Device:** SQLite database stored in protected Android app sandbox (`/data/data/com.shadowtrace.client/databases`).
* **Packet Tampering:** Telemetry packets signed with sender's hardware private key; verified against known public key stored in receiver's local database.
