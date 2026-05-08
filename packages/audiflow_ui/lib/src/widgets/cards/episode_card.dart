import 'package:audiflow_core/audiflow_core.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../styles/spacing.dart';
import '../buttons/episode_play_pill.dart';

/// Fixed height for the episode card, used as itemExtent in sliver lists.
const double episodeCardExtent = 140.0;

const double _thumbnailSize = 76.0;
const double _mainRowHeight = 80.0;
const double _actionRowHeight = 44.0;

/// Reusable episode card with fixed-height layout for use in sliver lists.
///
/// Layout:
/// - Main row (80dp): optional thumbnail, title (up to 2 lines), description
/// - Action row (44dp): play pill, date label, action buttons
/// - Vertical padding: 8dp (4dp top + 4dp bottom)
/// - Divider: 1dp
///
/// Total fixed extent: 140dp (80 + 44 + 8 + 1 padding/divider + 7 flex).
class EpisodeCard extends StatelessWidget {
  const EpisodeCard({
    super.key,
    required this.title,
    required this.pillLabel,
    this.dateLabel,
    this.description,
    this.thumbnailUrl,
    this.fallbackThumbnailUrl,
    this.podcastArtworkUrl,
    this.feedImageUrl,
    this.showThumbnail = true,
    this.isPlaying = false,
    this.isLoading = false,
    this.isNew = false,
    this.isCompleted = false,
    this.isInProgress = false,
    this.isCurrentEpisode = false,
    this.progressFraction,
    this.hasTranscript = false,
    this.transcriptLabel,
    this.onTap,
    this.onPlayPause,
    this.onLongPress,
    this.actionButtons = const [],
  });

  final String title;

  /// Pre-formatted state label rendered inside the play pill.
  final String pillLabel;

  /// Pre-formatted publish date rendered next to the pill. Null hides it.
  final String? dateLabel;

  /// Episode description snippet. Shown only when there is vertical space
  /// remaining after the title (similar to Apple Podcasts).
  final String? description;

  /// Episode-specific thumbnail URL.
  final String? thumbnailUrl;

  /// Shown when [thumbnailUrl] is null. Unlike [podcastArtworkUrl] this
  /// is never used for deduplication.
  final String? fallbackThumbnailUrl;

  /// Podcast-level artwork URL (iTunes API). Thumbnail is hidden when it
  /// matches this or [feedImageUrl].
  final String? podcastArtworkUrl;

  /// RSS feed-level image URL. Used alongside [podcastArtworkUrl] for
  /// thumbnail deduplication since the two come from different sources.
  final String? feedImageUrl;

  /// When `false`, the thumbnail is suppressed regardless of any
  /// available URL. Driven by the smart playlist `showThumbnail` /
  /// `showEpisodeThumbnail` flags.
  final bool showThumbnail;

  final bool isPlaying;
  final bool isLoading;

  /// Show "new" badge for unplayed episodes.
  final bool isNew;
  final bool isCompleted;
  final bool isInProgress;
  final bool isCurrentEpisode;

  /// Progress through the episode in `[0.0, 1.0]`. Drives the pill ring
  /// when [isPlaying] or [isInProgress] is true. Null is treated as 0.
  final double? progressFraction;

  /// Whether the episode has a transcript available.
  final bool hasTranscript;

  /// Accessibility label for the transcript indicator.
  final String? transcriptLabel;

  final VoidCallback? onTap;
  final VoidCallback? onPlayPause;
  final VoidCallback? onLongPress;

  /// Action buttons (queue, download, share) shown in the bottom row.
  final List<Widget> actionButtons;

  /// Resolved thumbnail URL, accounting for deduplication against podcast
  /// artwork. Falls back to [fallbackThumbnailUrl] when the primary
  /// thumbnail is null or duplicates the podcast/feed image.
  String? get _displayThumbnailUrl {
    if (thumbnailUrl != null) {
      final deduped =
          _urlPathEquals(thumbnailUrl, podcastArtworkUrl) ||
          _urlPathEquals(thumbnailUrl, feedImageUrl);
      if (!deduped) return thumbnailUrl;
      // Primary thumbnail duplicates podcast artwork -- use fallback.
      return fallbackThumbnailUrl;
    }
    return fallbackThumbnailUrl;
  }

  bool get _showThumbnail => showThumbnail && _displayThumbnailUrl != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: episodeCardExtent,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.xs,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: _mainRowHeight,
                      child: _buildMainRow(context),
                    ),
                    SizedBox(
                      height: _actionRowHeight,
                      child: _buildActionRow(context),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: 1,
              thickness: 0.5,
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.5),
              indent: Spacing.md,
              endIndent: Spacing.md,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainRow(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _buildCenter(theme, colorScheme)),
        if (_showThumbnail) ...[
          const SizedBox(width: Spacing.sm),
          _Thumbnail(url: _displayThumbnailUrl!),
        ],
      ],
    );
  }

  Widget _buildCenter(ThemeData theme, ColorScheme colorScheme) {
    final descColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.7);

    return ClipRect(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.htmlEntityDecode,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: isCurrentEpisode
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: isCurrentEpisode
                  ? colorScheme.primary
                  : isCompleted
                  ? colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                  : null,
            ),
          ),
          Expanded(
            child: description != null && description!.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      _stripHtml(description!),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: descColor,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        EpisodePlayPill(
          label: pillLabel,
          isPlaying: isPlaying,
          isLoading: isLoading,
          isCompleted: isCompleted,
          isInProgress: isInProgress,
          progressFraction: progressFraction,
          onPressed: onPlayPause,
        ),
        if (dateLabel != null) const SizedBox(width: Spacing.sm),
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dateLabel != null)
                Flexible(
                  child: Text(
                    dateLabel!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              if (hasTranscript) ...[
                const SizedBox(width: Spacing.xs),
                _TranscriptBadge(
                  color: colorScheme.onSurfaceVariant,
                  label: transcriptLabel,
                ),
              ],
              if (isNew) ...[
                const SizedBox(width: Spacing.xs),
                _NewBadge(color: colorScheme.primary),
              ],
            ],
          ),
        ),
        ...actionButtons,
      ],
    );
  }
}

/// Compares two URLs by scheme + host + path, ignoring query params and
/// fragments. Returns true when both are non-null and their paths match.
bool _urlPathEquals(String? a, String? b) {
  if (a == null || b == null) return false;
  if (a == b) return true;
  final uriA = Uri.tryParse(a);
  final uriB = Uri.tryParse(b);
  if (uriA == null || uriB == null) return false;
  return uriA.host == uriB.host && uriA.path == uriB.path;
}

final _htmlTagPattern = RegExp(r'<[^>]*>');
final _whitespacePattern = RegExp(r'\s+');

/// Strips HTML tags, decodes entities, and collapses whitespace for
/// plain-text display.
String _stripHtml(String html) {
  return html
      .replaceAll(_htmlTagPattern, ' ')
      .htmlEntityDecode
      .replaceAll(_whitespacePattern, ' ')
      .trim();
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: ExtendedImage.network(
        url,
        width: _thumbnailSize,
        height: _thumbnailSize,
        fit: BoxFit.cover,
        cache: true,
        loadStateChanged: (state) {
          if (state.extendedImageLoadState == LoadState.failed) {
            return Container(
              width: _thumbnailSize,
              height: _thumbnailSize,
              color: colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.podcasts,
                size: 32,
                color: colorScheme.onSurfaceVariant,
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}

class _TranscriptBadge extends StatelessWidget {
  const _TranscriptBadge({required this.color, this.label});

  final Color color;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Icon(Symbols.closed_caption, size: 16, color: color),
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'new',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
