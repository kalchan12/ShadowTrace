# ShadowTrace — System Architecture

This document defines the high-level architecture, component boundaries, communication protocols, and data ownership models for ShadowTrace.

---

## 1. High-Level Architecture Overview

ShadowTrace splits device-side operations into two distinct applications communicating over an Android IPC boundary, synchronizing ephemerally with a backend Supabase cluster.

```
+-------------------------------------------------------------------------+
|                              ANDROID DEVICE                             |
|                                                                         |
|  +-------------------------------------------------------------------+  |
|  |                 SHADOWTRACE CLIENT (Flutter APK)                  |  |
|  |                                                                   |  |
|  |  +------------------+  +------------------+  +-----------------+  |  |
|  |  |    UI Layer      |  |  Riverpod State  |  | Local Nicknames |  |  |
|  |  | (Tactical / Map) |  |   Controllers    |  |  (Preferences)  |  |  |
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
|  |  |  FusedLocationEngine |             |   Realtime Publisher   |  |  |
|  |  |  (GPS / Adaptive Pol)|             |   (Supabase / WSS)     |  |  |
|  |  +----------------------+             +-----------+------------+  |  |
|  +---------------------------------------------------|---------------+  |
+------------------------------------------------------|------------------+
                                                       |
                                        WSS / HTTPS Ingest
                                                       |
                                                       v
+-------------------------------------------------------------------------+
|                        BACKEND (Supabase PostgreSQL)                    |
|                                                                         |
|  +--------------------+  +--------------------+  +-------------------+  |
|  |  devices Table     |  |   groups Table     |  | memberships Table |  |
|  |  (Public Keys)     |  | (Group UUID & Meta)|  | (Device in Group) |  |
|  +--------------------+  +--------------------+  +-------------------+  |
|                                                                         |
|  +-------------------------------------------------------------------+  |
|  |                     current_locations Table                       |  |
|  |        (Upsert latest location packet per device_id)              |  |
|  +----------------------------------+--------------------------------+  |
|                                     |                                   |
|                             PostgreSQL RLS                              |
|                                     |                                   |
|                     Supabase Realtime Broadcast Engine                  |
+-------------------------------------+-----------------------------------+
                                      |
                      WebSocket Subscriptions / Broadcasts
                                      |
                                      v
                         [Peer Group Member Clients]
```

---

## 2. Client Architecture (Flutter)

The Client is responsible for presentation, user interaction, group pairing, and map visualization.

### Layered Structure
* **Presentation Layer (`features/` & `widgets/`):**
  * Built using a custom Material 3 "Tactical Dark" theme with dark charcoal surfaces, controlled cyan/violet telemetry indicators, and clean typography.
  * Map visualization powered by MapLibre GL.
* **State Management (`Riverpod`):**
  * Pure reactive state providers for active groups, discovered peers, location feeds, and service connection state.
* **Domain / Data Layer (`models/` & `data/`):**
  * Repository interfaces (`LocationRepository`, `FriendRepository`, `GroupRepository`).
  * Seamless swap between mock implementations (during development/testing) and live data sources.
* **Platform Bridge (`services/service_bridge`):**
  * Android MethodChannel / EventChannel or direct AIDL bound service connection to the Service APK.

---

## 3. Service Architecture (Native Kotlin)

The Service is a dedicated, standalone Android application responsible for continuous, low-latency, and battery-efficient location harvesting.

### Core Modules
1. **`identity`:**
   * Generates a 256-bit cryptographic keypair using Android Keystore with `KeyProperties.PURPOSE_SIGN`.
   * Never exports the private key. Derives the unique `device_id` as a SHA-256 fingerprint of the public key.
2. **`location`:**
   * Encapsulates `FusedLocationProviderClient`.
   * Implements adaptive sampling policies:
     * High accuracy moving: 5–10s intervals.
     * Stationary (geofenced/accelerometer): 60s+ heartbeat.
3. **`service`:**
   * `ForegroundLocationService` running with `foregroundServiceType="location"`.
   * Maintains persistent notification with real-time status and quick kill switch.
4. **`ipc`:**
   * Implements `IShadowTraceService.aidl` providing secure RPC interfaces for the Client APK.
   * Validates calling package signature and UID.
5. **`network`:**
   * Direct WebSocket / HTTPS publisher to Supabase ingest endpoints.

---

## 4. Client ↔ Service Communication (IPC)

The two APKs communicate using Android Interface Definition Language (AIDL) over a bound Service.

### Security Boundary
* **Package Verification:** Service inspects `Binder.getCallingUid()` and matches signatures to prevent rogue apps from querying location or issuing commands.
* **Action Surface:**
  * `startBroadcasting(String groupId)`
  * `stopBroadcasting()`
  * `getServiceState()` -> `ServiceStatus`
  * `getLastKnownLocation()` -> `LocationPacket`
  * `getDeviceId()` -> `String`

---

## 5. Device Identity & Pairing

```
Group Creator                     Group Joiner
    |                                  |
    | 1. Create Group                  |
    |    (Generates Group UUID & Key)  |
    | 2. Render QR Invite              |
    |    [group_id + invite_secret]    |
    |                                  |
    |           3. Scan QR             |
    |<---------------------------------+
    |                                  |
    |                                  | 4. Submit Join Proof
    |                                  |    (Signed by Device Key)
    |                                  +--------------------------> Backend
    |                                                                 |
    | 5. Realtime Notification: "New Peer Joined"                     |
    |<----------------------------------------------------------------+
```

* **No User Accounts:** There is no username, password, or cloud profile.
* **Local Nicknames:** Peer names are strictly local device mappings stored in the client's local storage. The backend never receives personal names.

---

## 6. Realtime Location Flow & Data Minimization

1. **Sampling:** Fused Location Provider triggers `onLocationResult`.
2. **Packaging:** Location engine packages `{device_id, group_id, lat, lng, accuracy, timestamp, speed, heading}`.
3. **Ingest & Upsert:** Service publishes packet to backend `current_locations` table via upsert (`ON CONFLICT (device_id) DO UPDATE`).
4. **Broadcast:** Supabase Realtime emits update on channel `group:<group_id>`.
5. **Consumption:** Connected Clients receive location updates and render tactical markers on the live map.

---

## 7. Architectural Decisions & Constraints

| Decision | Rationale |
|---|---|
| **Two APKs vs One Monolith** | Android OS handles background foreground services far more reliably in clean Kotlin; decouples heavy UI restarts from background telemetry. |
| **No Location History** | Eliminates catastrophic data leak risks and cloud storage overhead. Only current coordinate is retained. |
| **MapLibre vs Google Maps SDK** | Complete vector tile control, custom tactical styling, offline caching capability, and zero vendor lock-in. |
| **Hardware Keystore Identity** | Prevents device identity cloning across installations. |
