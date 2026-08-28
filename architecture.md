# ShadowTrace — System Architecture (Local-First, Zero-Cloud)

This document defines the high-level architecture, component boundaries, communication protocols, and data ownership models for ShadowTrace.

---

## 1. High-Level Architecture Overview

ShadowTrace operates without any centralized backend servers or cloud databases. All databases, key material, group configurations, and telemetry are stored strictly on local device storage, exchanging real-time packets directly between paired peer devices.

```
+-------------------------------------------------------------------------+
|                              ANDROID DEVICE                             |
|                                                                         |
|  +-------------------------------------------------------------------+  |
|  |                 SHADOWTRACE CLIENT (Flutter APK)                  |  |
|  |                                                                   |  |
|  |  +------------------+  +------------------+  +-----------------+  |  |
|  |  |    UI Layer      |  |  Riverpod State  |  | Local SQLite DB |  |  |
|  |  | (Tactical / Map) |  |   Controllers    |  |  (Nicknames/Grp)|  |  |
|  |  +--------+---------+  +--------+---------+  +--------+--------+  |  |
|  |           |                     |                     |           |  |
|  |           +---------------------+---------------------+           |  |
|  |                                 |                                 |  |
|  |                     +-----------v------------+                    |  |
|  |                     |  ServiceBridge (Client)|                    |  |
|  |                     +-----------+------------+                    |  |
|  +---------------------------------|---------------------------------+  |
|                                    | Android AIDL / Binder IPC          |
|  +---------------------------------v---------------------------------+  |
|  |                 SHADOWTRACE SERVICE (Native Kotlin APK)           |  |
|  |                                                                   |  |
|  |  +----------------------+             +------------------------+  |  |
|  |  |   AIDL IPC Server    |             | Keystore Identity Mgr  |  |  |
|  |  +----------+-----------+             +-----------+------------+  |  |
|  |             |                                     |               |  |
|  |  +----------v-------------------------------------v------------+  |  |
|  |  |               Foreground Service Coordinator                |  |  |
|  |  +----------+-------------------------------------+------------+  |  |
|  |             |                                     |               |  |
|  |  +----------v-----------+             +-----------v------------+  |  |
|  |  |  FusedLocationEngine |             | Direct Peer Transmitter|  |  |
|  |  |  (GPS / Adaptive Pol)|             | (P2P / Local Sockets)  |  |  |
|  |  +----------------------+             +-----------+------------+  |  |
|  +---------------------------------------------------|---------------+  |
+------------------------------------------------------|------------------+
                                                       |
                                        Direct Peer Communication
                                                       |
                                                       v
                                            [Paired Peer Devices]
```

---

## 2. Local Database & Persistence

### 2.1 Client Local Database
* **Technology:** Local SQLite / Drift database stored in app-private sandbox storage.
* **Schema Tables:**
  * `local_groups`: `{group_id, invite_secret, created_at, role}`
  * `local_peers`: `{device_id, group_id, nickname, public_key, joined_at}`
  * `cached_peer_locations`: `{device_id, latitude, longitude, accuracy, timestamp}` (Overwritten on update; no historical tracking)

### 2.2 Service Local Storage
* **Technology:** Jetpack DataStore / Room.
* Stores active broadcast sessions, sampling preferences, and peer endpoint routing tables.

---

## 3. Client ↔ Service Communication (IPC)

* **Protocol:** Android AIDL (`IShadowTraceService.aidl`).
* **Security:** Validates caller package signature via `PackageManager.checkSignatures()` before executing commands.
* **RPC Methods:**
  * `getDeviceId()`
  * `startBroadcasting(String groupId)`
  * `stopBroadcasting()`
  * `getServiceStatus()`
  * `getLastKnownLocation()`

---

## 4. Architectural Summary

| Dimension | Specification |
|---|---|
| **Cloud Dependency** | **ZERO (No backend, no cloud database, no cloud telemetry servers)** |
| **Local Database** | Encrypted/Private Local SQLite / DataStore on each device |
| **Identity** | Hardware-backed EC NIST P-256 keypairs in Android Keystore |
| **Nicknames** | Stored 100% locally on the device; never broadcast over network |
| **Telemetry History** | Ephemeral only (latest coordinate overwrite) |
