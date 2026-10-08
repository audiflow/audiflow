import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/duration_label.dart';

/// Episode hero (redesign 4.9): centered artwork, then left-aligned
/// podcast name, the full episode title, and one metadata line.
class EpisodeDetailHero extends StatelessWidget {
  const EpisodeDetailHero({
    super.key,
    required this.episode,
    required this.podcastTitle,
    required this.artworkUrl,
    required this.heroTag,
    required this.onPodcastTap,
  });

  static const double artworkSize = 200;
  static const BorderRadius artworkRadius = BorderRadius.all(
    Radius.circular(22),
  );
  static const Key artworkKey = ValueKey('episode-detail-hero-artwork');

  final PodcastItem episode;
  final String podcastTitle;
  final String? artworkUrl;

  /// Shared with the full-size artwork overlay.
  final String heroTag;

  final VoidCallback onPodcastTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final meta = episodeMetaLine(
      episode,
      AppLocalizations.of(context),
      Localizations.localeOf(context).toLanguageTag(),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.screenHorizontal,
        Spacing.sm,
        Spacing.screenHorizontal,
        Spacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: _HeroArtwork(url: artworkUrl, heroTag: heroTag),
          ),
          const SizedBox(height: Spacing.lg),
          if (podcastTitle.isNotBlank) ...[
            _PodcastLink(title: podcastTitle, onTap: onPodcastTap),
            const SizedBox(height: Spacing.xs),
          ],
          SelectableText(
            episode.title,
            style: AppTextStyles.heroTitle.copyWith(color: colors.ink),
          ),
          if (meta != null) ...[
            const SizedBox(height: Spacing.sm),
            Text(
              meta,
              style: AppTextStyles.tabular(
                AppTextStyles.meta.copyWith(color: colors.inkSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// "date · duration · S67 E3 · size", each part omitted when unknown.
/// Null when nothing is known.
@visibleForTesting
String? episodeMetaLine(
  PodcastItem episode,
  AppLocalizations l10n,
  String locale,
) {
  final date = episode.publishDate;
  final duration = episode.duration;
  final number = _episodeNumber(episode);
  final parts = [
    if (date != null) DateFormat.yMMMd(locale).format(date),
    if (duration != null && Duration.zero < duration)
      l10n.durationLabel(duration),
    ?number,
    ?episode.formattedFileSize,
  ];
  return parts.isEmpty ? null : parts.join(' · ');
}

String? _episodeNumber(PodcastItem episode) {
  final number = episode.episodeNumber;
  if (number == null) return null;
  final season = episode.seasonNumber;
  return season == null ? 'E$number' : 'S$season E$number';
}

class _PodcastLink extends StatelessWidget {
  const _PodcastLink({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.xs,
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.label.copyWith(color: colors.accent),
        ),
      ),
    );
  }
}

class _HeroArtwork extends StatelessWidget {
  const _HeroArtwork({required this.url, required this.heroTag});

  final String? url;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final imageUrl = url;
    final artwork = ClipRRect(
      key: EpisodeDetailHero.artworkKey,
      borderRadius: EpisodeDetailHero.artworkRadius,
      child: imageUrl == null
          ? const _ArtworkFallback(icon: Icons.podcasts)
          : ArtworkImage(
              url: imageUrl,
              width: EpisodeDetailHero.artworkSize,
              height: EpisodeDetailHero.artworkSize,
              loading: const _ArtworkFallback(
                icon: Icons.podcasts,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              placeholder: const _ArtworkFallback(icon: Icons.broken_image),
            ),
    );
    if (imageUrl == null) return artwork;
    return Semantics(
      label: 'View episode artwork',
      button: true,
      child: GestureDetector(
        onTap: () => _showOverlay(context, imageUrl),
        child: Hero(tag: heroTag, child: artwork),
      ),
    );
  }

  void _showOverlay(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black87,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, _, _) =>
            ArtworkOverlay(imageUrl: imageUrl, heroTag: heroTag),
      ),
    );
  }
}

class _ArtworkFallback extends StatelessWidget {
  const _ArtworkFallback({required this.icon, this.child});

  final IconData icon;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      width: EpisodeDetailHero.artworkSize,
      height: EpisodeDetailHero.artworkSize,
      alignment: Alignment.center,
      color: colors.surfaceSunken,
      child: child ?? Icon(icon, size: 64, color: colors.inkTertiary),
    );
  }
}
