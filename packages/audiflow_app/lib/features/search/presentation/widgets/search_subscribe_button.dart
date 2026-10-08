import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../subscription/presentation/controllers/subscription_controller.dart';
import '../../../podcast_detail/presentation/widgets/podcast_detail_header.dart'
    show togglePodcastSubscription;

/// Tonal "+" that subscribes to a search result in place (redesign 4.7).
///
/// Once subscribed it turns into a check and does nothing: unsubscribing
/// stays on the podcast's own screen, so a stray tap in a result list
/// cannot drop a subscription. Hidden while the state is unknown; a state
/// that failed to load offers a retry, as on the podcast screen.
class SearchSubscribeButton extends ConsumerWidget {
  const SearchSubscribeButton({super.key, required this.podcast});

  final Podcast podcast;

  static const double _circle = 36;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final provider = subscriptionControllerProvider(podcast.id);
    final subscription = ref.watch(provider);
    // Checked before the value: Riverpod keeps retrying a failed build,
    // so the error arrives wrapped in a loading state.
    if (subscription.hasError && !subscription.hasValue) {
      return IconButton(
        tooltip: l10n.commonRetry,
        icon: Icon(Icons.refresh_rounded, color: colors.accent),
        onPressed: () => ref.invalidate(provider),
      );
    }
    final subscribed = subscription.value;
    if (subscribed == null) {
      return const SizedBox.square(dimension: Spacing.minTouchTarget);
    }

    final circle = Container(
      width: _circle,
      height: _circle,
      decoration: BoxDecoration(
        color: colors.accentTint,
        shape: BoxShape.circle,
      ),
      child: Icon(
        subscribed ? Icons.check_rounded : Icons.add_rounded,
        size: 22,
        color: colors.accent,
      ),
    );

    if (subscribed) {
      return Semantics(
        label: l10n.podcastDetailSubscribed,
        // Swallows the tap: inside a result row it would open the podcast.
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {},
          excludeFromSemantics: true,
          child: SizedBox.square(
            dimension: Spacing.minTouchTarget,
            child: Center(child: ExcludeSemantics(child: circle)),
          ),
        ),
      );
    }
    return IconButton(
      tooltip: l10n.podcastDetailSubscribe,
      // Subscribing needs the feed, as on the podcast screen.
      onPressed: podcast.feedUrl == null
          ? null
          : () => _subscribe(context, ref),
      icon: circle,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(
        width: Spacing.minTouchTarget,
        height: Spacing.minTouchTarget,
      ),
    );
  }

  /// Subscribes, then fetches the episodes: Search never opens the podcast
  /// screen, whose own fetch would otherwise store them.
  Future<void> _subscribe(BuildContext context, WidgetRef ref) async {
    // Read before awaiting: the row may rebuild away meanwhile.
    final container = ProviderScope.containerOf(context, listen: false);
    final feedSync = ref.read(feedSyncServiceProvider);
    final logger = ref.read(namedLoggerProvider('SearchSubscribe'));
    await togglePodcastSubscription(
      context: context,
      ref: ref,
      podcast: podcast,
      source: SubscribeSource.search,
      expectSubscribed: false,
    );
    final feedUrl = podcast.feedUrl;
    final subscribed = container
        .read(subscriptionControllerProvider(podcast.id))
        .value;
    if (feedUrl == null || subscribed != true) return;
    try {
      await feedSync.syncFeedsByUrls([feedUrl]);
    } catch (error, stackTrace) {
      // Not fatal: the next refresh or opening the podcast fetches them.
      logger.w(
        'Failed to fetch a new subscription',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
