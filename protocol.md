# ShadowTrace — Communication & Data Protocol Specification

**Protocol Version:** `v1.0.0`

This document defines the formal data contracts, JSON schemas, and IPC command specifications used across the ShadowTrace Client, Service, and Supabase Backend.

---

## 1. Core Data Entities

### 1.1 Device Entity
Represents a registered hardware identity.

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "Device",
  "type": "object",
  "required": ["device_id", "public_key", "created_at", "last_seen"],
  "properties": {
    "device_id": {
      "type": "string",
      "description": "Deterministic SHA-256 fingerprint of the Keystore public key (hex encoded)"
    },
    "public_key": {
      "type": "string",
      "description": "Base64-encoded DER X.509 EC public key"
    },
    "created_at": {
      "type": "integer",
      "description": "Unix timestamp in milliseconds"
    },
    "last_seen": {
      "type": "integer",
      "description": "Unix timestamp in milliseconds of latest telemetry packet"
    }
  }
}
```

---

### 1.2 Group Entity
Represents an isolated circle of sharing participants.

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "Group",
  "type": "object",
  "required": ["group_id", "created_by_device_id", "created_at"],
  "properties": {
    "group_id": {
      "type": "string",
      "format": "uuid",
      "description": "Cryptographically random UUID v4"
    },
    "created_by_device_id": {
      "type": "string",
      "description": "Device ID of the group creator"
    },
    "created_at": {
      "type": "integer",
      "description": "Unix timestamp in milliseconds"
    }
  }
}
```

---

### 1.3 Membership Entity
Links a device to an active group.

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "Membership",
  "type": "object",
  "required": ["group_id", "device_id", "role", "joined_at"],
  "properties": {
    "group_id": {
      "type": "string",
      "format": "uuid"
    },
    "device_id": {
      "type": "string"
    },
    "role": {
      "type": "string",
      "enum": ["admin", "member"]
    },
    "joined_at": {
      "type": "integer",
      "description": "Unix timestamp in milliseconds"
    }
  }
}
```

---

### 1.4 LocationUpdate Entity
The fundamental real-time telemetry payload published by the Service.

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "LocationUpdate",
  "type": "object",
  "required": [
    "device_id",
    "group_id",
    "latitude",
    "longitude",
    "accuracy_m",
    "timestamp"
  ],
  "properties": {
    "device_id": {
      "type": "string"
    },
    "group_id": {
      "type": "string",
      "format": "uuid"
    },
    "latitude": {
      "type": "number",
      "minimum": -90.0,
      "maximum": 90.0
    },
    "longitude": {
      "type": "number",
      "minimum": -180.0,
      "maximum": 180.0
    },
    "accuracy_m": {
      "type": "number",
      "description": "Horizontal accuracy radius in meters (68% confidence)"
    },
    "altitude_m": {
      "type": ["number", "null"],
      "description": "Altitude above WGS 84 ellipsoid in meters"
    },
    "speed_mps": {
      "type": ["number", "null"],
      "description": "Instantaneous speed in meters per second"
    },
    "bearing_deg": {
      "type": ["number", "null"],
      "minimum": 0.0,
      "maximum": 360.0,
      "description": "Direction of travel in degrees clockwise from true north"
    },
    "battery_pct": {
      "type": ["integer", "null"],
      "minimum": 0,
      "maximum": 100,
      "description": "Device battery percentage"
    },
    "is_charging": {
      "type": ["boolean", "null"]
    },
    "timestamp": {
      "type": "integer",
      "description": "Unix epoch timestamp in milliseconds"
    }
  }
}
```

---

### 1.5 ServiceStatus Entity
Current operational state of the background Android service.

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "ServiceStatus",
  "type": "object",
  "required": [
    "is_running",
    "is_broadcasting",
    "active_group_id",
    "last_update_timestamp",
    "battery_optimization_ignored"
  ],
  "properties": {
    "is_running": {
      "type": "boolean"
    },
    "is_broadcasting": {
      "type": "boolean"
    },
    "active_group_id": {
      "type": ["string", "null"]
    },
    "last_update_timestamp": {
      "type": ["integer", "null"]
    },
    "battery_optimization_ignored": {
      "type": "boolean"
    },
    "location_permission_status": {
      "type": "string",
      "enum": ["granted_fine", "granted_coarse", "denied", "unknown"]
    }
  }
}
```

---

## 2. IPC Commands Contract (Client ↔ Service)

Communicated over AIDL interface `IShadowTraceService`.

| Command / Method | Arguments | Return Type | Description |
|---|---|---|---|
| `getDeviceId` | None | `String` | Returns deterministic device ID derived from Keystore. |
| `startBroadcasting` | `String groupId` | `boolean` | Initiates foreground location collection & publishing for `groupId`. |
| `stopBroadcasting` | None | `boolean` | Stops location collection & transitions service to idle foreground state. |
| `getServiceStatus` | None | `String (JSON)` | Returns serialized `ServiceStatus` payload. |
| `getLastKnownLocation` | None | `String (JSON)` | Returns serialized `LocationUpdate` of the most recent coordinate. |

---

## 3. Pairing QR Payload Format

The pairing QR code encodes a compact URI scheme:

```text
shadowtrace://v1/join?gid=<UUID>&sec=<32_BYTE_HEX_TOKEN>&exp=<UNIX_EPOCH_MS>
```

Example:
```text
shadowtrace://v1/join?gid=a8b3c4d5-e6f7-4a1b-8c2d-3e4f5a6b7c8d&sec=9f83ab21e054cc48d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4&exp=1787834400000
```
