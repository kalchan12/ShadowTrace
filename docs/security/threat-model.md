# Threat Model Specification

---

## 1. Scope & System Boundaries

The threat model analyzes potential attack vectors against:
1. Android OS level (Local device, inter-app IPC).
2. Network transport level (TLS, WebSockets).
3. Backend level (Supabase database, RLS policies).

---

## 2. Attack Vectors & Mitigations

### 2.1 IPC Hijacking & Impersonation
* **Threat:** A malicious app installed on the same device attempts to bind to `ShadowTraceAidlService` to extract real-time coordinates.
* **Mitigation:** Strict package signature verification in `ShadowTraceAidlService` via `PackageManager.checkSignatures()`. Calls from non-matching UIDs are instantly rejected.

### 2.2 Network Eavesdropping & Tampering
* **Threat:** An attacker on the local network monitors or alters location telemetry in transit.
* **Mitigation:** Mandatory TLS 1.3 encryption on all REST and WebSocket connections. Cryptographic signatures on telemetry packets ensure tamper detection.

### 2.3 Replay Attacks
* **Threat:** An attacker intercepts a valid signed location packet and retransmits it later to spoof a user's location.
* **Mitigation:** Telemetry packets require millisecond timestamps and monotonic nonces. Packets older than 60 seconds or with expired nonces are rejected.

### 2.4 Database Breach / Unauthorized Exfiltration
* **Threat:** An unauthorized client queries the Supabase API to harvest locations of groups they do not belong to.
* **Mitigation:** Supabase PostgreSQL Row-Level Security (RLS) restricts read access to `current_locations` strictly to authenticated group members.
