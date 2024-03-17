// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_subscriptions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastSubscriptionsHash() =>
    r'113ce9aec851fe6570bf21ab65bf6cbfbdbd7159';

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
