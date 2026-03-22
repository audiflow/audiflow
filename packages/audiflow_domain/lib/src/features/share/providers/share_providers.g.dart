// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(itunesChartsClient)
final itunesChartsClientProvider = ItunesChartsClientProvider._();

final class ItunesChartsClientProvider
    extends
        $FunctionalProvider<
          ItunesChartsClient,
          ItunesChartsClient,
          ItunesChartsClient
        >
    with $Provider<ItunesChartsClient> {
  ItunesChartsClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itunesChartsClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itunesChartsClientHash();

  @$internal
  @override
  $ProviderElement<ItunesChartsClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ItunesChartsClient create(Ref ref) {
    return itunesChartsClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ItunesChartsClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ItunesChartsClient>(value),
    );
  }
}

String _$itunesChartsClientHash() =>
    r'11b33c71a89b9f64ad66d597a3175326067f30f8';

@ProviderFor(shareLinkBuilder)
final shareLinkBuilderProvider = ShareLinkBuilderProvider._();

final class ShareLinkBuilderProvider
    extends
        $FunctionalProvider<
          ShareLinkBuilder,
          ShareLinkBuilder,
          ShareLinkBuilder
        >
    with $Provider<ShareLinkBuilder> {
  ShareLinkBuilderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shareLinkBuilderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shareLinkBuilderHash();

  @$internal
  @override
  $ProviderElement<ShareLinkBuilder> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ShareLinkBuilder create(Ref ref) {
    return shareLinkBuilder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShareLinkBuilder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShareLinkBuilder>(value),
    );
  }
}

String _$shareLinkBuilderHash() => r'8bea6372c617d629386099c8eaa79c6a5b8a5156';

@ProviderFor(deepLinkResolver)
final deepLinkResolverProvider = DeepLinkResolverProvider._();

final class DeepLinkResolverProvider
    extends
        $FunctionalProvider<
          DeepLinkResolver,
          DeepLinkResolver,
          DeepLinkResolver
        >
    with $Provider<DeepLinkResolver> {
  DeepLinkResolverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deepLinkResolverProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deepLinkResolverHash();

  @$internal
  @override
  $ProviderElement<DeepLinkResolver> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeepLinkResolver create(Ref ref) {
    return deepLinkResolver(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeepLinkResolver value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeepLinkResolver>(value),
    );
  }
}

String _$deepLinkResolverHash() => r'823599bb37fbb8dc099aef95ea62e8bc9c48bc33';
