package com.reedom.audiflow_app

import android.app.Activity
import android.os.Build
import android.view.HapticFeedbackConstants
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

    fun register(messenger: BinaryMessenger, activity: Activity) {
        // audio_service caches the engine beyond the activity's lifetime, so
        // a strong reference here would leak a destroyed MainActivity.
        val activityRef = WeakReference(activity)
        MethodChannel(messenger, CHANNEL_NAME).setMethodCallHandler { call, result ->
            when (call.method) {
                "play" -> {
                    val token = call.arguments as? String
                    val view = activityRef.get()?.takeUnless { it.isFinishing }?.window?.decorView
                    val constant = token?.let(::constantFor)
                    if (view != null && constant != null) view.performHapticFeedback(constant)
                    result.success(null)
                }
                // Android has no warm-up step for performHapticFeedback.
                "prepare" -> result.success(null)
                else -> result.notImplemented()
            }
        }
    }

    /**
     * The constant for [token], or null when the token plays nothing on
     * Android (`warning`, or a token this build does not know).
     */
    private fun constantFor(token: String): Int? = when (token) {
        "selection", "detent" -> onApi34(HapticFeedbackConstants.SEGMENT_TICK, HapticFeedbackConstants.CLOCK_TICK)
        "toggleOn" -> onApi34(HapticFeedbackConstants.TOGGLE_ON, HapticFeedbackConstants.CONTEXT_CLICK)
        "toggleOff" -> onApi34(HapticFeedbackConstants.TOGGLE_OFF, HapticFeedbackConstants.CLOCK_TICK)
        "tap" -> HapticFeedbackConstants.VIRTUAL_KEY
        "longPress" -> HapticFeedbackConstants.LONG_PRESS
        "thresholdCross" -> onApi34(
            HapticFeedbackConstants.GESTURE_THRESHOLD_ACTIVATE,
            HapticFeedbackConstants.CONTEXT_CLICK,
        )
        "thresholdRelease" -> onApi34(
            HapticFeedbackConstants.GESTURE_THRESHOLD_DEACTIVATE,
            HapticFeedbackConstants.CLOCK_TICK,
        )
        "dragPickUp" -> onApi34(HapticFeedbackConstants.DRAG_START, HapticFeedbackConstants.LONG_PRESS)
        "dragStep" -> onApi34(HapticFeedbackConstants.SEGMENT_FREQUENT_TICK, HapticFeedbackConstants.CLOCK_TICK)
        "dragDrop" -> onApi30(HapticFeedbackConstants.GESTURE_END, HapticFeedbackConstants.CLOCK_TICK)
        "success" -> onApi30(HapticFeedbackConstants.CONFIRM, HapticFeedbackConstants.VIRTUAL_KEY)
        "error" -> onApi30(HapticFeedbackConstants.REJECT, HapticFeedbackConstants.LONG_PRESS)
        // No warning constant exists, and every near candidate already
        // carries another token's meaning; silence beats a discordant feel.
        "warning" -> null
        else -> null
    }

    // A constant newer than the running OS plays nothing, so each one
    // falls back to the nearest older constant (AndroidX compat approach).
    private fun onApi34(constant: Int, fallback: Int): Int =
        if (Build.VERSION_CODES.UPSIDE_DOWN_CAKE <= Build.VERSION.SDK_INT) constant else fallback

    private fun onApi30(constant: Int, fallback: Int): Int =
        if (Build.VERSION_CODES.R <= Build.VERSION.SDK_INT) constant else fallback
}
