// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcript_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a singleton [TranscriptRepository] instance.

@ProviderFor(transcriptRepository)
final transcriptRepositoryProvider = TranscriptRepositoryProvider._();

/// Provides a singleton [TranscriptRepository] instance.

final class TranscriptRepositoryProvider
    extends
        $FunctionalProvider<
          TranscriptRepository,
          TranscriptRepository,
          TranscriptRepository
        >
    with $Provider<TranscriptRepository> {
  /// Provides a singleton [TranscriptRepository] instance.
  TranscriptRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transcriptRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transcriptRepositoryHash();

  @$internal
  @override
  $ProviderElement<TranscriptRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TranscriptRepository create(Ref ref) {
    return transcriptRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TranscriptRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TranscriptRepository>(value),
    );
  }
}

String _$transcriptRepositoryHash() =>
    r'ce699089f422a985b433a1d44380035529b4d6c8';
