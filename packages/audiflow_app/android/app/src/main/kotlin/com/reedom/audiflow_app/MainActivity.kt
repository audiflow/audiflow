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
                    try {
                        val uri = Uri.parse(uriString)
                        val content = contentResolver.openInputStream(uri)?.use {
                            it.bufferedReader().readText()
                        }
                        if (content != null) {
                            result.success(content)
                        } else {
                            result.error("READ_FAILED", "Could not read URI", null)
                        }
                    } catch (e: Exception) {
                        result.error("READ_FAILED", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
