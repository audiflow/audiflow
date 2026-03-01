// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a singleton [ChapterRepository] instance.

@ProviderFor(chapterRepository)
final chapterRepositoryProvider = ChapterRepositoryProvider._();

/// Provides a singleton [ChapterRepository] instance.

final class ChapterRepositoryProvider
    extends
        $FunctionalProvider<
          ChapterRepository,
          ChapterRepository,
          ChapterRepository
        >
    with $Provider<ChapterRepository> {
  /// Provides a singleton [ChapterRepository] instance.
  ChapterRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chapterRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chapterRepositoryHash();

  @$internal
  @override
  $ProviderElement<ChapterRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChapterRepository create(Ref ref) {
    return chapterRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChapterRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChapterRepository>(value),
    );
  }
}

String _$chapterRepositoryHash() => r'95a8a6a22d37e7aaa89ddd7b8a1a7614f8a8d610';
