# Communication & IPC Architecture

This document describes the communication boundaries between the Client, Service, and Backend.

---

## 1. IPC Boundary (Client ↔ Service)

The Client APK and Service APK run in separate Linux processes with distinct UIDs.

### 1.1 IPC Mechanism: AIDL (Android Interface Definition Language)
* Interface definition: `IShadowTraceService.aidl`.
* Action: Bound Service (`Context.bindService`) using explicit intent:
  * Component: `com.shadowtrace.service / com.shadowtrace.service.ipc.ShadowTraceAidlService`
  * Action: `com.shadowtrace.service.ACTION_BIND_IPC`

### 1.2 IPC Interface Methods
```aidl
package com.shadowtrace.service.ipc;

interface IShadowTraceService {
    String getDeviceId();
    boolean startBroadcasting(String groupId);
    boolean stopBroadcasting();
    String getServiceStatus();
    String getLastKnownLocation();
}
```

### 1.3 Caller Authentication & Authorization
Before servicing any RPC call, `ShadowTraceAidlService` validates the caller:
1. Retrieves caller UID: `val uid = Binder.getCallingUid()`.
2. Inspects caller package name using `PackageManager.getPackagesForUid(uid)`.
3. Verifies that the package signature matches the trusted ShadowTrace Client signing certificate.
4. If signature does not match, throws `SecurityException`.

---

## 2. Client ↔ Backend Communication

* **Protocol:** HTTPS (REST) for group creation, invite verification, and membership queries.
* **WebSocket (WSS):** Supabase Realtime channel subscription for live updates on `current_locations`.

---

## 3. Service ↔ Backend Communication

* **Protocol:** Direct HTTPS REST / WebSocket ingest.
* **Payload:** Atomic JSON upsert payload representing `LocationUpdate`.
* **Signing:** Packets signed with device private key via ECDSA NIST P-256.
