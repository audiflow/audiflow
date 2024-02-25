// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_subscriptions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastSubscriptionsHash() =>
    r'7de2d5bea250c6ab96f006e6d32e9e0a2e8835e1';

/// See also [PodcastSubscriptions].
@ProviderFor(PodcastSubscriptions)
final podcastSubscriptionsProvider = AsyncNotifierProvider<PodcastSubscriptions,
    List<(PodcastMetadata, PodcastStats)>>.internal(
  PodcastSubscriptions.new,
  name: r'podcastSubscriptionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$podcastSubscriptionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PodcastSubscriptions
    = AsyncNotifier<List<(PodcastMetadata, PodcastStats)>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
