package com.shadowtrace.service

import android.app.Application
import com.shadowtrace.service.identity.KeystoreManager
import com.shadowtrace.service.service.ServiceNotificationHelper

class ShadowTraceApp : Application() {
    override fun onCreate() {
        super.onCreate()
        ServiceNotificationHelper.createNotificationChannel(this)
        // Ensure hardware identity key exists on application startup
        KeystoreManager.getOrCreateIdentityKey()
    }
}
