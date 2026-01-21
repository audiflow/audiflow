// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

package com.audiflow.ai

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import com.google.mlkit.genai.prompt.FeatureStatus
import com.google.mlkit.genai.prompt.GenerateContentRequest
import com.google.mlkit.genai.prompt.GenerativeModel
import com.google.mlkit.genai.prompt.Generation
import com.google.mlkit.genai.prompt.GenAiException
import com.google.mlkit.genai.prompt.TextPart
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

/**
 * AudiflowAiPlugin handles platform channel communication for on-device AI features.
 *
 * This plugin provides access to ML Kit GenAI APIs for text generation and summarization
 * on supported Android devices (Pixel 8+, Honor Magic 6+, Samsung Galaxy 25+).
 *
 * ## Task Coverage
 * - Task 4.1: Capability detection (query AICore, map FeatureStatus, detect error -101)
 * - Task 4.2: Initialization and lifecycle (GenerativeModel, dispose, reinitialization)
 * - Task 4.3: Text generation (Prompt API, GenerationConfig, error handling)
 */
class AudiflowAiPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var generativeModel: GenerativeModel? = null
    private var systemInstructions: String? = null
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    companion object {
        private const val TAG = "AudiflowAiPlugin"
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

        // Status values matching Dart AiCapability enum
        private const val STATUS_FULL = "full"
        private const val STATUS_UNAVAILABLE = "unavailable"
        private const val STATUS_NEEDS_SETUP = "needsSetup"

        // Error codes
        private const val ERROR_AI_NOT_AVAILABLE = "AI_NOT_AVAILABLE"
        private const val ERROR_AI_NOT_INITIALIZED = "AI_NOT_INITIALIZED"
        private const val ERROR_AICORE_REQUIRED = "AICORE_REQUIRED"
        private const val ERROR_GENERATION_FAILED = "AI_GENERATION_FAILED"
        private const val ERROR_PROMPT_TOO_LONG = "PROMPT_TOO_LONG"
        private const val ERROR_INVALID_ARGUMENT = "INVALID_ARGUMENT"

        // AICore error code indicating not installed
        private const val AICORE_NOT_INSTALLED_ERROR_CODE = -101

        // AICore Play Store URL
        private const val AICORE_PACKAGE = "com.google.android.aicore"
        private const val PLAY_STORE_URL = "market://details?id=$AICORE_PACKAGE"
        private const val PLAY_STORE_WEB_URL =
            "https://play.google.com/store/apps/details?id=$AICORE_PACKAGE"

        // Default generation config
        private const val DEFAULT_TEMPERATURE = 0.7f
        private const val DEFAULT_MAX_OUTPUT_TOKENS = 256

        /**
         * Maps ML Kit FeatureStatus to capability string for platform channel.
         *
         * This matches the Dart AiCapability enum values:
         * - full: AI is fully available
         * - needsSetup: AICore needs to be installed or model downloaded
         * - unavailable: Device does not support on-device AI
         */
        internal fun mapFeatureStatusToCapability(status: Int): String = when (status) {
            FeatureStatus.AVAILABLE -> STATUS_FULL
            FeatureStatus.DOWNLOADABLE -> STATUS_NEEDS_SETUP
            FeatureStatus.DOWNLOADING -> STATUS_NEEDS_SETUP
            FeatureStatus.UNAVAILABLE -> STATUS_UNAVAILABLE
            else -> STATUS_UNAVAILABLE
        }

        /**
         * Validates system instructions string.
         *
         * @param instructions The system instructions or null
         * @return true if valid (null or non-blank), false if empty/blank
         */
        internal fun isValidSystemInstructions(instructions: String?): Boolean =
            instructions == null || instructions.isNotBlank()

        /**
         * Checks if an error indicates AICore is not installed.
         *
         * Error code -101 specifically indicates AICore is not installed on the device.
         *
         * @param errorCode The error code to check
         * @return true if the error indicates AICore is not installed
         */
        internal fun isAiCoreNotInstalledError(errorCode: Int): Boolean =
            errorCode == AICORE_NOT_INSTALLED_ERROR_CODE
    }

    /**
     * Holds parsed generation configuration.
     */
    internal data class ParsedGenerationConfig(
        val temperature: Float,
        val maxOutputTokens: Int?
    )

    /**
     * The current initialization state.
     */
    private val isInitialized: Boolean
        get() = generativeModel != null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
        Log.d(TAG, "Plugin attached to engine")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        disposeResources()
        scope.cancel()
        Log.d(TAG, "Plugin detached from engine")
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
     * Task 4.1: Check AI capability on this device.
     *
     * Queries AICore availability using ML Kit FeatureStatus API.
     * Maps the status to AiCapability enum values for the Dart layer.
     *
     * ## Status Mapping
     * - AVAILABLE -> full
     * - DOWNLOADABLE -> needsSetup
     * - DOWNLOADING -> needsSetup
     * - UNAVAILABLE -> unavailable
     *
     * ## Error Handling
     * - Error code -101: Returns needsSetup (AICore not installed)
     * - Other errors: Returns unavailable
     */
    private fun handleCheckCapability(result: Result) {
        scope.launch {
            try {
                val model = Generation.getClient()
                val status = model.checkStatus()

                Log.d(TAG, "Feature status: $status")

                val capability = mapFeatureStatusToCapability(status)
                result.success(mapOf(KEY_STATUS to capability))

            } catch (e: Exception) {
                Log.e(TAG, "Error checking capability", e)

                // Check for AICore not installed error (-101)
                val errorCode = extractErrorCode(e)
                if (isAiCoreNotInstalledError(errorCode)) {
                    result.success(mapOf(KEY_STATUS to STATUS_NEEDS_SETUP))
                    return@launch
                }

                // For other errors, return unavailable
                result.success(mapOf(KEY_STATUS to STATUS_UNAVAILABLE))
            }
        }
    }

    /**
     * Task 4.2: Initialize the AI engine with optional system instructions.
     *
     * Creates a new GenerativeModel instance. If already initialized, disposes
     * the existing model first (supports reinitialization).
     *
     * ## Parameters
     * - instructions: Optional system instructions for the model
     *
     * ## Error Handling
     * - Empty system instructions: Returns INVALID_ARGUMENT error
     * - AICore not installed: Returns AICORE_REQUIRED error
     * - Device not supported: Returns AI_NOT_AVAILABLE error
     */
    private fun handleInitialize(call: MethodCall, result: Result) {
        val instructions = call.argument<String>("instructions")

        // Validate system instructions (null is ok, empty is not)
        if (!isValidSystemInstructions(instructions)) {
            result.error(
                ERROR_INVALID_ARGUMENT,
                "System instructions cannot be empty",
                null
            )
            return
        }

        scope.launch {
            try {
                // Support reinitialization: dispose existing model first
                if (isInitialized) {
                    Log.d(TAG, "Reinitializing: disposing existing model")
                    disposeResources()
                }

                // Check feature status before initialization
                val model = Generation.getClient()
                val status = model.checkStatus()

                when (status) {
                    FeatureStatus.UNAVAILABLE -> {
                        result.error(
                            ERROR_AI_NOT_AVAILABLE,
                            "On-device AI is not available on this device",
                            null
                        )
                        return@launch
                    }
                    FeatureStatus.DOWNLOADABLE, FeatureStatus.DOWNLOADING -> {
                        result.error(
                            ERROR_AICORE_REQUIRED,
                            "Google AICore model needs to be downloaded. Call promptAiCoreInstall().",
                            null
                        )
                        return@launch
                    }
                    FeatureStatus.AVAILABLE -> {
                        // Model is available, continue with initialization
                    }
                }

                // Store the model and instructions
                generativeModel = model
                systemInstructions = instructions

                Log.d(TAG, "Initialization successful")
                result.success(mapOf(KEY_SUCCESS to true))

            } catch (e: Exception) {
                Log.e(TAG, "Initialization failed", e)

                // Check for AICore not installed error
                val errorCode = extractErrorCode(e)
                if (isAiCoreNotInstalledError(errorCode)) {
                    result.error(
                        ERROR_AICORE_REQUIRED,
                        "Google AICore is required. Call promptAiCoreInstall().",
                        mapOf("errorCode" to errorCode)
                    )
                    return@launch
                }

                result.error(
                    ERROR_AI_NOT_AVAILABLE,
                    "Failed to initialize AI: ${e.message}",
                    null
                )
            }
        }
    }

    /**
     * Task 4.3: Generate text from a prompt.
     *
     * Invokes ML Kit Prompt API with the given prompt and configuration.
     * Returns generated text along with metadata (token count, duration).
     *
     * ## Parameters
     * - prompt: The text prompt for generation
     * - config: Optional generation configuration (temperature, maxOutputTokens)
     *
     * ## Response
     * - text: Generated text
     * - tokenCount: Number of tokens in response (if available)
     * - durationMs: Generation duration in milliseconds
     *
     * ## Error Handling
     * - Not initialized: Returns AI_NOT_INITIALIZED error
     * - Empty prompt: Returns INVALID_ARGUMENT error
     * - Prompt too long: Returns PROMPT_TOO_LONG error
     * - Generation failure: Returns AI_GENERATION_FAILED error
     */
    private fun handleGenerateText(call: MethodCall, result: Result) {
        // Verify initialization
        val model = generativeModel
        if (model == null) {
            result.error(
                ERROR_AI_NOT_INITIALIZED,
                "AI engine not initialized. Call initialize() first.",
                null
            )
            return
        }

        // Validate prompt
        val prompt = call.argument<String>("prompt")
        if (prompt.isNullOrEmpty()) {
            result.error(
                ERROR_INVALID_ARGUMENT,
                "Prompt cannot be empty",
                null
            )
            return
        }

        // Parse generation config
        val configMap = call.argument<Map<String, Any>>("config")
        val config = parseGenerationConfig(configMap)

        scope.launch {
            val startTime = System.currentTimeMillis()

            try {
                // Build the generation request with system instructions and config
                val fullPrompt = buildFullPrompt(prompt)
                val request = buildGenerationRequest(fullPrompt, config)

                // Generate content
                val response = model.generateContent(request)

                val durationMs = System.currentTimeMillis() - startTime
                val generatedText = response.candidates?.firstOrNull()?.text ?: ""

                Log.d(TAG, "Generation completed in ${durationMs}ms")

                result.success(
                    mapOf(
                        KEY_TEXT to generatedText,
                        KEY_DURATION_MS to durationMs.toInt()
                    )
                )

            } catch (e: GenAiException) {
                Log.e(TAG, "Generation failed", e)
                handleGenerationError(e, result)

            } catch (e: Exception) {
                Log.e(TAG, "Unexpected error during generation", e)
                result.error(
                    ERROR_GENERATION_FAILED,
                    "Text generation failed: ${e.message}",
                    null
                )
            }
        }
    }

    /**
     * Task 4.2: Release native resources.
     *
     * Disposes the GenerativeModel and resets initialization state.
     * Safe to call multiple times.
     */
    private fun handleDispose(result: Result) {
        disposeResources()
        Log.d(TAG, "Resources disposed")
        result.success(mapOf(KEY_SUCCESS to true))
    }

    /**
     * Task 4.1: Open the Play Store to install AICore.
     *
     * First attempts to open the Play Store app, falls back to web browser
     * if Play Store is not available.
     */
    private fun handlePromptAiCoreInstall(result: Result) {
        try {
            // Try to open Play Store app first
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(PLAY_STORE_URL)).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

            try {
                context.startActivity(intent)
                Log.d(TAG, "Opened Play Store for AICore")
                result.success(true)
            } catch (e: android.content.ActivityNotFoundException) {
                // Fall back to web Play Store
                val webIntent = Intent(Intent.ACTION_VIEW, Uri.parse(PLAY_STORE_WEB_URL)).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                context.startActivity(webIntent)
                Log.d(TAG, "Opened web Play Store for AICore")
                result.success(true)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to open AICore install page", e)
            result.success(false)
        }
    }

    /**
     * Disposes all native resources.
     */
    private fun disposeResources() {
        generativeModel?.close()
        generativeModel = null
        systemInstructions = null
    }

    /**
     * Builds the full prompt including system instructions.
     */
    private fun buildFullPrompt(userPrompt: String): String {
        return if (!systemInstructions.isNullOrBlank()) {
            "$systemInstructions\n\n$userPrompt"
        } else {
            userPrompt
        }
    }

    /**
     * Builds a GenerateContentRequest with the given prompt and config.
     */
    private fun buildGenerationRequest(
        prompt: String,
        config: ParsedGenerationConfig
    ): GenerateContentRequest {
        return GenerateContentRequest.Builder(TextPart(prompt)).apply {
            setTemperature(config.temperature)
            config.maxOutputTokens?.let { setMaxOutputTokens(it) }
        }.build()
    }

    /**
     * Parses generation config from platform channel arguments.
     *
     * @param config Map containing temperature and maxOutputTokens
     * @return Parsed configuration with defaults applied
     */
    internal fun parseGenerationConfig(config: Map<String, Any>?): ParsedGenerationConfig {
        if (config == null) {
            return ParsedGenerationConfig(DEFAULT_TEMPERATURE, null)
        }

        val temperature = when (val temp = config["temperature"]) {
            is Double -> temp.toFloat()
            is Float -> temp
            is Number -> temp.toFloat()
            else -> DEFAULT_TEMPERATURE
        }

        val maxOutputTokens = when (val max = config["maxOutputTokens"]) {
            is Int -> max
            is Number -> max.toInt()
            else -> null
        }

        return ParsedGenerationConfig(temperature, maxOutputTokens)
    }

    /**
     * Handles GenAiException and maps to appropriate error codes.
     */
    private fun handleGenerationError(e: GenAiException, result: Result) {
        val message = e.message ?: "Unknown generation error"

        // Check for prompt too long error
        if (message.contains("too long", ignoreCase = true) ||
            message.contains("token limit", ignoreCase = true) ||
            message.contains("exceeds", ignoreCase = true)
        ) {
            result.error(
                ERROR_PROMPT_TOO_LONG,
                "Prompt exceeds maximum length",
                mapOf("maxTokens" to DEFAULT_MAX_OUTPUT_TOKENS * 16) // Approximate input limit
            )
            return
        }

        result.error(
            ERROR_GENERATION_FAILED,
            message,
            null
        )
    }

    /**
     * Extracts error code from exception if available.
     */
    private fun extractErrorCode(e: Exception): Int {
        // Try to extract error code from exception message or cause
        val message = e.message ?: return 0

        // Look for error code pattern in message
        val codeMatch = Regex("code[:\\s]*(-?\\d+)").find(message)
        if (codeMatch != null) {
            return codeMatch.groupValues[1].toIntOrNull() ?: 0
        }

        // Check cause chain
        var cause = e.cause
        while (cause != null) {
            val causeMessage = cause.message ?: ""
            val causeCodeMatch = Regex("code[:\\s]*(-?\\d+)").find(causeMessage)
            if (causeCodeMatch != null) {
                return causeCodeMatch.groupValues[1].toIntOrNull() ?: 0
            }
            cause = cause.cause
        }

        return 0
    }
}
