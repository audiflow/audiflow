package com.reedom.audiflow_app

import android.net.Uri
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

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
