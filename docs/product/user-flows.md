# Product User Flows

---

## 1. Flow Diagram: Full Lifecycle

```
[Start App] ──► [Verify Service Installed] ──► [Device Identity Ready]
                        │                              │
                        ▼                              ▼
                 [Prompt Install]               [Main Tactical Map]
                                                       │
                                   ┌───────────────────┴───────────────────┐
                                   ▼                                       ▼
                           [Create Group]                            [Join Group]
                                   │                                       │
                                   ▼                                       ▼
                           [Render QR Code]                          [Scan QR Code]
                                   │                                       │
                                   └───────────────────┬───────────────────┘
                                                       ▼
                                          [Members Paired in Group]
                                                       │
                                                       ▼
                                         [Toggle Live Broadcast]
                                                       │
                                                       ▼
                                        [Realtime Peer Telemetry Map]
```

---

## 2. Step-by-Step Experience

### 2.1 First-Time Setup
1. User opens Client.
2. If Service is not running/installed, a tactical status banner guides the user.
3. User selects a local tactical callsign (e.g. "GHOST-1").

### 2.2 Peer Pairing
1. Initiator taps "Create Group".
2. System generates group ID and high-entropy invite secret; displays QR.
3. Peer taps "Join Group", scans QR via camera.
4. Both devices confirm connection in real time.

### 2.3 Live Map Navigation
1. Interactive vector map centers on user's location with accuracy halo.
2. Friend markers display custom tactical rings and heading needles.
3. Tapping a friend marker reveals telemetry card: distance, speed, accuracy, and last seen.
