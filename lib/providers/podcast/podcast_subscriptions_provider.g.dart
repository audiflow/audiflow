// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_subscriptions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastSubscriptionsHash() =>
    r'ae7bc0c0ab2d1ce1a8e1ef7803bfa04069b9b100';

/// See also [PodcastSubscriptions].
@ProviderFor(PodcastSubscriptions)
final podcastSubscriptionsProvider = AsyncNotifierProvider<PodcastSubscriptions,
    List<(PodcastStats, PodcastSummary)>>.internal(
  PodcastSubscriptions.new,
  name: r'podcastSubscriptionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$podcastSubscriptionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PodcastSubscriptions
    = AsyncNotifier<List<(PodcastStats, PodcastSummary)>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
