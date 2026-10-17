import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

import 'episode_detail_actions.dart' show EpisodePrimaryPill;
import 'podcast_detail_header.dart' show PodcastDetailHeader;

/// Series episodes hero (redesign 4.3): artwork beside the series name,
/// the podcast name linking back, the series meta line, and a button that
/// resumes (or starts) the series. The button spans the width on phones;
/// on tablets it is centered and capped at the episode detail play pill's
/// width so it does not stretch across the screen. On tablets the artwork
/// grows to the podcast hero's size so the hero does not look sparse.
class SeriesHero extends StatelessWidget {
  const SeriesHero({
    super.key,
    required this.title,
    required this.podcastTitle,
    required this.meta,
    this.thumbnailUrl,
    this.onArtworkTap,
    this.artworkLabel,
    this.onPodcastTap,
    this.resumeLabel,
    this.onResume,
  });

  static const double phoneArtworkSize = 88;

  /// Tied to the podcast hero, not just equal to it: [ArtworkImage] decodes
  /// at the displayed physical width, and a series without its own artwork
  /// shows the podcast artwork. At the same size it reuses the decoded image
  /// the podcast screen (the usual way here) already holds in memory.
  static const double tabletArtworkSize = PodcastDetailHeader.artworkSize;

  /// Artwork side for this screen: [tabletArtworkSize] from the app-wide
  /// tablet breakpoint, [phoneArtworkSize] below it.
  static double artworkSizeOf(BuildContext context) =>
      _isTablet(context) ? tabletArtworkSize : phoneArtworkSize;

  static bool _isTablet(BuildContext context) =>
      DeviceUtils.isTablet(MediaQuery.sizeOf(context).shortestSide);

  @visibleForTesting
  static const Key artworkKey = ValueKey('series-hero-artwork');

  /// Titles at or past this length use the smaller hero style so they
  /// stay within three lines next to the artwork.
  static const int _longTitleLength = 24;

  final String title;
  final String podcastTitle;

  /// "N episodes · total duration".
  final String meta;
  final String? thumbnailUrl;
  final VoidCallback? onArtworkTap;

  /// Accessibility label of the artwork button.
  final String? artworkLabel;
  final VoidCallback? onPodcastTap;

  /// Label of the resume button; null hides it (e.g. every episode played).
  final String? resumeLabel;
  final VoidCallback? onResume;

  @override
  Widget build(BuildContext context) {
    final resumeLabel = this.resumeLabel;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.screenHorizontal,
        Spacing.sm,
        Spacing.screenHorizontal,
        Spacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _artwork(context),
              // On tablets, the podcast hero's artwork-to-text spacing: its
              // square column leaves 24 beside the artwork.
              SizedBox(width: _isTablet(context) ? Spacing.lg : Spacing.md),
              Expanded(child: _texts(context)),
            ],
          ),
          if (resumeLabel != null) ...[
            const SizedBox(height: Spacing.md),
            _resumeButton(context, resumeLabel),
          ],
        ],
      ),
    );
  }

  Widget _resumeButton(BuildContext context, String label) {
    final button = FilledButton.icon(
      onPressed: onResume,
      icon: const Icon(Icons.play_arrow_rounded),
      label: Text(label),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(Spacing.minTouchTarget),
        shape: const StadiumBorder(),
      ),
    );
    if (!_isTablet(context)) return button;
    // Same width as the episode detail play pill, so both screens' primary
    // play actions read as one size on tablets. Center hands the SizedBox
    // loose constraints, so a narrower row still clamps it.
    return Center(
      child: SizedBox(width: EpisodePrimaryPill.maxWidth, child: button),
    );
  }

  Widget _artwork(BuildContext context) {
    final colors = AppColors.of(context);
    final url = thumbnailUrl;
    final artworkSize = artworkSizeOf(context);
    // 64 matches the podcast hero's fallback icon at the same artwork size.
    final iconSize = _isTablet(context) ? 64.0 : 36.0;
    Widget fallback(IconData icon) => Container(
      width: artworkSize,
      height: artworkSize,
      alignment: Alignment.center,
      color: colors.surfaceSunken,
      child: Icon(icon, size: iconSize, color: colors.inkTertiary),
    );
    final image = url == null
        ? fallback(Icons.folder_outlined)
        : ArtworkImage(
            url: url,
            width: artworkSize,
            height: artworkSize,
            loading: const ArtworkLoadingIndicator(),
            placeholder: fallback(Icons.broken_image_outlined),
          );
    final artwork = ClipRRect(
      key: artworkKey,
      borderRadius: AppBorders.card,
      child: image,
    );
    if (url == null || onArtworkTap == null) return artwork;
    return Semantics(
      button: true,
      label: artworkLabel,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: AppBorders.card,
          onTap: onArtworkTap,
          child: Hero(tag: 'group_artwork_$url', child: artwork),
        ),
      ),
    );
  }

  Widget _texts(BuildContext context) {
    final colors = AppColors.of(context);
    final titleStyle = _longTitleLength <= title.characters.length
        ? AppTextStyles.heroTitleLong
        : AppTextStyles.heroTitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: titleStyle.copyWith(color: colors.ink),
        ),
        // Full-height touch target; the text stays where a plain line of
        // meta would sit.
        Semantics(
          link: onPodcastTap != null,
          child: InkWell(
            onTap: onPodcastTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: Spacing.minTouchTarget,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  podcastTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.meta.copyWith(color: colors.accent),
                ),
              ),
            ),
          ),
        ),
        Text(
          meta,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption.copyWith(color: colors.inkTertiary),
        ),
      ],
    );
  }
}
