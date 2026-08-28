package com.shadowtrace.service.location

import android.location.Location

object LocationFilter {
    private const val MAX_ACCEPTABLE_ACCURACY_METERS = 50.0f
    private const val MAX_PLAUSIBLE_SPEED_MPS = 100.0f // ~360 km/h

    fun isValidLocation(location: Location?): Boolean {
        if (location == null) return false
        if (location.latitude < -90.0 || location.latitude > 90.0) return false
        if (location.longitude < -180.0 || location.longitude > 180.0) return false
        if (location.accuracy <= 0.0f || location.accuracy > MAX_ACCEPTABLE_ACCURACY_METERS) return false
        if (location.hasSpeed() && location.speed > MAX_PLAUSIBLE_SPEED_MPS) return false
        return true
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
