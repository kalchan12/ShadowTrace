package com.shadowtrace.service.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat

object ServiceNotificationHelper {
    const val CHANNEL_ID = "shadowtrace_location_channel"
    const val NOTIFICATION_ID = 1001

    const val ACTION_STOP_BROADCAST = "com.shadowtrace.service.ACTION_STOP_BROADCAST"

    fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "ShadowTrace Location Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Active location broadcast indicator"
                setShowBadge(false)
            }
            val manager = context.getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }

    fun buildNotification(
        context: Context,
        isBroadcasting: Boolean,
        groupId: String? = null
    ): Notification {
        val title = if (isBroadcasting) {
            "ShadowTrace: Broadcasting Active"
        } else {
            "ShadowTrace: Standby"
        }

        val contentText = if (isBroadcasting && groupId != null) {
            "Broadcasting location to group: ${groupId.take(8)}..."
        } else {
            "Location service ready. Tap to manage sharing."
        }

        val stopIntent = Intent(context, ForegroundLocationService::class.java).apply {
            action = ACTION_STOP_BROADCAST
        }
        val stopPendingIntent = PendingIntent.getService(
            context,
            0,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(contentText)
            .setSmallIcon(android.R.drawable.ic_menu_mylocation)
            .setOngoing(isBroadcasting)
            .setPriority(NotificationCompat.PRIORITY_LOW)

        if (isBroadcasting) {
            builder.addAction(
                android.R.drawable.ic_menu_close_clear_cancel,
                "Stop Sharing",
                stopPendingIntent
            )
        }

        return builder.build()
    }
}
