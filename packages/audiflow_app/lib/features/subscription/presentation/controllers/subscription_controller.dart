import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../features/parental_control/domain/gate_guard.dart';
import '../../../../features/parental_control/providers/gate_guard_provider.dart';
import '../../../podcast_detail/presentation/controllers/podcast_detail_controller.dart';

part 'subscription_controller.g.dart';

/// Controller for managing subscription state for a specific podcast.
///
/// Tracks whether the user is subscribed to a podcast identified by iTunes ID
/// and provides methods to toggle subscription status.
@riverpod
class SubscriptionController extends _$SubscriptionController {
  @override
  Future<bool> build(String itunesId) async {
    return ref.watch(subscriptionRepositoryProvider).isSubscribed(itunesId);
  }

  /// Toggles subscription status for the given podcast.
  ///
  /// If subscribed, unsubscribes; if not subscribed, subscribes.
  /// Updates the state to reflect the new subscription status.
  ///
  /// [context] is required to present the PIN entry sheet when
  /// Restricted Mode is active and the gate is locked.
  ///
  /// [source] identifies the entry surface for the `subscribe` analytics
  /// emit (defaults to discovery). Callers from search/deeplink should
  /// pass the corresponding [SubscribeSource] so the audit reflects how
  /// users arrived at the subscribe action.
  Future<void> toggleSubscription(
    BuildContext context,
    Podcast podcast, {
    SubscribeSource source = SubscribeSource.discovery,
  }) async {
    final isCurrentlySubscribed = state.value ?? false;
    final reason = isCurrentlySubscribed
        ? GateReason.unsubscribe
        : GateReason.subscribe;
    final allowed = await ref
        .read(gateGuardProvider)
        .requireUnlock(context, reason: reason);
    if (!allowed) return;

    final repository = ref.read(subscriptionRepositoryProvider);

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      if (isCurrentlySubscribed) {
        final feedUrl = podcast.feedUrl;
        await repository.unsubscribe(podcast.id);
        ref.invalidate(subscriptionByItunesIdProvider(podcast.id));
        if (feedUrl != null) {
          ref.invalidate(subscriptionByFeedUrlProvider(feedUrl));
        }
        return false;
      } else {
        final feedUrl = podcast.feedUrl;
        if (feedUrl == null) {
          throw SubscriptionException(
            'Cannot subscribe: no feed URL available',
          );
        }

        await repository.subscribe(
          itunesId: podcast.id,
          feedUrl: feedUrl,
          title: podcast.name,
          artistName: podcast.artistName,
          artworkUrl: podcast.artworkUrl,
          description: podcast.description,
          genres: podcast.genres,
          explicit: podcast.explicit,
          source: source,
        );

        // Invalidate feed provider to trigger episode persistence
        // (episodes are only persisted when subscribed)
        ref.invalidate(podcastDetailProvider(feedUrl));
        ref.invalidate(subscriptionByItunesIdProvider(podcast.id));
        ref.invalidate(subscriptionByFeedUrlProvider(feedUrl));

        return true;
      }
    });
  }
}
