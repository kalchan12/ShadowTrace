# Cryptographic Device Identity Specification

---

## 1. Keystore-Backed Hardware Identity

ShadowTrace rejects traditional password-based authentication. Every device generates a dedicated hardware-backed keypair:

* **Key Type:** Elliptic Curve (EC) using curve `secp256r1` (NIST P-256).
* **Storage Provider:** `AndroidKeyStore`.
* **Key Alias:** `shadowtrace_device_identity_key`.
* **Purposes:** `KeyProperties.PURPOSE_SIGN | KeyProperties.PURPOSE_VERIFY`.
* **Exportability:** Non-exportable (Private key material cannot leave Keymaster/StrongBox TEE).

---

## 2. Device Identifier (`device_id`) Derivation

1. Extract the public key in X.509 DER format (`publicKey.encoded`).
2. Compute the SHA-256 message digest:
   ```kotlin
   val digest = MessageDigest.getInstance("SHA-256").digest(publicKey.encoded)
   val deviceId = digest.joinToString("") { "%02x".format(it) }
   ```
3. The resulting 64-character hex string serves as the `device_id`.

> **Note:** A `device_id` is an identifier, not a secret. Authorization is proven by signing challenges with the corresponding private key.
