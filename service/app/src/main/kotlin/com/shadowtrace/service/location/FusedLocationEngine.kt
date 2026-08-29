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

import android.util.Log

class FusedLocationEngine(
    private val context: Context,
    private val onLocationChanged: (Location) -> Unit
) {
    companion object {
        private const val TAG = "FusedLocationEngine"
    }

    private val fusedLocationClient: FusedLocationProviderClient =
        LocationServices.getFusedLocationProviderClient(context)

    private var lastEmittedLocation: Location? = null
    private var isTracking: Boolean = false
    private var isStationaryMode: Boolean = false
    private var stationaryCount: Int = 0

    private val locationCallback = object : LocationCallback() {
        override fun onLocationResult(result: LocationResult) {
            val location = result.lastLocation ?: return
            if (!LocationFilter.isValidLocation(location)) return

            handleAdaptiveThrottling(location)

            if (LocationFilter.hasSignificantMovement(lastEmittedLocation, location, if (isStationaryMode) LocationFilter.STATIONARY_MIN_DISTANCE_M else LocationFilter.MOVING_MIN_DISTANCE_M)) {
                lastEmittedLocation = location
                onLocationChanged(location)
            }
        }
    }

    private fun handleAdaptiveThrottling(location: Location) {
        if (LocationFilter.isStationary(location)) {
            stationaryCount++
            if (stationaryCount >= 3 && !isStationaryMode) {
                isStationaryMode = true
                Log.d(TAG, "Device stationary: Throttling GPS polling to ${LocationFilter.STATIONARY_INTERVAL_MS}ms for power optimization")
                reconfigureUpdates(
                    intervalMs = LocationFilter.STATIONARY_INTERVAL_MS,
                    minDistanceM = LocationFilter.STATIONARY_MIN_DISTANCE_M,
                    priority = Priority.PRIORITY_BALANCED_POWER_ACCURACY
                )
            }
        } else {
            stationaryCount = 0
            if (isStationaryMode) {
                isStationaryMode = false
                Log.d(TAG, "Movement detected: Boosting GPS polling to ${LocationFilter.MOVING_INTERVAL_MS}ms")
                reconfigureUpdates(
                    intervalMs = LocationFilter.MOVING_INTERVAL_MS,
                    minDistanceM = LocationFilter.MOVING_MIN_DISTANCE_M,
                    priority = Priority.PRIORITY_HIGH_ACCURACY
                )
            }
        }
    }

    @SuppressLint("MissingPermission")
    private fun reconfigureUpdates(intervalMs: Long, minDistanceM: Float, priority: Int) {
        if (!isTracking) return
        val request = LocationRequest.Builder(priority, intervalMs)
            .setMinUpdateIntervalMillis(intervalMs / 2)
            .setMinUpdateDistanceMeters(minDistanceM)
            .setWaitForAccurateLocation(false)
            .build()

        fusedLocationClient.requestLocationUpdates(
            request,
            locationCallback,
            Looper.getMainLooper()
        )
    }

    @SuppressLint("MissingPermission")
    fun startUpdates(
        intervalMs: Long = LocationFilter.MOVING_INTERVAL_MS,
        minDistanceMeters: Float = LocationFilter.MOVING_MIN_DISTANCE_M
    ) {
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
        isStationaryMode = false
        stationaryCount = 0
    }

    fun getLastLocation(): Location? = lastEmittedLocation
}
