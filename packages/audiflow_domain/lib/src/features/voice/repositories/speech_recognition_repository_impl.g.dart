// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speech_recognition_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a singleton [SpeechRecognitionRepository] instance.

@ProviderFor(speechRecognitionRepository)
final speechRecognitionRepositoryProvider =
    SpeechRecognitionRepositoryProvider._();

/// Provides a singleton [SpeechRecognitionRepository] instance.

final class SpeechRecognitionRepositoryProvider
    extends
        $FunctionalProvider<
          SpeechRecognitionRepository,
          SpeechRecognitionRepository,
          SpeechRecognitionRepository
        >
    with $Provider<SpeechRecognitionRepository> {
  /// Provides a singleton [SpeechRecognitionRepository] instance.
  SpeechRecognitionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'speechRecognitionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$speechRecognitionRepositoryHash();

  @$internal
  @override
  $ProviderElement<SpeechRecognitionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SpeechRecognitionRepository create(Ref ref) {
    return speechRecognitionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpeechRecognitionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpeechRecognitionRepository>(value),
    );
  }
}

String _$speechRecognitionRepositoryHash() =>
    r'd2e13e626a7098fd80be1dc1f4943c9a352cc45c';
