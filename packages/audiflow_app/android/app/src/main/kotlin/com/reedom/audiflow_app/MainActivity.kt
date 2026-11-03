package com.reedom.audiflow_app

import android.content.Intent
import android.net.Uri
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.io.InputStream

// Far above any real OPML file, and low enough that "Show all files" picking a
// video or backup fails on its own rather than pressuring audio playback in
// the same process. The iOS read in opml_file_picker.dart uses the same limit.
private const val MAX_CONTENT_URI_BYTES = 16 * 1024 * 1024

private fun InputStream.readTextWithin(maxBytes: Int): String {
    val out = ByteArrayOutputStream()
    val chunk = ByteArray(DEFAULT_BUFFER_SIZE)
    while (true) {
        val read = read(chunk)
        if (read < 0) break
        if (maxBytes - out.size() < read) throw IOException("File is too large to read")
        out.write(chunk, 0, read)
    }
    return out.toString(Charsets.UTF_8.name())
}

class MainActivity : AudioServiceActivity() {
    @Deprecated("FlutterActivity is not a ComponentActivity, so this is the only result hook.")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (DocumentPickerChannel.onActivityResult(requestCode, resultCode, data)) return
        @Suppress("DEPRECATION")
        super.onActivityResult(requestCode, resultCode, data)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        AudioRouteChannel.register(flutterEngine.dartExecutor.binaryMessenger, this)
        HapticsChannel.register(flutterEngine.dartExecutor.binaryMessenger, this)
        DocumentPickerChannel.register(flutterEngine.dartExecutor.binaryMessenger, this)
        SessionQueueChannel.register(flutterEngine.dartExecutor.binaryMessenger)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.reedom.audiflow_app/content_resolver",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "readContentUri" -> {
                    val uriString = call.arguments as? String
                    if (uriString == null) {
                        result.error("INVALID_ARGUMENT", "URI is required", null)
                        return@setMethodCallHandler
                    }
                    Thread {
                        try {
                            val uri = Uri.parse(uriString)
                            val content = contentResolver.openInputStream(uri)?.use {
                                it.readTextWithin(MAX_CONTENT_URI_BYTES)
                            }
                            if (content != null) {
                                runOnUiThread { result.success(content) }
                            } else {
                                runOnUiThread {
                                    result.error("READ_FAILED", "Could not read URI", null)
                                }
                            }
                        } catch (e: OutOfMemoryError) {
                            // A last resort: the size limit should stop the read
                            // first, unless memory is already short.
                            val message = "File is too large to read"
                            runOnUiThread { result.error("READ_FAILED", message, null) }
                        } catch (e: Exception) {
                            val message = e.message
                                ?: "Failed to read URI: ${e::class.java.simpleName}"
                            runOnUiThread { result.error("READ_FAILED", message, null) }
                        }
                    }.start()
                }
                else -> result.notImplemented()
            }
        }
    }
}
