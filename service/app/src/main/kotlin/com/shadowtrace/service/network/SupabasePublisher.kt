package com.shadowtrace.service.network

import android.location.Location
import android.util.Log

/**
 * Publisher stub for direct telemetry transmission to Supabase Ingest (Phase 6).
 */
class SupabasePublisher {
    companion object {
        private const val TAG = "SupabasePublisher"
    }

    suspend fun publishLocation(
        deviceId: String,
        groupId: String,
        location: Location
    ): Boolean {
        // Direct telemetry ingest will be integrated in Phase 6.
        Log.d(
            TAG,
            "Publishing location for device $deviceId in group $groupId: (${location.latitude}, ${location.longitude})"
        )
        return true
    }
}
