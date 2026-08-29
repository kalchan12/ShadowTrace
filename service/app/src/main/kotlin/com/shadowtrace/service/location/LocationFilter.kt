package com.shadowtrace.service.location

import android.location.Location

object LocationFilter {
    private const val MAX_ACCEPTABLE_ACCURACY_METERS = 50.0f
    private const val MAX_PLAUSIBLE_SPEED_MPS = 100.0f // ~360 km/h
    const val STATIONARY_SPEED_THRESHOLD_MPS = 0.6f // ~2.1 km/h
    const val STATIONARY_INTERVAL_MS = 30000L // 30s interval when stationary (NFR-1)
    const val MOVING_INTERVAL_MS = 5000L // 5s interval when moving (NFR-2)
    const val STATIONARY_MIN_DISTANCE_M = 20.0f
    const val MOVING_MIN_DISTANCE_M = 5.0f

    fun isValidLocation(location: Location?): Boolean {
        if (location == null) return false
        if (location.latitude < -90.0 || location.latitude > 90.0) return false
        if (location.longitude < -180.0 || location.longitude > 180.0) return false
        if (location.accuracy <= 0.0f || location.accuracy > MAX_ACCEPTABLE_ACCURACY_METERS) return false
        if (location.hasSpeed() && location.speed > MAX_PLAUSIBLE_SPEED_MPS) return false
        return true
    }

    fun isStationary(location: Location): Boolean {
        return if (location.hasSpeed()) {
            location.speed < STATIONARY_SPEED_THRESHOLD_MPS
        } else {
            false
        }
    }

    fun hasSignificantMovement(
        lastLocation: Location?,
        newLocation: Location,
        minDisplacementMeters: Float = 5.0f
    ): Boolean {
        if (lastLocation == null) return true
        val distance = lastLocation.distanceTo(newLocation)
        return distance >= minDisplacementMeters
    }
}
