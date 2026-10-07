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
/// cannot drop a subscription. Hidden while the state is unknown.
class SearchSubscribeButton extends ConsumerWidget {
  const SearchSubscribeButton({super.key, required this.podcast});

  final Podcast podcast;

  static const double _circle = 36;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final subscribed = ref
        .watch(subscriptionControllerProvider(podcast.id))
        .value;
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
        child: SizedBox.square(
          dimension: Spacing.minTouchTarget,
          child: Center(child: ExcludeSemantics(child: circle)),
        ),
      );
    }
    return IconButton(
      tooltip: l10n.podcastDetailSubscribe,
      onPressed: () => togglePodcastSubscription(
        context: context,
        ref: ref,
        podcast: podcast,
        source: SubscribeSource.search,
        expectSubscribed: false,
      ),
      icon: circle,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(
        width: Spacing.minTouchTarget,
        height: Spacing.minTouchTarget,
      ),
    );
  }
}
