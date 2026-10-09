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

    /**
     * A constant and the nearest older one to play below [sinceSdk].
     * The fallback plays [fallbackRepeats] times, [REPEAT_GAP_MS] apart.
     */
    private data class Mapping(
        val constant: Int,
        val sinceSdk: Int,
        val fallback: Int,
        val fallbackRepeats: Int = 1,
    )

    // Measured from the start of each tap. Old OEM waveforms run longer
    // than a 10-20 ms click (100 ms merged into one buzz on a Huawei
    // Android 8 device), so the gap leaves room for the whole pattern.
    private const val REPEAT_GAP_MS = 200L

    private const val API_30 = Build.VERSION_CODES.R
    private const val API_34 = Build.VERSION_CODES.UPSIDE_DOWN_CAKE

    // `warning` is deliberately absent: Android has no warning constant, and
    // every near candidate already carries another token's meaning.
    private val mappings = mapOf(
        "selection" to Mapping(C.SEGMENT_TICK, API_34, C.CLOCK_TICK),
        "detent" to Mapping(C.SEGMENT_TICK, API_34, C.CLOCK_TICK),
        "step" to Mapping(C.SEGMENT_FREQUENT_TICK, API_34, C.CLOCK_TICK),
        // A click, a step up from the detent tick, so the end reads as a stop.
        "edge" to Mapping(C.VIRTUAL_KEY, 0, C.VIRTUAL_KEY),
        // CONTEXT_CLICK felt heavier than the selection tick below API 34, so
        // on uses the same faint tick as off there; the switch shows which.
        "toggleOn" to Mapping(C.TOGGLE_ON, API_34, C.CLOCK_TICK),
        "toggleOff" to Mapping(C.TOGGLE_OFF, API_34, C.CLOCK_TICK),
        "tap" to Mapping(C.VIRTUAL_KEY, 0, C.VIRTUAL_KEY),
        "longPress" to Mapping(C.LONG_PRESS, 0, C.LONG_PRESS),
        "thresholdCross" to Mapping(C.GESTURE_THRESHOLD_ACTIVATE, API_34, C.CONTEXT_CLICK),
        "thresholdRelease" to Mapping(C.GESTURE_THRESHOLD_DEACTIVATE, API_34, C.CLOCK_TICK),
        "dragPickUp" to Mapping(C.DRAG_START, API_34, C.LONG_PRESS),
        "dragStep" to Mapping(C.SEGMENT_FREQUENT_TICK, API_34, C.CLOCK_TICK),
        "dragDrop" to Mapping(C.GESTURE_END, API_30, C.CLOCK_TICK),
        "success" to Mapping(C.CONFIRM, API_30, C.VIRTUAL_KEY),
        // Below API 30 the old constants play OEM-defined waveforms whose
        // relative strength varies by device, so error is told apart from
        // success by rhythm (two taps, like REJECT) instead of strength.
        "error" to Mapping(C.REJECT, API_30, C.VIRTUAL_KEY, fallbackRepeats = 2),
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
        val view = live.window?.decorView ?: return
        // A constant newer than the running OS plays nothing, so it falls
        // back to the nearest older constant (the AndroidX compat approach).
        if (mapping.sinceSdk <= Build.VERSION.SDK_INT) {
            view.performHapticFeedback(mapping.constant)
            return
        }
        view.performHapticFeedback(mapping.fallback)
        for (i in 1 until mapping.fallbackRepeats) {
            view.postDelayed({ view.performHapticFeedback(mapping.fallback) }, REPEAT_GAP_MS * i)
        }
    }
}
