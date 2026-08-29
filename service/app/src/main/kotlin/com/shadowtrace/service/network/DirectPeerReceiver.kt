package com.shadowtrace.service.network

import android.util.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetSocketAddress

/**
 * Background UDP receiver listening for incoming peer telemetry datagrams on the local network (Phase 6).
 */
class DirectPeerReceiver(
    private val port: Int = DirectPeerDispatcher.DEFAULT_PORT
) {
    companion object {
        private const val TAG = "DirectPeerReceiver"
        private const val BUFFER_SIZE = 2048
    }

    private var socket: DatagramSocket? = null
    private var listeningJob: Job? = null

    private val _incomingTelemetry = MutableSharedFlow<String>(extraBufferCapacity = 64)
    val incomingTelemetry: SharedFlow<String> = _incomingTelemetry.asSharedFlow()

    /**
     * Start listening for incoming P2P telemetry packets on a background coroutine scope.
     */
    fun startListening(scope: CoroutineScope) {
        if (listeningJob != null && listeningJob?.isActive == true) return

        listeningJob = scope.launch(Dispatchers.IO) {
            try {
                val s = DatagramSocket(null).apply {
                    reuseAddress = true
                    bind(InetSocketAddress(port))
                    broadcast = true
                }
                socket = s
                Log.d(TAG, "Started UDP telemetry receiver on port $port")

                val buffer = ByteArray(BUFFER_SIZE)

                while (isActive && !s.isClosed) {
                    val packet = DatagramPacket(buffer, buffer.size)
                    s.receive(packet)

                    val json = String(packet.data, packet.offset, packet.length, Charsets.UTF_8).trim()
                    if (json.isNotEmpty() && json.startsWith("{") && json.endsWith("}")) {
                        Log.d(TAG, "Received peer telemetry from ${packet.address}:${packet.port} ($json)")
                        _incomingTelemetry.emit(json)
                    }
                }
            } catch (e: Exception) {
                if (isActive) {
                    Log.e(TAG, "UDP listener encountered error: ${e.message}", e)
                }
            } finally {
                stopListening()
            }
        }
    }

    /**
     * Stop listening and close the underlying socket.
     */
    fun stopListening() {
        listeningJob?.cancel()
        listeningJob = null
        try {
            socket?.close()
        } catch (_: Exception) {}
        socket = null
        Log.d(TAG, "Stopped UDP telemetry receiver")
    }
}
