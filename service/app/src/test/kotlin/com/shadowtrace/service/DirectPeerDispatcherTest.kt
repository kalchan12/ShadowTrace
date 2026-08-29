package com.shadowtrace.service

import android.location.Location
import com.shadowtrace.service.network.DirectPeerDispatcher
import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Test
import org.mockito.kotlin.doReturn
import org.mockito.kotlin.mock

class DirectPeerDispatcherTest {

    @Test
    fun buildLocationPayload_createsConformingJson() {
        val location = mock<Location> {
            on { latitude } doReturn 37.7749
            on { longitude } doReturn -122.4194
            on { accuracy } doReturn 4.5f
            on { hasSpeed() } doReturn true
            on { speed } doReturn 1.2f
            on { hasBearing() } doReturn true
            on { bearing } doReturn 90.0f
            on { hasAltitude() } doReturn true
            on { altitude } doReturn 15.0
            on { time } doReturn 1772184000000L
        }

        val jsonString = DirectPeerDispatcher.buildLocationPayload(
            deviceId = "dev-test-123",
            groupId = "grp-test-456",
            location = location,
            batteryPct = 85,
            isCharging = false
        )

        assertNotNull(jsonString)
        val json = JSONObject(jsonString)

        assertEquals("dev-test-123", json.getString("device_id"))
        assertEquals("grp-test-456", json.getString("group_id"))
        assertEquals(37.7749, json.getDouble("latitude"), 0.0001)
        assertEquals(-122.4194, json.getDouble("longitude"), 0.0001)
        assertEquals(4.5, json.getDouble("accuracy_m"), 0.001)
        assertEquals(1.2, json.getDouble("speed_mps"), 0.001)
        assertEquals(90.0, json.getDouble("bearing_deg"), 0.001)
        assertEquals(15.0, json.getDouble("altitude_m"), 0.001)
        assertEquals(85, json.getInt("battery_pct"))
        assertEquals(false, json.getBoolean("is_charging"))
        assertEquals(1772184000000L, json.getLong("timestamp"))
    }
}
