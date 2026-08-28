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
}
