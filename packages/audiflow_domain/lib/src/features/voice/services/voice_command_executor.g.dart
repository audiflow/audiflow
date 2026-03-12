// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_command_executor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Executes voice command actions against player and queue services.

@ProviderFor(voiceCommandExecutor)
final voiceCommandExecutorProvider = VoiceCommandExecutorProvider._();

/// Executes voice command actions against player and queue services.

final class VoiceCommandExecutorProvider
    extends
        $FunctionalProvider<
          VoiceCommandExecutor,
          VoiceCommandExecutor,
          VoiceCommandExecutor
        >
    with $Provider<VoiceCommandExecutor> {
  /// Executes voice command actions against player and queue services.
  VoiceCommandExecutorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'voiceCommandExecutorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$voiceCommandExecutorHash();

  @$internal
  @override
  $ProviderElement<VoiceCommandExecutor> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VoiceCommandExecutor create(Ref ref) {
    return voiceCommandExecutor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VoiceCommandExecutor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VoiceCommandExecutor>(value),
    );
  }
}

String _$voiceCommandExecutorHash() =>
    r'180a48979745916e17ce2d2d70e0883d9b27ea00';
