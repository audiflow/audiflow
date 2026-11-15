package com.reedom.audiflow_app

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException

/**
 * Handles `audiflow/device_only_store` (Dart `MethodChannelDeviceOnlyStore`).
 *
 * Values are files under `noBackupFilesDir`, which Auto Backup and device
 * transfer never copy, so a restored or new device never inherits them
 * (docs/architecture/user-data-sync.md). Uninstalling the app removes them.
 */
object DeviceOnlyStoreChannel {
    private const val CHANNEL_NAME = "audiflow/device_only_store"
    private const val DIRECTORY = "device_only_store"

    // Keys are fixed identifiers from Dart; anything else could escape the
    // directory, so it is rejected rather than escaped.
    private val KEY_PATTERN = Regex("^[a-z0-9_]{1,64}$")

    fun register(messenger: BinaryMessenger, context: Context) {
        val directory = File(context.noBackupFilesDir, DIRECTORY)
        MethodChannel(messenger, CHANNEL_NAME).setMethodCallHandler { call, result ->
            val key = call.argument<String>("key")
            if (key == null || !KEY_PATTERN.matches(key)) {
                result.error("INVALID_ARGUMENT", "A valid key is required", null)
                return@setMethodCallHandler
            }
            val file = File(directory, key)
            try {
                when (call.method) {
                    "read" -> result.success(if (file.exists()) file.readText() else null)
                    "write" -> {
                        val value = call.argument<String>("value")
                        if (value == null) {
                            result.error("INVALID_ARGUMENT", "value is required", null)
                            return@setMethodCallHandler
                        }
                        write(directory, file, value)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            } catch (e: IOException) {
                result.error("IO", e.message ?: "Device-only store I/O failed", null)
            }
        }
    }

    /** Writes through a temporary file so a crash never leaves a partial id. */
    private fun write(directory: File, file: File, value: String) {
        if (!directory.isDirectory && !directory.mkdirs()) {
            throw IOException("Cannot create ${directory.path}")
        }
        val temp = File(directory, "${file.name}.tmp")
        temp.writeText(value)
        if (!temp.renameTo(file)) {
            temp.delete()
            throw IOException("Cannot replace ${file.path}")
        }
    }
}
