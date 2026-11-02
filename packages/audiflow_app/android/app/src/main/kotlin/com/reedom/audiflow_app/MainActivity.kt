package com.reedom.audiflow_app

import android.content.Intent
import android.net.Uri
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

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
                                it.bufferedReader().readText()
                            }
                            if (content != null) {
                                runOnUiThread { result.success(content) }
                            } else {
                                runOnUiThread {
                                    result.error("READ_FAILED", "Could not read URI", null)
                                }
                            }
                        } catch (e: OutOfMemoryError) {
                            // "Show all files" lets the user pick a large video
                            // or backup; report it instead of crashing.
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
