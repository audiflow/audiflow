// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_link_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for [FeedLinkResolver].

@ProviderFor(feedLinkResolver)
final feedLinkResolverProvider = FeedLinkResolverProvider._();

/// Provider for [FeedLinkResolver].

final class FeedLinkResolverProvider
    extends
        $FunctionalProvider<
          FeedLinkResolver,
          FeedLinkResolver,
          FeedLinkResolver
        >
    with $Provider<FeedLinkResolver> {
  /// Provider for [FeedLinkResolver].
  FeedLinkResolverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedLinkResolverProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedLinkResolverHash();

  @$internal
  @override
  $ProviderElement<FeedLinkResolver> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FeedLinkResolver create(Ref ref) {
    return feedLinkResolver(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedLinkResolver value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedLinkResolver>(value),
    );
  }
}

String _$feedLinkResolverHash() => r'95729e6d8361dad4a04a6610898143c5ee358a2a';

/// Resolves a feed link pasted into search to the podcast to preview.

@ProviderFor(FeedLinkController)
final feedLinkControllerProvider = FeedLinkControllerProvider._();

/// Resolves a feed link pasted into search to the podcast to preview.
final class FeedLinkControllerProvider
    extends $NotifierProvider<FeedLinkController, FeedLinkState> {
  /// Resolves a feed link pasted into search to the podcast to preview.
  FeedLinkControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedLinkControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedLinkControllerHash();

  @$internal
  @override
  FeedLinkController create() => FeedLinkController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedLinkState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedLinkState>(value),
    );
  }
}

String _$feedLinkControllerHash() =>
    r'05bd9adbf2df082bb7b507542ab492b5abb567d2';

/// Resolves a feed link pasted into search to the podcast to preview.

abstract class _$FeedLinkController extends $Notifier<FeedLinkState> {
  FeedLinkState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FeedLinkState, FeedLinkState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FeedLinkState, FeedLinkState>,
              FeedLinkState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
