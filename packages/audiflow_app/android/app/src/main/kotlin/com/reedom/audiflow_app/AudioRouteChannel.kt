package com.reedom.audiflow_app

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.os.Build
import android.provider.Settings
import androidx.mediarouter.app.SystemOutputSwitcherDialogController
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference

/**
 * Handles `audiflow/audio_route`: opens the system media output switcher.
 *
 * The androidx helper picks the right entry point per API level (public
 * MediaRouter2 API on 34+, SystemUI broadcast on 31-33, Settings panel on
 * 30) and verifies a system component handles it, so no hidden intents are
 * hard-coded here.
 */
object AudioRouteChannel {
    private const val CHANNEL_NAME = "audiflow/audio_route"

    fun register(messenger: BinaryMessenger, activity: Activity) {
        // audio_service caches the engine beyond the activity's lifetime, so
        // a strong reference here would leak a destroyed MainActivity.
        val activityRef = WeakReference(activity)
        MethodChannel(messenger, CHANNEL_NAME).setMethodCallHandler { call, result ->
            when (call.method) {
                "isPickerAvailable" -> result.success(isPickerAvailable())
                "showPicker" -> {
                    val current = activityRef.get()?.takeUnless { it.isFinishing }
                    result.success(current != null && showPicker(current))
                }
                else -> result.notImplemented()
            }
        }
    }

    // Android 8-10 has no output switcher; the Flutter side hides the
    // button there rather than offer a Bluetooth-only settings screen.
    private fun isPickerAvailable(): Boolean =
        Build.VERSION_CODES.R <= Build.VERSION.SDK_INT

    private fun showPicker(activity: Activity): Boolean {
        if (SystemOutputSwitcherDialogController.showDialog(activity)) return true
        // OEMs that removed the SystemUI dialog still have Bluetooth
        // settings, which at least lets the user switch headsets.
        return try {
            activity.startActivity(Intent(Settings.ACTION_BLUETOOTH_SETTINGS))
            true
        } catch (e: ActivityNotFoundException) {
            false
        }
    }
}
