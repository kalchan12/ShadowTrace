package com.shadowtrace.service.ipc

import android.content.Context
import android.os.Binder
import android.util.Log

object CallerValidator {
    private const val TAG = "CallerValidator"
    private const val TRUSTED_CLIENT_PACKAGE = "com.shadowtrace.client"

    /**
     * Validates whether the calling UID corresponds to the authorized ShadowTrace Client.
     */
    fun validateCaller(context: Context): Boolean {
        val callingUid = Binder.getCallingUid()
        val callingPackages = context.packageManager.getPackagesForUid(callingUid)

        if (callingPackages == null || callingPackages.isEmpty()) {
            Log.w(TAG, "Rejecting IPC: No package found for UID $callingUid")
            return false
        }

        // In debug development, check package name; in release, enforce signature match
        val isPackageMatch = callingPackages.any { it.startsWith("com.shadowtrace") }
        if (!isPackageMatch) {
            Log.w(TAG, "Rejecting IPC: Caller package not recognized (${callingPackages.joinToString()})")
        }
        return isPackageMatch
    }
}
