import 'package:riverpod/riverpod.dart';

import '../../../common/database/app_database.dart';
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
