package com.shadowtrace.shadowtrace_client

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.content.pm.PackageManager
import android.os.IBinder
import android.util.Log
import com.shadowtrace.service.ipc.IShadowTraceService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val TAG = "ShadowTrace.MainActivity"
        private const val CHANNEL_NAME = "com.shadowtrace.client/service_bridge"
        private const val SERVICE_PACKAGE = "com.shadowtrace.service"
        private const val SERVICE_ACTION = "com.shadowtrace.service.ACTION_BIND_IPC"
    }

    private var serviceChannel: MethodChannel? = null
    private var shadowTraceService: IShadowTraceService? = null
    private var isBound = false
    private var pendingResult: MethodChannel.Result? = null
    private var pendingCall: MethodCall? = null

    /**
     * AIDL ServiceConnection that manages the binding lifecycle
     * to the ShadowTrace Service APK.
     */
    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, binder: IBinder?) {
            Log.i(TAG, "Connected to ShadowTrace Service: $name")
            shadowTraceService = IShadowTraceService.Stub.asInterface(binder)
            isBound = true

            // If there was a pending call waiting for the connection, execute it now
            val call = pendingCall
            val result = pendingResult
            if (call != null && result != null) {
                pendingCall = null
                pendingResult = null
                handleMethodCall(call, result)
            }
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            Log.w(TAG, "Disconnected from ShadowTrace Service: $name")
            shadowTraceService = null
            isBound = false
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        serviceChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        serviceChannel?.setMethodCallHandler { call, result ->
            handleMethodCall(call, result)
        }

        // Attempt to bind to the service proactively on startup
        bindToServiceIfAvailable()
    }

    override fun onDestroy() {
        unbindFromService()
        serviceChannel?.setMethodCallHandler(null)
        serviceChannel = null
        super.onDestroy()
    }

    // ─────────────────────────────────────────────
    // Method Call Dispatcher
    // ─────────────────────────────────────────────

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isServiceInstalled" -> handleIsServiceInstalled(result)
            "getDeviceId" -> handleGetDeviceId(result)
            "startBroadcasting" -> handleStartBroadcasting(call, result)
            "stopBroadcasting" -> handleStopBroadcasting(result)
            "getServiceStatus" -> handleGetServiceStatus(result)
            "getLastKnownLocation" -> handleGetLastKnownLocation(result)
            else -> result.notImplemented()
        }
    }

    // ─────────────────────────────────────────────
    // IPC Method Handlers
    // ─────────────────────────────────────────────

    /**
     * Checks if the ShadowTrace Service APK is installed on the device.
     */
    private fun handleIsServiceInstalled(result: MethodChannel.Result) {
        try {
            val isInstalled = isServicePackageInstalled()
            result.success(isInstalled)
        } catch (e: Exception) {
            Log.e(TAG, "Error checking service installation", e)
            result.error("SERVICE_CHECK_FAILED", e.message, null)
        }
    }

    /**
     * Retrieves the hardware-backed device identifier from the Service.
     */
    private fun handleGetDeviceId(result: MethodChannel.Result) {
        val service = shadowTraceService
        if (service == null) {
            // Try binding first, queue the call
            if (bindToServiceIfAvailable()) {
                pendingCall = MethodCall("getDeviceId", null)
                pendingResult = result
            } else {
                result.error("SERVICE_NOT_BOUND", "ShadowTrace Service is not connected", null)
            }
            return
        }

        try {
            val deviceId = service.deviceId
            result.success(deviceId)
        } catch (e: Exception) {
            Log.e(TAG, "Error getting device ID via IPC", e)
            result.error("IPC_ERROR", "Failed to get device ID: ${e.message}", null)
        }
    }

    /**
     * Starts location broadcast for the given group ID.
     */
    private fun handleStartBroadcasting(call: MethodCall, result: MethodChannel.Result) {
        val groupId = call.argument<String>("groupId")
        if (groupId == null) {
            result.error("INVALID_ARGUMENT", "groupId is required", null)
            return
        }

        val service = shadowTraceService
        if (service == null) {
            if (bindToServiceIfAvailable()) {
                pendingCall = call
                pendingResult = result
            } else {
                result.error("SERVICE_NOT_BOUND", "ShadowTrace Service is not connected", null)
            }
            return
        }

        try {
            val success = service.startBroadcasting(groupId)
            result.success(success)
        } catch (e: Exception) {
            Log.e(TAG, "Error starting broadcast via IPC", e)
            result.error("IPC_ERROR", "Failed to start broadcasting: ${e.message}", null)
        }
    }

    /**
     * Stops location broadcast.
     */
    private fun handleStopBroadcasting(result: MethodChannel.Result) {
        val service = shadowTraceService
        if (service == null) {
            if (bindToServiceIfAvailable()) {
                pendingCall = MethodCall("stopBroadcasting", null)
                pendingResult = result
            } else {
                result.error("SERVICE_NOT_BOUND", "ShadowTrace Service is not connected", null)
            }
            return
        }

        try {
            val success = service.stopBroadcasting()
            result.success(success)
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping broadcast via IPC", e)
            result.error("IPC_ERROR", "Failed to stop broadcasting: ${e.message}", null)
        }
    }

    /**
     * Retrieves the current service status as a JSON string.
     */
    private fun handleGetServiceStatus(result: MethodChannel.Result) {
        val service = shadowTraceService
        if (service == null) {
            if (bindToServiceIfAvailable()) {
                pendingCall = MethodCall("getServiceStatus", null)
                pendingResult = result
            } else {
                result.error("SERVICE_NOT_BOUND", "ShadowTrace Service is not connected", null)
            }
            return
        }

        try {
            val statusJson = service.serviceStatus
            result.success(statusJson)
        } catch (e: Exception) {
            Log.e(TAG, "Error getting service status via IPC", e)
            result.error("IPC_ERROR", "Failed to get service status: ${e.message}", null)
        }
    }

    /**
     * Retrieves the most recent location as a JSON string.
     */
    private fun handleGetLastKnownLocation(result: MethodChannel.Result) {
        val service = shadowTraceService
        if (service == null) {
            if (bindToServiceIfAvailable()) {
                pendingCall = MethodCall("getLastKnownLocation", null)
                pendingResult = result
            } else {
                result.error("SERVICE_NOT_BOUND", "ShadowTrace Service is not connected", null)
            }
            return
        }

        try {
            val locationJson = service.lastKnownLocation
            result.success(locationJson)
        } catch (e: Exception) {
            Log.e(TAG, "Error getting last known location via IPC", e)
            result.error("IPC_ERROR", "Failed to get last known location: ${e.message}", null)
        }
    }

    // ─────────────────────────────────────────────
    // Service Binding Management
    // ─────────────────────────────────────────────

    /**
     * Attempts to bind to the ShadowTrace Service APK if it is installed.
     * Returns true if binding was initiated or already bound, false if service not found.
     */
    private fun bindToServiceIfAvailable(): Boolean {
        if (isBound && shadowTraceService != null) return true

        if (!isServicePackageInstalled()) {
            Log.w(TAG, "ShadowTrace Service APK is not installed")
            return false
        }

        val bindIntent = Intent(SERVICE_ACTION).apply {
            setPackage(SERVICE_PACKAGE)
        }

        return try {
            val bound = bindService(bindIntent, serviceConnection, Context.BIND_AUTO_CREATE)
            if (!bound) {
                Log.e(TAG, "bindService() returned false — service not found or permission denied")
            }
            bound
        } catch (e: SecurityException) {
            Log.e(TAG, "SecurityException binding to Service: ${e.message}", e)
            false
        }
    }

    /**
     * Safely unbinds from the ShadowTrace Service.
     */
    private fun unbindFromService() {
        if (isBound) {
            try {
                unbindService(serviceConnection)
            } catch (e: IllegalArgumentException) {
                Log.w(TAG, "Service was already unbound", e)
            }
            isBound = false
            shadowTraceService = null
        }
    }

    /**
     * Checks whether the ShadowTrace Service package is installed on the device.
     */
    private fun isServicePackageInstalled(): Boolean {
        return try {
            packageManager.getPackageInfo(SERVICE_PACKAGE, PackageManager.GET_ACTIVITIES)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }
}
