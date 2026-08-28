# Client Architecture Specification

The ShadowTrace Client is a Flutter application designed for real-time visualization and group interaction.

---

## 1. Directory Structure

```
client/lib/
├── core/
│   ├── constants/        # Tactical theme colors, dimensions, API constants
│   ├── errors/           # App failures, exceptions, error handlers
│   ├── routing/          # GoRouter or Navigator configuration
│   ├── theme/            # Material 3 Tactical Dark theme definition
│   └── utils/            # Coordinate formatting, timestamp helpers
│
├── models/               # Immutable domain models (Freezed / plain Dart)
│   ├── device.dart       # Device hardware identity model
│   ├── friend.dart       # Paired friend representation (with nickname)
│   ├── group.dart        # Group configuration & metadata
│   ├── location.dart     # Location coordinate & telemetry packet
│   └── service_status.dart # Android service status representation
│
├── data/
│   ├── repositories/     # Abstract repository interfaces
│   │   ├── location_repository.dart
│   │   ├── friend_repository.dart
│   │   └── group_repository.dart
│   └── mock/             # Mock repository implementations for Phase 1
│       ├── mock_location_repository.dart
│       ├── mock_friend_repository.dart
│       └── mock_group_repository.dart
│
├── features/             # Feature-based module organization
│   ├── splash/           # Initialization & service detection
│   ├── onboarding/       # Callsign / alias initial setup
│   ├── map/              # Main Tactical Live Map view & controls
│   ├── friends/          # Friend list & friend telemetry detail sheet
│   ├── group/            # Create group, join group QR scanner
│   ├── sharing/          # Broadcast switch & service control panel
│   └── settings/         # App settings & diagnostics
│
├── services/
│   └── service_bridge/   # Android IPC MethodChannel interface
│
└── widgets/              # Reusable tactical UI components
    ├── friend_marker/    # Custom tactical map marker
    ├── status_badge/     # Online/Stale/Offline indicator
    ├── tactical_card/    # Dark charcoal card with subtle border
    └── tactical_button/  # High-contrast action button
```

---

## 2. State Management Strategy (Riverpod)

* **`serviceStatusProvider`:** Watches connection and broadcast state with the Native Service.
* **`activeGroupProvider`:** Holds currently selected group and its metadata.
* **`groupMembersProvider`:** Reactive list of paired members in the active group.
* **`liveLocationsProvider`:** Stream provider yielding real-time location updates for all active group members.
* **`localNicknamesProvider`:** Persistent map linking `device_id` to user-defined aliases.

---

## 3. Map Architecture

* **Library:** `maplibre_gl` (Vector tiles).
* **Styling:** Custom dark basemap with muted landmasses and accentuated roads.
* **Friend Markers:** Smoothly interpolated coordinate updates to prevent snapping or jittering.
* **Telemetry Overlay:** Selecting a marker opens a bottom sheet showing distance, heading, accuracy circle, and last update time.
