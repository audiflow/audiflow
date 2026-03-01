// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcript_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(transcriptService)
final transcriptServiceProvider = TranscriptServiceProvider._();

final class TranscriptServiceProvider
    extends
        $FunctionalProvider<
          TranscriptService,
          TranscriptService,
          TranscriptService
        >
    with $Provider<TranscriptService> {
  TranscriptServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transcriptServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transcriptServiceHash();

  @$internal
  @override
  $ProviderElement<TranscriptService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TranscriptService create(Ref ref) {
    return transcriptService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TranscriptService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TranscriptService>(value),
    );
  }
}

String _$transcriptServiceHash() => r'd05dd3b23b863c4daa16c5994a6ef6cd57a3f5fd';
