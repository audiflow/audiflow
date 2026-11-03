// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream_cache_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StreamCacheServiceNotifier)
final streamCacheServiceProvider = StreamCacheServiceNotifierProvider._();

final class StreamCacheServiceNotifierProvider
    extends $NotifierProvider<StreamCacheServiceNotifier, StreamCacheService> {
  StreamCacheServiceNotifierProvider._()
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
  String debugGetCreateSourceHash() => _$streamCacheServiceNotifierHash();

  @$internal
  @override
  StreamCacheServiceNotifier create() => StreamCacheServiceNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StreamCacheService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StreamCacheService>(value),
    );
  }
}

String _$streamCacheServiceNotifierHash() =>
    r'de9612171e07c38a5700a5f41ab483378fc4d4fa';

abstract class _$StreamCacheServiceNotifier
    extends $Notifier<StreamCacheService> {
  StreamCacheService build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<StreamCacheService, StreamCacheService>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StreamCacheService, StreamCacheService>,
              StreamCacheService,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// The bytes currently held by the streamed-audio cache, kept current while
/// something shows them.

@ProviderFor(StreamCacheSize)
final streamCacheSizeProvider = StreamCacheSizeProvider._();

/// The bytes currently held by the streamed-audio cache, kept current while
/// something shows them.
final class StreamCacheSizeProvider
    extends $AsyncNotifierProvider<StreamCacheSize, int> {
  /// The bytes currently held by the streamed-audio cache, kept current while
  /// something shows them.
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
  StreamCacheSize create() => StreamCacheSize();
}

String _$streamCacheSizeHash() => r'b9de7c15a7047323e80897f675fe56b7fb2f4061';

/// The bytes currently held by the streamed-audio cache, kept current while
/// something shows them.

abstract class _$StreamCacheSize extends $AsyncNotifier<int> {
  FutureOr<int> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
