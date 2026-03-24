import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Re-export for convenience.
export 'package:audiflow_domain/audiflow_domain.dart'
    show
        VoiceRecognitionState,
        VoiceIdle,
        VoiceListening,
        VoiceProcessing,
        VoiceExecuting,
        VoiceSuccess,
        VoiceError,
        VoiceSettingsAutoApplied,
        VoiceSettingsDisambiguation,
        VoiceSettingsLowConfidence;

part 'voice_command_controller.g.dart';

/// Controller for voice command UI interactions.
///
/// This is a thin wrapper around [VoiceCommandOrchestrator] that provides
/// UI-specific convenience methods. The actual state is managed by the
/// domain-layer orchestrator.
///
/// Usage:
/// ```dart
/// final state = ref.watch(voiceCommandOrchestratorProvider);
/// final controller = ref.read(voiceCommandControllerProvider.notifier);
///
/// // Start listening
/// await controller.startVoiceCommand();
///
/// // Cancel
/// await controller.cancel();
/// ```
@riverpod
class VoiceCommandController extends _$VoiceCommandController {
  @override
  void build() {
    // This controller doesn't manage its own state;
    // it delegates to the orchestrator.
  }

  /// Get the current voice recognition state.
  VoiceRecognitionState get currentState {
    return ref.read(voiceCommandOrchestratorProvider);
  }

  /// Whether voice recognition is available on this device.
  bool get isAvailable {
    final repo = ref.read(speechRecognitionRepositoryProvider);
    return repo.isAvailable;
  }

  /// Whether the system is currently listening for voice input.
  bool get isListening {
    return currentState is VoiceListening;
  }

  /// Whether the system is processing a voice command.
  bool get isProcessing {
    return currentState is VoiceProcessing || currentState is VoiceExecuting;
  }

  /// Whether the system is in an active state (not idle).
  bool get isActive {
    return currentState is! VoiceIdle;
  }

  /// Start listening for a voice command.
  ///
  /// Returns once the entire voice command flow completes
  /// (listening -> processing -> execution -> result).
  Future<void> startVoiceCommand() async {
    final orchestrator = ref.read(voiceCommandOrchestratorProvider.notifier);
    await orchestrator.startVoiceCommand();
  }

  /// Cancel the current voice command operation.
  Future<void> cancel() async {
    final orchestrator = ref.read(voiceCommandOrchestratorProvider.notifier);
    await orchestrator.cancelVoiceCommand();
  }

  /// Reset the state to idle.
  void reset() {
    final orchestrator = ref.read(voiceCommandOrchestratorProvider.notifier);
    orchestrator.resetToIdle();
  }

  /// Initialize the voice command system.
  ///
  /// Call this early in the app lifecycle to pre-initialize
  /// speech recognition.
  Future<bool> initialize() async {
    final orchestrator = ref.read(voiceCommandOrchestratorProvider.notifier);
    return orchestrator.initialize();
  }
}
