package com.reedom.audiflow_app

import android.support.v4.media.session.MediaSessionCompat
import android.util.Log
import com.ryanheise.audioservice.AudioService
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Handles `audiflow/session_queue`: sets the media session's queue title,
 * which Android Auto shows as the heading of the queue list.
 *
 * audio_service has no call for this, and its service instance and session
 * are not public, so they are reached by name; `proguard-rules.pro` keeps
 * those names in release builds. If a plugin upgrade renames them, the only
 * effect is that the list loses its heading, which does not justify keeping
 * a fork of the plugin for one string.
 */
object SessionQueueChannel {
    private const val CHANNEL_NAME = "audiflow/session_queue"
    private const val TAG = "SessionQueueChannel"

    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, CHANNEL_NAME).setMethodCallHandler { call, result ->
            when (call.method) {
                "setTitle" -> result.success(setTitle(call.arguments as? String))
                else -> result.notImplemented()
            }
        }
    }

    /** Returns false when no session exists yet or it could not be reached. */
    private fun setTitle(title: String?): Boolean {
        return try {
            val session = currentSession() ?: return false
            session.setQueueTitle(title)
            true
        } catch (e: ReflectiveOperationException) {
            Log.w(TAG, "audio_service no longer exposes its media session", e)
            false
        }
    }

    private fun currentSession(): MediaSessionCompat? {
        val service = AudioService::class.java.getDeclaredField("instance")
            .apply { isAccessible = true }
            .get(null) ?: return null
        return AudioService::class.java.getDeclaredField("mediaSession")
            .apply { isAccessible = true }
            .get(service) as? MediaSessionCompat
    }
}
