package com.shadowtrace.service.location

import android.annotation.SuppressLint
import android.content.Context
import android.location.Location
import android.os.Looper
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority

class FusedLocationEngine(
    private val context: Context,
    private val onLocationChanged: (Location) -> Unit
) {
    private val fusedLocationClient: FusedLocationProviderClient =
        LocationServices.getFusedLocationProviderClient(context)

    private var lastEmittedLocation: Location? = null
    private var isTracking: Boolean = false

    private val locationCallback = object : LocationCallback() {
        override fun onLocationResult(result: LocationResult) {
            val location = result.lastLocation ?: return
            if (!LocationFilter.isValidLocation(location)) return

            if (LocationFilter.hasSignificantMovement(lastEmittedLocation, location)) {
                lastEmittedLocation = location
                onLocationChanged(location)
            }
        }
    }

    @SuppressLint("MissingPermission")
    fun startUpdates(intervalMs: Long = 10000L, minDistanceMeters: Float = 5.0f) {
        if (isTracking) return

        val locationRequest = LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, intervalMs)
            .setMinUpdateIntervalMillis(intervalMs / 2)
            .setMinUpdateDistanceMeters(minDistanceMeters)
            .setWaitForAccurateLocation(true)
            .build()

        fusedLocationClient.requestLocationUpdates(
            locationRequest,
            locationCallback,
            Looper.getMainLooper()
        )
        isTracking = true
    }

    fun stopUpdates() {
        if (!isTracking) return
        fusedLocationClient.removeLocationUpdates(locationCallback)
        isTracking = false
    }

    fun getLastLocation(): Location? = lastEmittedLocation
}
