import 'package:audiflow_domain/audiflow_domain.dart' show SubscribeSource;
import 'package:audiflow_search/audiflow_search.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../subscription/presentation/controllers/subscription_controller.dart';

/// Centered podcast hero: artwork, title, meta line, and a subscribe pill
/// when not yet subscribed (redesign 4.2).
class PodcastDetailHeader extends ConsumerWidget {
  const PodcastDetailHeader({
    super.key,
    required this.podcast,
    this.subscribeSource = SubscribeSource.discovery,
  });

  static const double artworkSize = 180;
  static const Key artworkKey = ValueKey('podcast-detail-hero-artwork');

  /// Titles at or past this length use the smaller hero style so they
  /// stay within three lines.
  static const int _longTitleLength = 28;

  final Podcast podcast;

  /// Surface that led the user to this header. Forwarded to the
  /// `subscribe` analytics emit when the user taps the subscribe button.
  final SubscribeSource subscribeSource;

  void _showArtworkOverlay(BuildContext context, String artworkUrl) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black87,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) {
          return ArtworkOverlay(
            imageUrl: artworkUrl,
            heroTag: 'podcast_artwork_${podcast.id}',
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artworkUrl = podcast.artworkUrl;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.xl,
        Spacing.sm,
        Spacing.xl,
        Spacing.lg,
      ),
      child: Column(
        children: [
          Semantics(
            label: 'View podcast artwork',
            button: true,
            child: GestureDetector(
              onTap: artworkUrl == null
                  ? null
                  : () => _showArtworkOverlay(context, artworkUrl),
              child: Hero(
                tag: 'podcast_artwork_${podcast.id}',
                child: ClipRRect(
                  key: artworkKey,
                  borderRadius: AppBorders.artworkHero,
                  child: _PodcastArtwork(artworkUrl: artworkUrl),
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),
          _PodcastMetadata(podcast: podcast, longTitle: _isLongTitle),
          _SubscribeButton(podcast: podcast, subscribeSource: subscribeSource),
        ],
      ),
    );
  }

  bool get _isLongTitle => _longTitleLength <= podcast.name.length;
}

class _PodcastMetadata extends StatelessWidget {
  const _PodcastMetadata({required this.podcast, required this.longTitle});

  final Podcast podcast;
  final bool longTitle;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final titleStyle = longTitle
        ? AppTextStyles.heroTitleLong
        : AppTextStyles.heroTitle;
    final category = podcast.genres.firstOrNull;
    final meta = category == null
        ? podcast.artistName
        : '${podcast.artistName} · $category';

    return SelectionArea(
      child: Column(
        children: [
          Text(
            podcast.name,
            textAlign: TextAlign.center,
            style: titleStyle.copyWith(color: colors.ink),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            meta,
            textAlign: TextAlign.center,
            style: AppTextStyles.meta.copyWith(color: colors.inkSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PodcastArtwork extends StatelessWidget {
  const _PodcastArtwork({this.artworkUrl});

  final String? artworkUrl;

  @override
  Widget build(BuildContext context) {
    const size = PodcastDetailHeader.artworkSize;
    final colors = AppColors.of(context);
    Widget fallback(IconData icon, {Widget? child}) => Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: colors.surfaceSunken,
      child: child ?? Icon(icon, size: 64, color: colors.inkTertiary),
    );

    final url = artworkUrl;
    if (url == null) return fallback(Icons.podcasts);

    return ArtworkImage(
      url: url,
      width: size,
      height: size,
      loading: fallback(
        Icons.podcasts,
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
      placeholder: fallback(Icons.broken_image),
    );
  }
}

/// Accent "subscribe" pill, shown only while the podcast is not
/// subscribed. Unsubscribing lives in the `…` menu, so a subscribed
/// podcast's hero carries no button.
class _SubscribeButton extends ConsumerWidget {
  const _SubscribeButton({
    required this.podcast,
    required this.subscribeSource,
  });

  final Podcast podcast;
  final SubscribeSource subscribeSource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final subscriptionState = ref.watch(
      subscriptionControllerProvider(podcast.id),
    );

    // Checked before the value: Riverpod keeps retrying a failed build,
    // so the error arrives wrapped in a loading state.
    if (subscriptionState.hasError && !subscriptionState.hasValue) {
      return _pill(
        context,
        icon: Icons.refresh,
        label: l10n.commonRetry,
        onPressed: () =>
            ref.invalidate(subscriptionControllerProvider(podcast.id)),
      );
    }
    // Nothing until the state is known, so a subscribed podcast does not
    // flash a pill that then disappears.
    if (subscriptionState.value ?? true) return const SizedBox.shrink();
    return _pill(
      context,
      icon: Icons.add,
      label: l10n.podcastDetailSubscribe,
      onPressed: podcast.feedUrl == null
          ? null
          : () => _toggleSubscription(context, ref),
    );
  }

  Widget _pill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.md),
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: colors.onAccent,
          textStyle: AppTextStyles.label,
          shape: const StadiumBorder(),
          minimumSize: const Size(0, Spacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
        ),
      ),
    );
  }

  Future<void> _toggleSubscription(BuildContext context, WidgetRef ref) {
    return togglePodcastSubscription(
      context: context,
      ref: ref,
      podcast: podcast,
      source: subscribeSource,
      // The pill is only offered while not subscribed.
      expectSubscribed: false,
    );
  }
}

/// Subscribes or unsubscribes [podcast], telling the user when parental
/// controls block the change. Shared by the hero pill and the `…` menu.
///
/// [expectSubscribed] is the state the caller offered the action for
/// ("Unsubscribe" when true). If the state has since changed or is not
/// known yet, nothing happens: toggling would do the opposite of the
/// label the listener tapped.
Future<void> togglePodcastSubscription({
  required BuildContext context,
  required WidgetRef ref,
  required Podcast podcast,
  required SubscribeSource source,
  required bool expectSubscribed,
}) async {
  final provider = subscriptionControllerProvider(podcast.id);
  if (ref.read(provider).value != expectSubscribed) return;
  final allowed = await ref
      .read(provider.notifier)
      .toggleSubscription(context, podcast, source: source);
  if (allowed || !context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(AppLocalizations.of(context).parentalControlAccessDenied),
    ),
  );
}
