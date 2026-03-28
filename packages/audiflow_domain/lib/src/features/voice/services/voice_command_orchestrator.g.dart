// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_command_orchestrator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Orchestrates voice command flow from speech recognition to execution.
///
/// Manages the state machine:
/// idle -> listening -> processing -> executing -> success/error -> idle
///
/// Usage:
/// ```dart
/// final state = ref.watch(voiceCommandOrchestratorProvider);
/// final orchestrator = ref.read(voiceCommandOrchestratorProvider.notifier);
/// await orchestrator.startVoiceCommand();
/// ```

@ProviderFor(VoiceCommandOrchestrator)
final voiceCommandOrchestratorProvider = VoiceCommandOrchestratorProvider._();

/// Orchestrates voice command flow from speech recognition to execution.
///
/// Manages the state machine:
/// idle -> listening -> processing -> executing -> success/error -> idle
///
/// Usage:
/// ```dart
/// final state = ref.watch(voiceCommandOrchestratorProvider);
/// final orchestrator = ref.read(voiceCommandOrchestratorProvider.notifier);
/// await orchestrator.startVoiceCommand();
/// ```
final class VoiceCommandOrchestratorProvider
    extends $NotifierProvider<VoiceCommandOrchestrator, VoiceRecognitionState> {
  /// Orchestrates voice command flow from speech recognition to execution.
  ///
  /// Manages the state machine:
  /// idle -> listening -> processing -> executing -> success/error -> idle
  ///
  /// Usage:
  /// ```dart
  /// final state = ref.watch(voiceCommandOrchestratorProvider);
  /// final orchestrator = ref.read(voiceCommandOrchestratorProvider.notifier);
  /// await orchestrator.startVoiceCommand();
  /// ```
  VoiceCommandOrchestratorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'voiceCommandOrchestratorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$voiceCommandOrchestratorHash();

  @$internal
  @override
  VoiceCommandOrchestrator create() => VoiceCommandOrchestrator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VoiceRecognitionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VoiceRecognitionState>(value),
    );
  }
}

String _$voiceCommandOrchestratorHash() =>
    r'aa91c4384a92ad6e7c1d7e77fad110e794ff0531';

/// Orchestrates voice command flow from speech recognition to execution.
///
/// Manages the state machine:
/// idle -> listening -> processing -> executing -> success/error -> idle
///
/// Usage:
/// ```dart
/// final state = ref.watch(voiceCommandOrchestratorProvider);
/// final orchestrator = ref.read(voiceCommandOrchestratorProvider.notifier);
/// await orchestrator.startVoiceCommand();
/// ```

abstract class _$VoiceCommandOrchestrator
    extends $Notifier<VoiceRecognitionState> {
  VoiceRecognitionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<VoiceRecognitionState, VoiceRecognitionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VoiceRecognitionState, VoiceRecognitionState>,
              VoiceRecognitionState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
