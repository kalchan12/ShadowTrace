package com.shadowtrace.service.service

import android.location.Location
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import org.json.JSONObject

object ServiceStateHolder {
    private val _isRunning = MutableStateFlow(false)
    val isRunning: StateFlow<Boolean> = _isRunning.asStateFlow()

    private val _isBroadcasting = MutableStateFlow(false)
    val isBroadcasting: StateFlow<Boolean> = _isBroadcasting.asStateFlow()

    private val _activeGroupId = MutableStateFlow<String?>(null)
    val activeGroupId: StateFlow<String?> = _activeGroupId.asStateFlow()

    private val _lastLocation = MutableStateFlow<Location?>(null)
    val lastLocation: StateFlow<Location?> = _lastLocation.asStateFlow()

    private val _lastUpdateTimestamp = MutableStateFlow<Long?>(null)
    val lastUpdateTimestamp: StateFlow<Long?> = _lastUpdateTimestamp.asStateFlow()

    fun updateServiceRunning(running: Boolean) {
        _isRunning.value = running
    }

    fun setBroadcasting(broadcasting: Boolean, groupId: String? = null) {
        _isBroadcasting.value = broadcasting
        _activeGroupId.value = if (broadcasting) groupId else null
    }

    fun updateLocation(location: Location) {
        _lastLocation.value = location
        _lastUpdateTimestamp.value = System.currentTimeMillis()
    }

    fun toJsonStatus(): String {
        val json = JSONObject()
        json.put("is_running", _isRunning.value)
        json.put("is_broadcasting", _isBroadcasting.value)
        json.put("active_group_id", _activeGroupId.value ?: JSONObject.NULL)
        json.put("last_update_timestamp", _lastUpdateTimestamp.value ?: JSONObject.NULL)
        json.put("battery_optimization_ignored", true)
        json.put("location_permission_status", "granted_fine")
        return json.toString()
    }

    fun lastLocationToJson(): String {
        val loc = _lastLocation.value ?: return "{}"
        val json = JSONObject()
        json.put("latitude", loc.latitude)
        json.put("longitude", loc.longitude)
        json.put("accuracy_m", loc.accuracy)
        json.put("speed_mps", if (loc.hasSpeed()) loc.speed else JSONObject.NULL)
        json.put("bearing_deg", if (loc.hasBearing()) loc.bearing else JSONObject.NULL)
        json.put("altitude_m", if (loc.hasAltitude()) loc.altitude else JSONObject.NULL)
        json.put("timestamp", loc.time)
        return json.toString()
    }
}
