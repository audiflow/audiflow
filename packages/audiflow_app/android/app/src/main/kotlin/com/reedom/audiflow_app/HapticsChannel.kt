package com.reedom.audiflow_app

import android.app.Activity
import android.os.Build
import android.view.HapticFeedbackConstants as C
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference

/**
 * Handles `audiflow/haptics`: plays catalog haptic tokens with
 * `View.performHapticFeedback`.
 *
 * `performHapticFeedback` needs no VIBRATE permission and follows the
 * user's touch-feedback setting, unlike `Vibrator`. The token-to-constant
 * mapping and the substitutes for older OS versions are specified in
 * `docs/design/haptics.md` sections 2 and 4.2.
 */
object HapticsChannel {
    private const val CHANNEL_NAME = "audiflow/haptics"

    /** A constant and the nearest older one to play below [sinceSdk]. */
    private data class Mapping(val constant: Int, val sinceSdk: Int, val fallback: Int)

    private const val API_30 = Build.VERSION_CODES.R
    private const val API_34 = Build.VERSION_CODES.UPSIDE_DOWN_CAKE

    // `warning` is deliberately absent: Android has no warning constant, and
    // every near candidate already carries another token's meaning.
    private val mappings = mapOf(
        "selection" to Mapping(C.SEGMENT_TICK, API_34, C.CLOCK_TICK),
        "detent" to Mapping(C.SEGMENT_TICK, API_34, C.CLOCK_TICK),
        "toggleOn" to Mapping(C.TOGGLE_ON, API_34, C.CONTEXT_CLICK),
        "toggleOff" to Mapping(C.TOGGLE_OFF, API_34, C.CLOCK_TICK),
        "tap" to Mapping(C.VIRTUAL_KEY, 0, C.VIRTUAL_KEY),
        "longPress" to Mapping(C.LONG_PRESS, 0, C.LONG_PRESS),
        "thresholdCross" to Mapping(C.GESTURE_THRESHOLD_ACTIVATE, API_34, C.CONTEXT_CLICK),
        "thresholdRelease" to Mapping(C.GESTURE_THRESHOLD_DEACTIVATE, API_34, C.CLOCK_TICK),
        "dragPickUp" to Mapping(C.DRAG_START, API_34, C.LONG_PRESS),
        "dragStep" to Mapping(C.SEGMENT_FREQUENT_TICK, API_34, C.CLOCK_TICK),
        "dragDrop" to Mapping(C.GESTURE_END, API_30, C.CLOCK_TICK),
        "success" to Mapping(C.CONFIRM, API_30, C.VIRTUAL_KEY),
        "error" to Mapping(C.REJECT, API_30, C.LONG_PRESS),
    )

    fun register(messenger: BinaryMessenger, activity: Activity) {
        // audio_service caches the engine beyond the activity's lifetime, so
        // a strong reference here would leak a destroyed MainActivity.
        val activityRef = WeakReference(activity)
        MethodChannel(messenger, CHANNEL_NAME).setMethodCallHandler { call, result ->
            when (call.method) {
                "play" -> {
                    play(activityRef.get(), call.arguments as? String)
                    result.success(null)
                }
                // Android has no warm-up step for performHapticFeedback.
                "prepare" -> result.success(null)
                else -> result.notImplemented()
            }
        }
    }

    private fun play(activity: Activity?, token: String?) {
        val live = activity?.takeUnless { it.isFinishing || it.isDestroyed } ?: return
        // An unknown token plays nothing: a newer Dart build must never
        // crash an older native build over a missing haptic.
        val mapping = mappings[token] ?: return
        live.window?.decorView?.performHapticFeedback(constantFor(mapping))
    }

    // A constant newer than the running OS plays nothing, so it falls back
    // to the nearest older constant (the AndroidX compat approach).
    private fun constantFor(mapping: Mapping): Int =
        if (mapping.sinceSdk <= Build.VERSION.SDK_INT) mapping.constant else mapping.fallback
}
