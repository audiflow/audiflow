// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

import Flutter
import UIKit

#if canImport(FoundationModels)
import FoundationModels
#endif

/// AudiflowAiPlugin handles platform channel communication for on-device AI features.
///
/// This plugin provides access to Apple Foundation Models for text generation
/// and summarization on supported iOS devices (iOS 26+, iPhone 15 Pro+).
///
/// ## Task Coverage
/// - Task 5.1: Capability detection (SystemLanguageModel.default.availability)
/// - Task 5.2: Initialization and lifecycle (LanguageModelSession, dispose, reinitialization)
/// - Task 5.3: Text generation (LanguageModelSession.respond(to:), GenerationConfig mapping)
public class AudiflowAiPlugin: NSObject, FlutterPlugin {
    // MARK: - Constants

    private static let channelName = "com.audiflow/ai"

    // Method names
    private static let methodCheckCapability = "checkCapability"
    private static let methodInitialize = "initialize"
    private static let methodGenerateText = "generateText"
    private static let methodDispose = "dispose"
    private static let methodPromptAiCoreInstall = "promptAiCoreInstall"
    private static let methodResolveSettingsIntent = "resolveSettingsIntent"

    // Response keys
    private static let keyStatus = "status"
    private static let keyText = "text"
    private static let keyTokenCount = "tokenCount"
    private static let keyDurationMs = "durationMs"
    private static let keySuccess = "success"
    private static let keyErrorCode = "errorCode"
    private static let keyErrorMessage = "errorMessage"

    // Status values matching Dart AiCapability enum
    private static let statusFull = "full"
    private static let statusLimited = "limited"
    private static let statusUnavailable = "unavailable"
    private static let statusNeedsSetup = "needsSetup"

    // Error codes
    private static let errorAiNotAvailable = "AI_NOT_AVAILABLE"
    private static let errorAiNotInitialized = "AI_NOT_INITIALIZED"
    private static let errorGenerationFailed = "AI_GENERATION_FAILED"
    private static let errorPromptTooLong = "PROMPT_TOO_LONG"
    private static let errorInvalidArgument = "INVALID_ARGUMENT"

    // Default generation config
    private static let defaultTemperature: Double = 0.7
    private static let defaultMaxOutputTokens: Int = 256

    // MARK: - Properties

    /// Type-erased storage for LanguageModelSession (iOS 26+).
    /// Access via the `session` computed property which handles availability.
    private var _sessionStorage: Any?

    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private var session: LanguageModelSession? {
        get { _sessionStorage as? LanguageModelSession }
        set { _sessionStorage = newValue }
    }
    #endif

    /// The system instructions for the current session.
    private var systemInstructions: String?

    /// Whether the plugin is initialized and ready for generation.
    private var isInitialized: Bool = false

    // MARK: - Plugin Registration

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: registrar.messenger()
        )
        let instance = AudiflowAiPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    // MARK: - Method Call Handler

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case AudiflowAiPlugin.methodCheckCapability:
            handleCheckCapability(result: result)

        case AudiflowAiPlugin.methodInitialize:
            handleInitialize(call: call, result: result)

        case AudiflowAiPlugin.methodGenerateText:
            handleGenerateText(call: call, result: result)

        case AudiflowAiPlugin.methodDispose:
            handleDispose(result: result)

        case AudiflowAiPlugin.methodPromptAiCoreInstall:
            // Not applicable on iOS - AICore is Android-specific
            result(false)

        case AudiflowAiPlugin.methodResolveSettingsIntent:
            handleResolveSettingsIntent(call: call, result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Task 5.1: Capability Detection

    /// Check AI capability on this device.
    ///
    /// Queries SystemLanguageModel.default.availability to determine if Foundation Models
    /// is available on this device.
    ///
    /// ## Status Mapping
    /// - .available -> full
    /// - .unavailable(reason) -> unavailable (with reason in details)
    ///
    /// ## Requirements Coverage
    /// - Req 1.3: iOS device running iOS 26+ returns full capability
    /// - Req 1.5: Device not meeting requirements returns unavailable
    /// - Req 8.4: Verify Foundation Models availability
    private func handleCheckCapability(result: @escaping FlutterResult) {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            let availability = SystemLanguageModel.default.availability

            switch availability {
            case .available:
                result([AudiflowAiPlugin.keyStatus: AudiflowAiPlugin.statusFull])

            case .unavailable(_):
                let details = mapUnavailabilityReason(availability)
                result([
                    AudiflowAiPlugin.keyStatus: AudiflowAiPlugin.statusUnavailable,
                    AudiflowAiPlugin.keyErrorMessage: details
                ])

            @unknown default:
                result([AudiflowAiPlugin.keyStatus: AudiflowAiPlugin.statusUnavailable])
            }
        } else {
            // iOS version below 26
            result([
                AudiflowAiPlugin.keyStatus: AudiflowAiPlugin.statusUnavailable,
                AudiflowAiPlugin.keyErrorMessage: "iOS 26 or later is required for on-device AI"
            ])
        }
        #else
        // Foundation Models framework not available (older SDK)
        result([
            AudiflowAiPlugin.keyStatus: AudiflowAiPlugin.statusUnavailable,
            AudiflowAiPlugin.keyErrorMessage: "Foundation Models framework not available"
        ])
        #endif
    }

    // MARK: - Task 5.2: Initialization and Lifecycle

    /// Initialize the AI engine with optional system instructions.
    ///
    /// Creates a new LanguageModelSession. If already initialized, disposes
    /// the existing session first (supports reinitialization).
    ///
    /// ## Parameters
    /// - instructions: Optional system instructions for the model
    ///
    /// ## Error Handling
    /// - Empty system instructions: Returns INVALID_ARGUMENT error
    /// - Device not supported: Returns AI_NOT_AVAILABLE error
    /// - Session creation failure: Returns AI_NOT_AVAILABLE with details
    ///
    /// ## Requirements Coverage
    /// - Req 2.1: Initialize with default system instructions
    /// - Req 2.2: Initialize with custom system instructions
    /// - Req 2.3: Throw AiNotAvailableException if platform not supported
    /// - Req 2.5: Reinitialize with new configuration
    /// - Req 8.3: Initialize Foundation Models framework
    /// - Req 8.9: Proper memory management
    private func handleInitialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]
        let instructions = args?["instructions"] as? String

        // Validate system instructions (null is ok, empty is not)
        if let inst = instructions, inst.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            result(FlutterError(
                code: AudiflowAiPlugin.errorInvalidArgument,
                message: "System instructions cannot be empty",
                details: nil
            ))
            return
        }

        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            // Check availability before initialization
            let availability = SystemLanguageModel.default.availability
            guard case .available = availability else {
                let reason = mapUnavailabilityReason(availability)
                result(FlutterError(
                    code: AudiflowAiPlugin.errorAiNotAvailable,
                    message: reason,
                    details: nil
                ))
                return
            }

            // Support reinitialization: dispose existing session first
            if isInitialized {
                disposeResources()
            }

            do {
                // Create session with system instructions if provided
                if let instructions = instructions {
                    session = LanguageModelSession(instructions: instructions)
                } else {
                    session = LanguageModelSession()
                }

                systemInstructions = instructions
                isInitialized = true

                result([AudiflowAiPlugin.keySuccess: true])
            } catch {
                result(FlutterError(
                    code: AudiflowAiPlugin.errorAiNotAvailable,
                    message: "Failed to initialize AI: \(error.localizedDescription)",
                    details: nil
                ))
            }
        } else {
            result(FlutterError(
                code: AudiflowAiPlugin.errorAiNotAvailable,
                message: "iOS 26 or later is required for on-device AI",
                details: nil
            ))
        }
        #else
        result(FlutterError(
            code: AudiflowAiPlugin.errorAiNotAvailable,
            message: "Foundation Models framework not available",
            details: nil
        ))
        #endif
    }

    // MARK: - Task 5.3: Text Generation

    /// Generate text from a prompt.
    ///
    /// Invokes LanguageModelSession.respond(to:) with the given prompt and configuration.
    /// Returns generated text along with metadata (duration).
    ///
    /// ## Parameters
    /// - prompt: The text prompt for generation
    /// - config: Optional generation configuration (temperature, maxOutputTokens)
    ///
    /// ## Response
    /// - text: Generated text
    /// - durationMs: Generation duration in milliseconds
    ///
    /// ## Error Handling
    /// - Not initialized: Returns AI_NOT_INITIALIZED error
    /// - Empty prompt: Returns INVALID_ARGUMENT error
    /// - Generation failure: Returns AI_GENERATION_FAILED error
    ///
    /// ## Requirements Coverage
    /// - Req 3.1: Generate text with valid prompt returns AiResponse
    /// - Req 3.2: Apply GenerationConfig parameters
    /// - Req 3.5: Handle generation errors with AiGenerationException
    /// - Req 8.5: Invoke LanguageModelSession.respond(to:)
    /// - Req 8.6: Use summarization-optimized prompts when appropriate
    private func handleGenerateText(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Verify initialization
        guard isInitialized else {
            result(FlutterError(
                code: AudiflowAiPlugin.errorAiNotInitialized,
                message: "AI engine not initialized. Call initialize() first.",
                details: nil
            ))
            return
        }

        // Validate prompt
        guard let args = call.arguments as? [String: Any],
              let prompt = args["prompt"] as? String,
              !prompt.isEmpty else {
            result(FlutterError(
                code: AudiflowAiPlugin.errorInvalidArgument,
                message: "Prompt cannot be empty",
                details: nil
            ))
            return
        }

        // Parse generation config
        let configMap = args["config"] as? [String: Any]
        let config = parseGenerationConfig(configMap)

        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            guard let currentSession = session else {
                result(FlutterError(
                    code: AudiflowAiPlugin.errorAiNotInitialized,
                    message: "AI session not available. Call initialize() first.",
                    details: nil
                ))
                return
            }

            // Execute generation asynchronously
            Task {
                let startTime = CFAbsoluteTimeGetCurrent()

                do {
                    // Build generation options from config
                    let generationOptions = buildGenerationOptions(from: config)

                    // Generate response using LanguageModelSession
                    let sessionResponse: LanguageModelSession.Response<String>
                    if let options = generationOptions {
                        sessionResponse = try await currentSession.respond(to: prompt, options: options)
                    } else {
                        sessionResponse = try await currentSession.respond(to: prompt)
                    }

                    // Extract the content string from the response
                    let response = sessionResponse.content

                    let durationMs = Int((CFAbsoluteTimeGetCurrent() - startTime) * 1000)

                    // Return result on main thread
                    DispatchQueue.main.async {
                        result([
                            AudiflowAiPlugin.keyText: response,
                            AudiflowAiPlugin.keyDurationMs: durationMs
                        ])
                    }
                } catch let error as LanguageModelSession.GenerationError {
                    DispatchQueue.main.async {
                        self.handleGenerationError(error, result: result)
                    }
                } catch {
                    DispatchQueue.main.async {
                        result(FlutterError(
                            code: AudiflowAiPlugin.errorGenerationFailed,
                            message: "Text generation failed: \(error.localizedDescription)",
                            details: nil
                        ))
                    }
                }
            }
        } else {
            result(FlutterError(
                code: AudiflowAiPlugin.errorAiNotAvailable,
                message: "iOS 26 or later is required for on-device AI",
                details: nil
            ))
        }
        #else
        result(FlutterError(
            code: AudiflowAiPlugin.errorAiNotAvailable,
            message: "Foundation Models framework not available",
            details: nil
        ))
        #endif
    }

    /// Release native resources.
    ///
    /// Disposes the LanguageModelSession and resets initialization state.
    /// Safe to call multiple times.
    ///
    /// ## Requirements Coverage
    /// - Req 15.1: Support disposing resources via dispose() method
    /// - Req 15.2: Release all native platform resources
    private func handleDispose(result: @escaping FlutterResult) {
        disposeResources()
        result([AudiflowAiPlugin.keySuccess: true])
    }

    // MARK: - Settings Intent Resolution

    /// Resolve a voice transcription into a settings change using keyword matching.
    ///
    /// Parses the provided JSON schema to extract settings with synonyms, types, and
    /// constraints, then matches the transcription against those synonyms. Returns a
    /// dictionary describing the resolved action (absolute, relative, ambiguous, or
    /// not_found) along with a confidence score.
    ///
    /// ## Parameters
    /// - transcription: The voice transcription to resolve
    /// - settingsSchema: JSON string containing the settings schema
    ///
    /// ## Requirements Coverage
    /// - Task 3: iOS SettingsIntentHandler + plugin wiring
    private func handleResolveSettingsIntent(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let transcription = args["transcription"] as? String,
              let schemaJson = args["settingsSchema"] as? String else {
            result(FlutterError(code: AudiflowAiPlugin.errorInvalidArgument,
                                message: "Missing transcription or settingsSchema", details: nil))
            return
        }
        if #available(iOS 26.0, *) {
            let handler = SettingsIntentHandler()
            let resolved = handler.resolve(transcription: transcription, schemaJson: schemaJson)
            result(resolved)
        } else {
            result(nil)
        }
    }

    // MARK: - Private Helpers

    /// Disposes all native resources.
    private func disposeResources() {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            session = nil
        }
        #endif
        systemInstructions = nil
        isInitialized = false
    }

    /// Parsed generation configuration.
    private struct ParsedGenerationConfig {
        let temperature: Double
        let maxOutputTokens: Int?
    }

    /// Parses generation config from platform channel arguments.
    ///
    /// - Parameter config: Map containing temperature and maxOutputTokens
    /// - Returns: Parsed configuration with defaults applied
    private func parseGenerationConfig(_ config: [String: Any]?) -> ParsedGenerationConfig {
        guard let config = config else {
            return ParsedGenerationConfig(
                temperature: AudiflowAiPlugin.defaultTemperature,
                maxOutputTokens: nil
            )
        }

        let temperature: Double
        if let temp = config["temperature"] as? Double {
            temperature = temp
        } else if let temp = config["temperature"] as? NSNumber {
            temperature = temp.doubleValue
        } else {
            temperature = AudiflowAiPlugin.defaultTemperature
        }

        let maxOutputTokens: Int?
        if let max = config["maxOutputTokens"] as? Int {
            maxOutputTokens = max
        } else if let max = config["maxOutputTokens"] as? NSNumber {
            maxOutputTokens = max.intValue
        } else {
            maxOutputTokens = nil
        }

        return ParsedGenerationConfig(
            temperature: temperature,
            maxOutputTokens: maxOutputTokens
        )
    }

    /// Builds Foundation Models GenerationOptions from parsed config.
    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private func buildGenerationOptions(from config: ParsedGenerationConfig) -> GenerationOptions? {
        var options = GenerationOptions()
        var hasOptions = false

        // Apply temperature if different from default
        if config.temperature != AudiflowAiPlugin.defaultTemperature {
            options.temperature = config.temperature
            hasOptions = true
        }

        // Apply max output tokens if specified
        if let maxTokens = config.maxOutputTokens {
            options.maximumResponseTokens = maxTokens
            hasOptions = true
        }

        return hasOptions ? options : nil
    }
    #endif

    /// Maps unavailability reason to human-readable string.
    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private func mapUnavailabilityReason(_ availability: SystemLanguageModel.Availability) -> String {
        switch availability {
        case .available:
            return "Available"
        case .unavailable(.deviceNotEligible):
            return "This device does not support Apple Intelligence"
        case .unavailable(.appleIntelligenceNotEnabled):
            return "Apple Intelligence is not enabled. Please enable it in Settings."
        case .unavailable(.modelNotReady):
            return "The language model is not ready. Please try again later."
        case .unavailable(_):
            return "On-device AI is not available on this device"
        @unknown default:
            return "On-device AI is not available on this device"
        }
    }
    #endif

    /// Handles generation errors and maps to appropriate error codes.
    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private func handleGenerationError(_ error: LanguageModelSession.GenerationError, result: @escaping FlutterResult) {
        switch error {
        case .exceededContextWindowSize:
            result(FlutterError(
                code: AudiflowAiPlugin.errorPromptTooLong,
                message: "Prompt exceeds maximum context window size",
                details: nil
            ))

        case .guardrailViolation(let context):
            result(FlutterError(
                code: AudiflowAiPlugin.errorGenerationFailed,
                message: "Content policy violation: \(context)",
                details: nil
            ))

        @unknown default:
            result(FlutterError(
                code: AudiflowAiPlugin.errorGenerationFailed,
                message: "Text generation failed: \(error.localizedDescription)",
                details: nil
            ))
        }
    }
    #endif
}
