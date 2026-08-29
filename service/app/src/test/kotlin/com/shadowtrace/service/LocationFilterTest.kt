package com.shadowtrace.service

import android.location.Location
import com.shadowtrace.service.location.LocationFilter
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.mockito.kotlin.doReturn
import org.mockito.kotlin.mock

class LocationFilterTest {

    @Test
    fun isValidLocation_acceptsNormalLocation() {
        val location = mock<Location> {
            on { latitude } doReturn 37.7749
            on { longitude } doReturn -122.4194
            on { accuracy } doReturn 5.0f
            on { hasSpeed() } doReturn true
            on { speed } doReturn 2.5f
        }

        assertTrue(LocationFilter.isValidLocation(location))
    }

    @Test
    fun isValidLocation_rejectsInvalidAccuracyOrBounds() {
        val badAccuracy = mock<Location> {
            on { latitude } doReturn 37.7749
            on { longitude } doReturn -122.4194
            on { accuracy } doReturn 85.0f // > 50.0m limit
        }
        assertFalse(LocationFilter.isValidLocation(badAccuracy))

        val badLat = mock<Location> {
            on { latitude } doReturn 95.0
            on { longitude } doReturn -122.4194
            on { accuracy } doReturn 5.0f
        }
        assertFalse(LocationFilter.isValidLocation(badLat))
    }

    @Test
    fun isStationary_identifiesLowSpeed() {
        val stationaryLocation = mock<Location> {
            on { hasSpeed() } doReturn true
            on { speed } doReturn 0.2f // < 0.6 m/s
        }
        assertTrue(LocationFilter.isStationary(stationaryLocation))

        val movingLocation = mock<Location> {
            on { hasSpeed() } doReturn true
            on { speed } doReturn 3.5f // > 0.6 m/s
        }
        assertFalse(LocationFilter.isStationary(movingLocation))
    }
}
