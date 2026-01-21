import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_search/audiflow_search.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
  Future<void> toggleSubscription(Podcast podcast) async {
    final repository = ref.read(subscriptionRepositoryProvider);
    final isCurrentlySubscribed = state.value ?? false;

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      if (isCurrentlySubscribed) {
        await repository.unsubscribe(podcast.id);
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
        );
        return true;
      }
    });
  }
}
