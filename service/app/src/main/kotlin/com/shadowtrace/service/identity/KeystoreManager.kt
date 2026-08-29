package com.shadowtrace.service.identity

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import java.security.KeyPair
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.MessageDigest
import java.security.PublicKey
import java.security.spec.ECGenParameterSpec
import android.util.Base64

import java.security.Signature

object KeystoreManager {
    private const val ANDROID_KEYSTORE = "AndroidKeyStore"
    private const val KEY_ALIAS = "shadowtrace_device_identity_key"
    private const val SIGNATURE_ALGORITHM = "SHA256withECDSA"

    fun getOrCreateIdentityKey(): KeyPair {
        val keyStore = KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }
        if (!keyStore.containsAlias(KEY_ALIAS)) {
            val keyPairGenerator = KeyPairGenerator.getInstance(
                KeyProperties.KEY_ALGORITHM_EC,
                ANDROID_KEYSTORE
            )
            val parameterSpec = KeyGenParameterSpec.Builder(
                KEY_ALIAS,
                KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY
            )
                .setAlgorithmParameterSpec(ECGenParameterSpec("secp256r1"))
                .setDigests(KeyProperties.DIGEST_SHA256)
                .build()

            keyPairGenerator.initialize(parameterSpec)
            return keyPairGenerator.generateKeyPair()
        }

        val entry = keyStore.getEntry(KEY_ALIAS, null) as KeyStore.PrivateKeyEntry
        return KeyPair(entry.certificate.publicKey, entry.privateKey)
    }

    fun getPublicKey(): PublicKey {
        return getOrCreateIdentityKey().public
    }

    fun getPublicKeyBase64(): String {
        return Base64.encodeToString(getPublicKey().encoded, Base64.NO_WRAP)
    }

    fun getDeviceId(): String {
        val publicKeyEncoded = getPublicKey().encoded
        return computeSha256Hex(publicKeyEncoded)
    }

    fun computeSha256Hex(bytes: ByteArray): String {
        val digest = MessageDigest.getInstance("SHA-256").digest(bytes)
        return digest.joinToString("") { "%02x".format(it) }
    }

    fun getCanonicalPayload(
        deviceId: String,
        groupId: String,
        latitude: Double,
        longitude: Double,
        accuracyM: Double,
        timestamp: Long
    ): String {
        return "$deviceId:$groupId:$latitude:$longitude:$accuracyM:$timestamp"
    }

    fun signData(data: ByteArray): String {
        val privateKey = getOrCreateIdentityKey().private
        val signature = Signature.getInstance(SIGNATURE_ALGORITHM).apply {
            initSign(privateKey)
            update(data)
        }
        return Base64.encodeToString(signature.sign(), Base64.NO_WRAP)
    }

    fun verifySignature(publicKey: PublicKey, data: ByteArray, signatureBase64: String): Boolean {
        return try {
            val sigBytes = Base64.decode(signatureBase64, Base64.NO_WRAP)
            val signature = Signature.getInstance(SIGNATURE_ALGORITHM).apply {
                initVerify(publicKey)
                update(data)
            }
            signature.verify(sigBytes)
        } catch (e: Exception) {
            false
        }
    }
}
