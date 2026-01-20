// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

import Flutter
import UIKit

/// AudiflowAiPlugin handles platform channel communication for on-device AI features.
///
/// This plugin provides access to Apple Foundation Models for text generation
/// and summarization on supported iOS devices.
public class AudiflowAiPlugin: NSObject, FlutterPlugin {
    // MARK: - Constants

    private static let channelName = "com.audiflow/ai"

    // Method names
    private static let methodCheckCapability = "checkCapability"
    private static let methodInitialize = "initialize"
    private static let methodGenerateText = "generateText"
    private static let methodDispose = "dispose"
    private static let methodPromptAiCoreInstall = "promptAiCoreInstall"

    // Response keys
    private static let keyStatus = "status"
    private static let keyText = "text"
    private static let keyTokenCount = "tokenCount"
    private static let keyDurationMs = "durationMs"
    private static let keySuccess = "success"
    private static let keyErrorCode = "errorCode"
    private static let keyErrorMessage = "errorMessage"

    // Status values
    private static let statusFull = "full"
    private static let statusLimited = "limited"
    private static let statusUnavailable = "unavailable"
    private static let statusNeedsSetup = "needsSetup"

    // MARK: - Properties

    private var isInitialized = false

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
            // Not applicable on iOS
            result(false)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Method Handlers

    /// Check AI capability on this device.
    ///
    /// Returns status indicating whether AI is available or unavailable.
    /// This is a stub that returns unavailable - will be implemented with Foundation Models in Phase 2.
    private func handleCheckCapability(result: @escaping FlutterResult) {
        // Stub implementation - returns unavailable until Foundation Models integration in Phase 2
        // TODO: Check SystemLanguageModel.default.availability
        result([
            AudiflowAiPlugin.keyStatus: AudiflowAiPlugin.statusUnavailable
        ])
    }

    /// Initialize the AI engine with optional system instructions.
    ///
    /// This is a stub that returns an error - will be implemented with Foundation Models in Phase 2.
    private func handleInitialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]
        let _ = args?["instructions"] as? String

        // Stub implementation - returns error until Foundation Models integration in Phase 2
        // TODO: Create LanguageModelSession with system instructions
        result(FlutterError(
            code: "AI_NOT_AVAILABLE",
            message: "AI is not available on this device (stub implementation)",
            details: nil
        ))
    }

    /// Generate text from a prompt.
    ///
    /// This is a stub that returns an error - will be implemented with Foundation Models in Phase 2.
    private func handleGenerateText(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard isInitialized else {
            result(FlutterError(
                code: "AI_NOT_INITIALIZED",
                message: "AI engine not initialized. Call initialize() first.",
                details: nil
            ))
            return
        }

        guard let args = call.arguments as? [String: Any],
              let prompt = args["prompt"] as? String,
              !prompt.isEmpty else {
            result(FlutterError(
                code: "INVALID_ARGUMENT",
                message: "Prompt cannot be empty",
                details: nil
            ))
            return
        }

        // Stub implementation - will be implemented with Foundation Models in Phase 2
        // TODO: Invoke LanguageModelSession.respond(to:)
        result(FlutterError(
            code: "AI_NOT_AVAILABLE",
            message: "AI is not available on this device (stub implementation)",
            details: nil
        ))
    }

    /// Release native resources.
    private func handleDispose(result: @escaping FlutterResult) {
        isInitialized = false
        // TODO: Release Foundation Models resources in Phase 2
        result([AudiflowAiPlugin.keySuccess: true])
    }
}
