package com.reedom.audiflow_app

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference

/**
 * Handles `com.reedom.audiflow_app/document_picker`: opens the Storage Access
 * Framework picker filtered by exact MIME types and returns the chosen URI.
 *
 * Exists because file_picker only accepts extensions, which it maps through
 * `MimeTypeMap`; that cannot express the types Drive reports for `.opml`.
 * The caller reads the URI over the content resolver channel, on a background
 * thread, so a slow provider never blocks the main thread here.
 */
object DocumentPickerChannel {
    private const val CHANNEL_NAME = "com.reedom.audiflow_app/document_picker"

    // Distinct from file_picker's 0x4F50 and 0x4F51.
    private const val REQUEST_CODE = 0x4F52

    // Held here, not on the activity: audio_service caches the engine beyond
    // the activity's lifetime, so a recreated activity must still be able to
    // answer the Dart call that the previous one started.
    private var pendingResult: MethodChannel.Result? = null

    fun register(messenger: BinaryMessenger, activity: Activity) {
        // The cached engine would otherwise leak a destroyed MainActivity.
        val activityRef = WeakReference(activity)
        MethodChannel(messenger, CHANNEL_NAME).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickDocument" -> {
                    val mimeTypes = (call.arguments as? List<*>)?.filterIsInstance<String>()
                    if (mimeTypes.isNullOrEmpty()) {
                        result.error("INVALID_ARGUMENT", "MIME types are required", null)
                        return@setMethodCallHandler
                    }
                    pick(activityRef.get(), mimeTypes, result)
                }
                else -> result.notImplemented()
            }
        }
    }

    /** Returns whether [requestCode] belonged to this channel. */
    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_CODE) return false
        val result = pendingResult ?: return true
        pendingResult = null
        val uri = if (resultCode == Activity.RESULT_OK) data?.data else null
        result.success(uri?.toString())
        return true
    }

    private fun pick(activity: Activity?, mimeTypes: List<String>, result: MethodChannel.Result) {
        if (activity == null) {
            result.error("NO_ACTIVITY", "No activity to present the picker", null)
            return
        }
        // Reaching here with a call still pending means its picker result was
        // lost, for example with its activity. Answer it as cancelled rather
        // than refuse this pick; the screen that started it has since gone.
        pendingResult?.success(null)
        pendingResult = result

        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "*/*"
            putExtra(Intent.EXTRA_MIME_TYPES, mimeTypes.toTypedArray())
        }
        try {
            activity.startActivityForResult(intent, REQUEST_CODE)
        } catch (e: ActivityNotFoundException) {
            pendingResult = null
            result.error("PICKER_UNAVAILABLE", e.message, null)
        }
    }
}
