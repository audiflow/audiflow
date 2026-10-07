import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

/// Series episodes hero (redesign 4.3): artwork beside the series name,
/// the podcast name linking back, the series meta line, and a full-width
/// button that resumes (or starts) the series.
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

  static const double artworkSize = 88;

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
              const SizedBox(width: Spacing.md),
              Expanded(child: _texts(context)),
            ],
          ),
          if (resumeLabel != null) ...[
            const SizedBox(height: Spacing.md),
            FilledButton.icon(
              onPressed: onResume,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(resumeLabel),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(Spacing.minTouchTarget),
                shape: const StadiumBorder(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _artwork(BuildContext context) {
    final colors = AppColors.of(context);
    final url = thumbnailUrl;
    Widget fallback(IconData icon) => Container(
      width: artworkSize,
      height: artworkSize,
      alignment: Alignment.center,
      color: colors.surfaceSunken,
      child: Icon(icon, size: 36, color: colors.inkTertiary),
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
