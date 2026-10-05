// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(chapterService)
final chapterServiceProvider = ChapterServiceProvider._();

final class ChapterServiceProvider
    extends $FunctionalProvider<ChapterService, ChapterService, ChapterService>
    with $Provider<ChapterService> {
  ChapterServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chapterServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chapterServiceHash();

  @$internal
  @override
  $ProviderElement<ChapterService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChapterService create(Ref ref) {
    return chapterService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChapterService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChapterService>(value),
    );
  }
}

String _$chapterServiceHash() => r'42b74d19226b1cc1d41c7136b0f662e2a25a28fe';
