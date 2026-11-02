// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream_cache_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(streamCacheService)
final streamCacheServiceProvider = StreamCacheServiceProvider._();

final class StreamCacheServiceProvider
    extends
        $FunctionalProvider<
          StreamCacheService,
          StreamCacheService,
          StreamCacheService
        >
    with $Provider<StreamCacheService> {
  StreamCacheServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streamCacheServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streamCacheServiceHash();

  @$internal
  @override
  $ProviderElement<StreamCacheService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StreamCacheService create(Ref ref) {
    return streamCacheService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StreamCacheService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StreamCacheService>(value),
    );
  }
}

String _$streamCacheServiceHash() =>
    r'55c5b64e6c931c197dd83a4e2fb5dbcafe4b33c8';

/// The bytes currently held by the streamed-audio cache.

@ProviderFor(streamCacheSize)
final streamCacheSizeProvider = StreamCacheSizeProvider._();

/// The bytes currently held by the streamed-audio cache.

final class StreamCacheSizeProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// The bytes currently held by the streamed-audio cache.
  StreamCacheSizeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streamCacheSizeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streamCacheSizeHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return streamCacheSize(ref);
  }
}

String _$streamCacheSizeHash() => r'f3fa0ee0ee689b9511e71667c669465b18e50fff';
