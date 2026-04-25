// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_command_orchestrator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Orchestrates the on-device Gemma 4 voice command flow.
///
/// Hold-to-talk state machine:
/// `idle -> listening (mic open) -> processing (Gemma) -> executing
/// (executor) -> success | error | settingsXxx -> idle`
///
/// Settings change states (`settingsAutoApplied`, `settingsDisambiguation`,
/// `settingsLowConfidence`) are emitted from the executing transition when
/// the parsed command is `changeSettings`; the UI then calls back into
/// [confirmSettingsChange] / [undoSettingsChange] /
/// [selectSettingsCandidate] to resolve.

@ProviderFor(VoiceCommandOrchestrator)
final voiceCommandOrchestratorProvider = VoiceCommandOrchestratorProvider._();

/// Orchestrates the on-device Gemma 4 voice command flow.
///
/// Hold-to-talk state machine:
/// `idle -> listening (mic open) -> processing (Gemma) -> executing
/// (executor) -> success | error | settingsXxx -> idle`
///
/// Settings change states (`settingsAutoApplied`, `settingsDisambiguation`,
/// `settingsLowConfidence`) are emitted from the executing transition when
/// the parsed command is `changeSettings`; the UI then calls back into
/// [confirmSettingsChange] / [undoSettingsChange] /
/// [selectSettingsCandidate] to resolve.
final class VoiceCommandOrchestratorProvider
    extends $NotifierProvider<VoiceCommandOrchestrator, VoiceRecognitionState> {
  /// Orchestrates the on-device Gemma 4 voice command flow.
  ///
  /// Hold-to-talk state machine:
  /// `idle -> listening (mic open) -> processing (Gemma) -> executing
  /// (executor) -> success | error | settingsXxx -> idle`
  ///
  /// Settings change states (`settingsAutoApplied`, `settingsDisambiguation`,
  /// `settingsLowConfidence`) are emitted from the executing transition when
  /// the parsed command is `changeSettings`; the UI then calls back into
  /// [confirmSettingsChange] / [undoSettingsChange] /
  /// [selectSettingsCandidate] to resolve.
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
    r'85080098f1751d9441598119e17e4e54cff32ca9';

/// Orchestrates the on-device Gemma 4 voice command flow.
///
/// Hold-to-talk state machine:
/// `idle -> listening (mic open) -> processing (Gemma) -> executing
/// (executor) -> success | error | settingsXxx -> idle`
///
/// Settings change states (`settingsAutoApplied`, `settingsDisambiguation`,
/// `settingsLowConfidence`) are emitted from the executing transition when
/// the parsed command is `changeSettings`; the UI then calls back into
/// [confirmSettingsChange] / [undoSettingsChange] /
/// [selectSettingsCandidate] to resolve.

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
