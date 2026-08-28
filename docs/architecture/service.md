# Service Architecture Specification

The ShadowTrace Service is a dedicated Native Android/Kotlin application engineered for 24/7 background location harvesting, hardware key management, and resilient network transmission.

---

## 1. Package Structure

```
service/app/src/main/kotlin/com/shadowtrace/service/
├── identity/
│   ├── KeystoreManager.kt       # Hardware-backed EC P-256 key management
│   └── DeviceIdentity.kt        # Fingerprint derivation (device_id)
│
├── location/
│   ├── FusedLocationEngine.kt   # Location client wrapper & updates callback
│   ├── LocationPolicy.kt        # Adaptive rate manager (moving vs stationary)
│   └── LocationFilter.kt        # Jitter filtering & accuracy thresholds
│
├── service/
│   ├── ForegroundLocationService.kt # Foreground service lifecycle & sticky notification
│   ├── ServiceNotificationHelper.kt # Notification channel & action builders
│   └── ServiceStateHolder.kt    # In-memory broadcast state & observers
│
├── ipc/
│   ├── ShadowTraceAidlService.kt # AIDL server stub implementation
│   └── CallerValidator.kt       # Package signature & UID verification
│
├── network/
│   ├── SupabasePublisher.kt     # WebSocket / HTTPS location transmitter
│   └── NetworkMonitor.kt        # Cellular / Wi-Fi reachability listener
│
└── storage/
    └── ServicePreferences.kt    # Jetpack DataStore for local service config
```

---

## 2. Foreground Service Lifecycle

```
[Client IPC: startBroadcasting]
               │
               ▼
[Validate Permissions: ACCESS_FINE_LOCATION, POST_NOTIFICATIONS, FOREGROUND_SERVICE_LOCATION]
               │
               ▼
[Start ForegroundLocationService with startForeground(NOTIFICATION_ID, ...)]
               │
               ▼
[Request Location Updates from FusedLocationProviderClient]
               │
               ▼
[Loop: Receive Coordinate -> Filter Jitter -> Sign Packet -> Publish to Backend]
               │
               ▼
[Client IPC / Notif Action: stopBroadcasting]
               │
               ▼
[Remove Location Updates -> Transition Notification to Dormant / Stop Service]
```

---

## 3. Battery & Power Conservation Policy

* **Moving State:** Standard updates every 5–10 seconds or every 5 meters displacement.
* **Stationary State:** If device displacement is < 10 meters over 3 minutes, throttle updates to 60-second heartbeats.
* **Doze & Battery Optimization:** Request `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` during setup to ensure reliable background transmission.
