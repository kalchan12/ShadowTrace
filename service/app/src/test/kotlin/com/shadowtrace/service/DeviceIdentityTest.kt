package com.shadowtrace.service

import com.shadowtrace.service.identity.KeystoreManager
import org.junit.Assert.assertEquals
import org.junit.Test

class DeviceIdentityTest {

    @Test
    fun computeSha256Hex_computesCorrectHash() {
        val input = "ShadowTraceDeviceKey".toByteArray(Charsets.UTF_8)
        val hash = KeystoreManager.computeSha256Hex(input)
        assertEquals(64, hash.length)
    }

    @Test
    fun getCanonicalPayload_formatsDeterministicString() {
        val canonical = KeystoreManager.getCanonicalPayload(
            deviceId = "dev-101",
            groupId = "grp-202",
            latitude = 37.7749,
            longitude = -122.4194,
            accuracyM = 4.5,
            timestamp = 1772184000000L
        )
        assertEquals("dev-101:grp-202:37.7749:-122.4194:4.5:1772184000000", canonical)
    }
}
