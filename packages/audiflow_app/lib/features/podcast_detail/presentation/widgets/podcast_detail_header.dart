import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart' show SubscribeSource;
import 'package:audiflow_search/audiflow_search.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../subscription/presentation/controllers/subscription_controller.dart';
import 'detail_hero_layout.dart';

/// Podcast hero: artwork, title, meta line, and a subscribe pill when not
/// yet subscribed (redesign 4.2). Centered on phones; artwork beside
/// left-aligned content on tablets.
class PodcastDetailHeader extends ConsumerWidget {
  const PodcastDetailHeader({
    super.key,
    required this.podcast,
    this.subscribeSource = SubscribeSource.discovery,
  });

  static const double artworkSize = 180;
  static const Key artworkKey = ValueKey('podcast-detail-hero-artwork');

  /// Titles at or past this length use the smaller hero style so they
  /// stay within three lines in the narrow centered phone column.
  static const int _longTitleLength = 28;

  final Podcast podcast;

  /// Surface that led the user to this header. Forwarded to the
  /// `subscribe` analytics emit when the user taps the subscribe button.
  final SubscribeSource subscribeSource;

  void _showArtworkOverlay(BuildContext context, String artworkUrl) {
    unawaited(
      ArtworkOverlay.show(
        context,
        imageUrl: artworkUrl,
        heroTag: 'podcast_artwork_${podcast.id}',
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DetailHeroLayout(
      artworkSize: artworkSize,
      artworkGap: Spacing.md,
      phonePadding: const EdgeInsets.fromLTRB(
        Spacing.xl,
        Spacing.sm,
        Spacing.xl,
        Spacing.lg,
      ),
      artwork: _buildArtwork(context),
      content: _buildContent(DetailHeroLayout.isSideBySide(context)),
    );
  }

  /// Centered under the artwork on phones; left-aligned beside it on
  /// tablets, where the content has a column of its own.
  Widget _buildContent(bool sideBySide) {
    return Column(
      crossAxisAlignment: sideBySide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        _PodcastMetadata(
          podcast: podcast,
          // The tablet column is wide enough for a long title in the
          // full hero style within three lines.
          longTitle: !sideBySide && _isLongTitle,
          centered: !sideBySide,
        ),
        _SubscribeButton(
          podcast: podcast,
          subscribeSource: subscribeSource,
          centered: !sideBySide,
        ),
      ],
    );
  }

  Widget _buildArtwork(BuildContext context) {
    final artworkUrl = podcast.artworkUrl;
    return Semantics(
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
    );
  }

  bool get _isLongTitle => _longTitleLength <= podcast.name.length;
}

class _PodcastMetadata extends StatelessWidget {
  const _PodcastMetadata({
    required this.podcast,
    required this.longTitle,
    required this.centered,
  });

  final Podcast podcast;
  final bool longTitle;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final titleStyle = longTitle
        ? AppTextStyles.heroTitleLong
        : AppTextStyles.heroTitle;
    final category = podcast.genres.firstOrNull;
    final textAlign = centered ? TextAlign.center : TextAlign.start;
    final meta = category == null
        ? podcast.artistName
        : '${podcast.artistName} · $category';

    return SelectionArea(
      child: Column(
        crossAxisAlignment: centered
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            podcast.name,
            textAlign: textAlign,
            style: titleStyle.copyWith(color: colors.ink),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            meta,
            textAlign: textAlign,
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
/// podcast's hero carries no button. A new subscription is confirmed on
/// the pill for a moment before it fades and its space closes, so the list
/// below glides up instead of jumping.
class _SubscribeButton extends ConsumerStatefulWidget {
  const _SubscribeButton({
    required this.podcast,
    required this.subscribeSource,
    required this.centered,
  });

  final Podcast podcast;
  final SubscribeSource subscribeSource;
  final bool centered;

  @override
  ConsumerState<_SubscribeButton> createState() => _SubscribeButtonState();
}

class _SubscribeButtonState extends ConsumerState<_SubscribeButton> {
  static const Duration _switchDuration = Duration(milliseconds: 160);
  static const Duration _reducedSwitchDuration = Duration(milliseconds: 100);
  static const Duration _sizeDuration = FloatingNavigationBar.switchDuration;
  static const Duration _confirmHold = Duration(milliseconds: 700);

  /// Last value seen outside a loading state.
  bool? _lastSettled;
  bool _confirming = false;

  /// Off until the first known state has been shown, so the pill appears
  /// at once when the screen opens rather than growing in.
  bool _animate = false;
  bool _animateScheduled = false;
  Timer? _confirmTimer;

  Podcast get podcast => widget.podcast;

  @override
  void dispose() {
    _confirmTimer?.cancel();
    super.dispose();
  }

  void _startConfirmation() {
    _confirmTimer?.cancel();
    setState(() => _confirming = true);
    _confirmTimer = Timer(_confirmHold, () {
      if (mounted) setState(() => _confirming = false);
    });
  }

  /// Turns animation on one frame after a known state is first shown.
  void _scheduleAnimate(AsyncValue<bool> state) {
    if (_animateScheduled || state.isLoading || !state.hasValue) return;
    _animateScheduled = true;
    _lastSettled ??= state.requireValue;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _animate = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = subscriptionControllerProvider(podcast.id);
    ref.listen(provider, (_, next) {
      if (next.isLoading || !next.hasValue) return;
      final settled = next.requireValue;
      // Only a real unsubscribed -> subscribed change earns the
      // confirmation; the first load does not.
      if (_lastSettled == false && settled) _startConfirmation();
      _lastSettled = settled;
    });
    final subscriptionState = ref.watch(provider);
    _scheduleAnimate(subscriptionState);
    return _animated(context, _current(context, subscriptionState));
  }

  Widget _current(BuildContext context, AsyncValue<bool> state) {
    final l10n = AppLocalizations.of(context);
    // Checked before the value: Riverpod keeps retrying a failed build,
    // so the error arrives wrapped in a loading state.
    if (state.hasError && !state.hasValue) {
      return KeyedSubtree(
        key: const ValueKey('retry'),
        child: _pill(
          context,
          icon: Icons.refresh,
          label: l10n.commonRetry,
          onPressed: () =>
              ref.invalidate(subscriptionControllerProvider(podcast.id)),
        ),
      );
    }
    if (_confirming) {
      return KeyedSubtree(
        key: const ValueKey('confirmed'),
        child: _pill(
          context,
          icon: Icons.check_rounded,
          label: l10n.podcastDetailSubscribed,
          onPressed: null,
        ),
      );
    }
    // Nothing until the state is known, so a subscribed podcast does not
    // flash a pill that then disappears.
    if (state.value ?? true) {
      return const SizedBox.shrink(key: ValueKey('none'));
    }
    return KeyedSubtree(
      key: const ValueKey('offer'),
      child: _pill(
        context,
        icon: Icons.add,
        label: l10n.podcastDetailSubscribe,
        onPressed: podcast.feedUrl == null
            ? null
            : () => _toggleSubscription(context, ref),
      ),
    );
  }

  /// The pill fades out before its space closes: the switcher's stack
  /// keeps the old pill's size until its fade ends.
  Widget _animated(BuildContext context, Widget child) {
    // Left out rather than given zero durations: a zero-length
    // AnimatedSize re-dirties itself during layout.
    if (!_animate) return child;
    // iOS reports Reduce Motion only through `reduceMotion`; Android's
    // "Remove animations" only through `disableAnimations`.
    final reduceMotion =
        MediaQuery.disableAnimationsOf(context) ||
        View.of(context).platformDispatcher.accessibilityFeatures.reduceMotion;
    final alignment = widget.centered
        ? Alignment.topCenter
        : AlignmentDirectional.topStart;
    final switcher = AnimatedSwitcher(
      duration: reduceMotion ? _reducedSwitchDuration : _switchDuration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (current, previous) =>
          Stack(alignment: alignment, children: [...previous, ?current]),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: reduceMotion
            ? child
            : ScaleTransition(
                scale: Tween<double>(begin: 0.97, end: 1).animate(animation),
                child: child,
              ),
      ),
      child: child,
    );
    if (reduceMotion) return switcher;
    return AnimatedSize(
      duration: _sizeDuration,
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: switcher,
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
          // The confirmation is inert but must not turn gray.
          disabledBackgroundColor: colors.accent,
          disabledForegroundColor: colors.onAccent,
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
      source: widget.subscribeSource,
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
// Subscribing is a completed task (success); unsubscribing is low-key
// (tap), so the two never share a feel; a failed toggle is an error.
HapticToken _subscriptionOutcome(AsyncValue<bool> result) => switch (result) {
  AsyncError() => HapticToken.error,
  AsyncData(value: true) => HapticToken.success,
  _ => HapticToken.tap,
};

Future<void> togglePodcastSubscription({
  required BuildContext context,
  required WidgetRef ref,
  required Podcast podcast,
  required SubscribeSource source,
  required bool expectSubscribed,
}) async {
  final provider = subscriptionControllerProvider(podcast.id);
  if (ref.read(provider).value != expectSubscribed) return;
  final haptics = HapticsScope.of(context);
  final allowed = await ref
      .read(provider.notifier)
      .toggleSubscription(context, podcast, source: source);
  if (!context.mounted) return;
  if (allowed) {
    haptics.play(_subscriptionOutcome(ref.read(provider)));
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(AppLocalizations.of(context).parentalControlAccessDenied),
    ),
  );
}
