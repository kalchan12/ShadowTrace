package com.shadowtrace.service.identity

data class DeviceIdentity(
    val deviceId: String,
    val publicKeyBase64: String,
    val createdAtEpochMs: Long
) {
    companion object {
        fun current(): DeviceIdentity {
            return DeviceIdentity(
                deviceId = KeystoreManager.getDeviceId(),
                publicKeyBase64 = KeystoreManager.getPublicKeyBase64(),
                createdAtEpochMs = System.currentTimeMillis()
            )
        }
    }
}
