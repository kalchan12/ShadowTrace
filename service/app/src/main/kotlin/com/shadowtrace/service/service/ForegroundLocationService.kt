package com.shadowtrace.service.service

import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.ServiceCompat
import com.shadowtrace.service.identity.KeystoreManager
import com.shadowtrace.service.location.FusedLocationEngine
import com.shadowtrace.service.network.DirectPeerDispatcher
import com.shadowtrace.service.network.DirectPeerReceiver
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

class ForegroundLocationService : Service() {

    companion object {
        const val ACTION_START_BROADCAST = "com.shadowtrace.service.ACTION_START_BROADCAST"
        const val EXTRA_GROUP_ID = "com.shadowtrace.service.EXTRA_GROUP_ID"
    }

    private val serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private lateinit var locationEngine: FusedLocationEngine
    private val peerDispatcher = DirectPeerDispatcher()
    private val peerReceiver = DirectPeerReceiver()

    override fun onCreate() {
        super.onCreate()
        locationEngine = FusedLocationEngine(this) { location ->
            ServiceStateHolder.updateLocation(location)
            val activeGid = ServiceStateHolder.activeGroupId.value
            if (activeGid != null && ServiceStateHolder.isBroadcasting.value) {
                serviceScope.launch {
                    val deviceId = KeystoreManager.getDeviceId()
                    peerDispatcher.dispatchLocation(
                        deviceId = deviceId,
                        groupId = activeGid,
                        location = location
                    )
                }
            }
        }
        peerReceiver.startListening(serviceScope)
        ServiceStateHolder.updateServiceRunning(true)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action

        when (action) {
            ACTION_START_BROADCAST -> {
                val groupId = intent.getStringExtra(EXTRA_GROUP_ID)
                startForegroundBroadcast(groupId)
            }
            ServiceNotificationHelper.ACTION_STOP_BROADCAST -> {
                stopForegroundBroadcast()
            }
        }

        return START_STICKY
    }

    private fun startForegroundBroadcast(groupId: String?) {
        ServiceStateHolder.setBroadcasting(true, groupId)
        val notification = ServiceNotificationHelper.buildNotification(this, true, groupId)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ServiceCompat.startForeground(
                this,
                ServiceNotificationHelper.NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION
            )
        } else {
            startForeground(ServiceNotificationHelper.NOTIFICATION_ID, notification)
        }

        locationEngine.startUpdates()
    }

    private fun stopForegroundBroadcast() {
        locationEngine.stopUpdates()
        ServiceStateHolder.setBroadcasting(false)
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        locationEngine.stopUpdates()
        peerReceiver.stopListening()
        serviceScope.cancel()
        ServiceStateHolder.updateServiceRunning(false)
        ServiceStateHolder.setBroadcasting(false)
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
