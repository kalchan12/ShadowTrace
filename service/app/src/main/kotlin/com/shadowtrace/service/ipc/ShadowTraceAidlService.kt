package com.shadowtrace.service.ipc

import android.app.Service
import android.content.Intent
import android.os.IBinder
import androidx.core.content.ContextCompat
import com.shadowtrace.service.identity.KeystoreManager
import com.shadowtrace.service.service.ForegroundLocationService
import com.shadowtrace.service.service.ServiceStateHolder

class ShadowTraceAidlService : Service() {

    private val binder = object : IShadowTraceService.Stub() {
        override fun getDeviceId(): String {
            enforceCallerValidation()
            return KeystoreManager.getDeviceId()
        }

        override fun startBroadcasting(groupId: String): Boolean {
            enforceCallerValidation()
            val intent = Intent(this@ShadowTraceAidlService, ForegroundLocationService::class.java).apply {
                action = ForegroundLocationService.ACTION_START_BROADCAST
                putExtra(ForegroundLocationService.EXTRA_GROUP_ID, groupId)
            }
            ContextCompat.startForegroundService(this@ShadowTraceAidlService, intent)
            return true
        }

        override fun stopBroadcasting(): Boolean {
            enforceCallerValidation()
            val intent = Intent(this@ShadowTraceAidlService, ForegroundLocationService::class.java).apply {
                action = com.shadowtrace.service.service.ServiceNotificationHelper.ACTION_STOP_BROADCAST
            }
            startService(intent)
            return true
        }

        override fun getServiceStatus(): String {
            enforceCallerValidation()
            return ServiceStateHolder.toJsonStatus()
        }

        override fun getLastKnownLocation(): String {
            enforceCallerValidation()
            return ServiceStateHolder.lastLocationToJson()
        }
    }

    private fun enforceCallerValidation() {
        if (!CallerValidator.validateCaller(this)) {
            throw SecurityException("Unauthorized caller attempting to access ShadowTrace Service IPC.")
        }
    }

    override fun onBind(intent: Intent?): IBinder {
        return binder
    }
}
