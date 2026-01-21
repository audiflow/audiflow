// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_command_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(VoiceCommandController)
final voiceCommandControllerProvider = VoiceCommandControllerProvider._();

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
final class VoiceCommandControllerProvider
    extends $NotifierProvider<VoiceCommandController, void> {
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
  VoiceCommandControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'voiceCommandControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$voiceCommandControllerHash();

  @$internal
  @override
  VoiceCommandController create() => VoiceCommandController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$voiceCommandControllerHash() =>
    r'47eb46de34fb3c7c32002f86c6c2153fc80f8a6d';

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

abstract class _$VoiceCommandController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
