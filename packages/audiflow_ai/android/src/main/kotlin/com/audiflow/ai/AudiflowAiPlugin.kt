// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

package com.audiflow.ai

import android.content.Context
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * AudiflowAiPlugin handles platform channel communication for on-device AI features.
 *
 * This plugin provides access to ML Kit GenAI APIs for text generation and summarization
 * on supported Android devices.
 */
class AudiflowAiPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    companion object {
        private const val CHANNEL_NAME = "com.audiflow/ai"

        // Method names
        private const val METHOD_CHECK_CAPABILITY = "checkCapability"
        private const val METHOD_INITIALIZE = "initialize"
        private const val METHOD_GENERATE_TEXT = "generateText"
        private const val METHOD_DISPOSE = "dispose"
        private const val METHOD_PROMPT_AICORE_INSTALL = "promptAiCoreInstall"

        // Response keys
        private const val KEY_STATUS = "status"
        private const val KEY_TEXT = "text"
        private const val KEY_TOKEN_COUNT = "tokenCount"
        private const val KEY_DURATION_MS = "durationMs"
        private const val KEY_SUCCESS = "success"
        private const val KEY_ERROR_CODE = "errorCode"
        private const val KEY_ERROR_MESSAGE = "errorMessage"

        // Status values
        private const val STATUS_FULL = "full"
        private const val STATUS_LIMITED = "limited"
        private const val STATUS_UNAVAILABLE = "unavailable"
        private const val STATUS_NEEDS_SETUP = "needsSetup"

        // AICore Play Store URL
        private const val AICORE_PACKAGE = "com.google.android.aicore"
        private const val PLAY_STORE_URL = "market://details?id=$AICORE_PACKAGE"
        private const val PLAY_STORE_WEB_URL =
            "https://play.google.com/store/apps/details?id=$AICORE_PACKAGE"
    }

    private var isInitialized = false

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            METHOD_CHECK_CAPABILITY -> handleCheckCapability(result)
            METHOD_INITIALIZE -> handleInitialize(call, result)
            METHOD_GENERATE_TEXT -> handleGenerateText(call, result)
            METHOD_DISPOSE -> handleDispose(result)
            METHOD_PROMPT_AICORE_INSTALL -> handlePromptAiCoreInstall(result)
            else -> result.notImplemented()
        }
    }

    /**
     * Check AI capability on this device.
     *
     * Returns status indicating whether AI is available, needs setup, or is unavailable.
     * This is a stub that returns unavailable - will be implemented with ML Kit in Phase 2.
     */
    private fun handleCheckCapability(result: Result) {
        // Stub implementation - returns unavailable until ML Kit integration in Phase 2
        // TODO: Query ML Kit FeatureStatus API
        result.success(
            mapOf(
                KEY_STATUS to STATUS_UNAVAILABLE
            )
        )
    }

    /**
     * Initialize the AI engine with optional system instructions.
     *
     * This is a stub that returns an error - will be implemented with ML Kit in Phase 2.
     */
    private fun handleInitialize(call: MethodCall, result: Result) {
        val instructions = call.argument<String>("instructions")

        // Stub implementation - returns error until ML Kit integration in Phase 2
        // TODO: Initialize ML Kit GenerativeModel
        result.error(
            "AI_NOT_AVAILABLE",
            "AI is not available on this device (stub implementation)",
            null
        )
    }

    /**
     * Generate text from a prompt.
     *
     * This is a stub that returns an error - will be implemented with ML Kit in Phase 2.
     */
    private fun handleGenerateText(call: MethodCall, result: Result) {
        if (!isInitialized) {
            result.error(
                "AI_NOT_INITIALIZED",
                "AI engine not initialized. Call initialize() first.",
                null
            )
            return
        }

        val prompt = call.argument<String>("prompt")
        if (prompt.isNullOrEmpty()) {
            result.error(
                "INVALID_ARGUMENT",
                "Prompt cannot be empty",
                null
            )
            return
        }

        // Stub implementation - will be implemented with ML Kit in Phase 2
        // TODO: Invoke ML Kit Prompt API
        result.error(
            "AI_NOT_AVAILABLE",
            "AI is not available on this device (stub implementation)",
            null
        )
    }

    /**
     * Release native resources.
     */
    private fun handleDispose(result: Result) {
        isInitialized = false
        // TODO: Release ML Kit resources in Phase 2
        result.success(mapOf(KEY_SUCCESS to true))
    }

    /**
     * Open the Play Store to install AICore.
     */
    private fun handlePromptAiCoreInstall(result: Result) {
        try {
            // Try to open Play Store app first
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(PLAY_STORE_URL)).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

            try {
                context.startActivity(intent)
                result.success(true)
            } catch (e: android.content.ActivityNotFoundException) {
                // Fall back to web Play Store
                val webIntent = Intent(Intent.ACTION_VIEW, Uri.parse(PLAY_STORE_WEB_URL)).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                context.startActivity(webIntent)
                result.success(true)
            }
        } catch (e: Exception) {
            result.success(false)
        }
    }
}
