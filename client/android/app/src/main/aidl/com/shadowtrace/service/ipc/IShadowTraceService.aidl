package com.shadowtrace.service.ipc;

interface IShadowTraceService {
    /**
     * Retrieves the hardware-backed device identifier (SHA-256 fingerprint of public key).
     */
    String getDeviceId();

    /**
     * Starts foreground location telemetry collection and publishing for the given group.
     */
    boolean startBroadcasting(String groupId);

    /**
     * Stops location telemetry collection and places the service in dormant standby.
     */
    boolean stopBroadcasting();

    /**
     * Returns the serialized JSON ServiceStatus of the background service.
     */
    String getServiceStatus();

    /**
     * Returns the serialized JSON LocationUpdate of the most recent coordinate.
     */
    String getLastKnownLocation();
}
