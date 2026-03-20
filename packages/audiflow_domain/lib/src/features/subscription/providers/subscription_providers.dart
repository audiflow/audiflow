import 'package:riverpod/riverpod.dart';

import '../models/subscriptions.dart';
import '../repositories/subscription_repository_impl.dart';

/// Gets subscription by iTunes ID.
///
/// Returns null if no subscription exists with the given iTunes ID.
final subscriptionByItunesIdProvider = FutureProvider.autoDispose
    .family<Subscription?, String>((ref, itunesId) {
      final repo = ref.watch(subscriptionRepositoryProvider);
      return repo.getSubscription(itunesId);
    });

/// Gets subscription by feed URL.
///
/// Returns null if no subscription exists with the given feed URL.
final subscriptionByFeedUrlProvider = FutureProvider.autoDispose
    .family<Subscription?, String>((ref, feedUrl) {
      final repo = ref.watch(subscriptionRepositoryProvider);
      return repo.getByFeedUrl(feedUrl);
    });

/// Gets subscription by its database ID.
///
/// Used to look up podcast metadata (title, artwork) from an episode's
/// Episode.podcastId.
final subscriptionByIdProvider = FutureProvider.autoDispose
    .family<Subscription?, int>((ref, id) {
      final repo = ref.watch(subscriptionRepositoryProvider);
      return repo.getById(id);
    });
