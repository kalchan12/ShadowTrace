package com.shadowtrace.service.network

import android.location.Location
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress

/**
 * Dispatcher for direct peer-to-peer telemetry transmission across local networks (Phase 6).
 *
 * Implements zero-cloud ephemeral location packet dispatching directly to paired peers
 * using UDP local subnet broadcasts.
 */
class DirectPeerDispatcher {
    companion object {
        private const val TAG = "DirectPeerDispatcher"
        const val DEFAULT_PORT = 48550
        const val BROADCAST_ADDRESS = "255.255.255.255"

        /**
         * Builds a standard LocationUpdate JSON payload conforming to protocol v1.0.
         */
        fun buildLocationPayload(
            deviceId: String,
            groupId: String,
            location: Location,
            batteryPct: Int? = null,
            isCharging: Boolean? = null
        ): String {
            val json = JSONObject()
            json.put("device_id", deviceId)
            json.put("group_id", groupId)
            json.put("latitude", location.latitude)
            json.put("longitude", location.longitude)
            json.put("accuracy_m", location.accuracy.toDouble())

            if (location.hasAltitude()) {
                json.put("altitude_m", location.altitude)
            } else {
                json.put("altitude_m", JSONObject.NULL)
            }

            if (location.hasSpeed()) {
                json.put("speed_mps", location.speed.toDouble())
            } else {
                json.put("speed_mps", JSONObject.NULL)
            }

            if (location.hasBearing()) {
                json.put("bearing_deg", location.bearing.toDouble())
            } else {
                json.put("bearing_deg", JSONObject.NULL)
            }

            if (batteryPct != null) {
                json.put("battery_pct", batteryPct)
            } else {
                json.put("battery_pct", JSONObject.NULL)
            }

            if (isCharging != null) {
                json.put("is_charging", isCharging)
            } else {
                json.put("is_charging", JSONObject.NULL)
            }

            val timestamp = if (location.time > 0) location.time else System.currentTimeMillis()
            json.put("timestamp", timestamp)

            return json.toString()
        }
    }

    /**
     * Dispatches a location telemetry packet directly over UDP local subnet broadcast.
     */
    suspend fun dispatchLocation(
        deviceId: String,
        groupId: String,
        location: Location,
        port: Int = DEFAULT_PORT,
        batteryPct: Int? = null,
        isCharging: Boolean? = null
    ): Boolean = withContext(Dispatchers.IO) {
        var socket: DatagramSocket? = null
        try {
            val payload = buildLocationPayload(deviceId, groupId, location, batteryPct, isCharging)
            val bytes = payload.toByteArray(Charsets.UTF_8)

            socket = DatagramSocket()
            socket.broadcast = true

            val packet = DatagramPacket(
                bytes,
                bytes.size,
                InetAddress.getByName(BROADCAST_ADDRESS),
                port
            )

            socket.send(packet)
            Log.d(TAG, "Dispatched P2P location packet (${bytes.size} bytes) to $BROADCAST_ADDRESS:$port")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to dispatch direct P2P location: ${e.message}", e)
            false
        } finally {
            try {
                socket?.close()
            } catch (_: Exception) {}
        }
    }
}
