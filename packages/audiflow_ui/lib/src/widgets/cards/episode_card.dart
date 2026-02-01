import 'package:flutter/material.dart';

import '../../styles/spacing.dart';

/// Fixed height for the episode card, used as itemExtent in sliver lists.
const double episodeCardExtent = 116.0;

const double _thumbnailSize = 64.0;
const double _mainRowHeight = 64.0;
const double _actionRowHeight = 36.0;
const double _playButtonSize = 48.0;

/// Reusable episode card with fixed-height layout for use in sliver lists.
///
/// Layout:
/// - Main row (72dp): optional thumbnail, title (up to 3 lines), metadata,
///   play/pause button
/// - Action row (36dp): centered action buttons (queue, download, share)
///
/// Total fixed extent: 120dp (72 + 36 + 12 padding).
class EpisodeCard extends StatelessWidget {
  const EpisodeCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.description,
    this.thumbnailUrl,
    this.podcastArtworkUrl,
    this.feedImageUrl,
    this.isPlaying = false,
    this.isLoading = false,
    this.isNew = false,
    this.isCompleted = false,
    this.isCurrentEpisode = false,
    this.onTap,
    this.onPlayPause,
    this.onLongPress,
    this.actionButtons = const [],
  });

  final String title;

  /// Date + duration string shown below the title.
  final String subtitle;

  /// Episode description snippet. Shown only when there is vertical space
  /// remaining after the title (similar to Apple Podcasts).
  final String? description;

  /// Episode-specific thumbnail URL.
  final String? thumbnailUrl;

  /// Podcast-level artwork URL (iTunes API). Thumbnail is hidden when it
  /// matches this or [feedImageUrl].
  final String? podcastArtworkUrl;

  /// RSS feed-level image URL. Used alongside [podcastArtworkUrl] for
  /// thumbnail deduplication since the two come from different sources.
  final String? feedImageUrl;

  final bool isPlaying;
  final bool isLoading;

  /// Show "new" badge for unplayed episodes.
  final bool isNew;
  final bool isCompleted;
  final bool isCurrentEpisode;

  final VoidCallback? onTap;
  final VoidCallback? onPlayPause;
  final VoidCallback? onLongPress;

  /// Action buttons (queue, download, share) shown in the bottom row.
  final List<Widget> actionButtons;

  bool get _showThumbnail =>
      thumbnailUrl != null &&
      !_urlPathEquals(thumbnailUrl, podcastArtworkUrl) &&
      !_urlPathEquals(thumbnailUrl, feedImageUrl);

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
        if (_showThumbnail) ...[
          _Thumbnail(url: thumbnailUrl!),
          const SizedBox(width: Spacing.sm),
        ],
        Expanded(child: _buildCenter(theme, colorScheme)),
        _buildPlayButton(colorScheme),
      ],
    );
  }

  Widget _buildCenter(ThemeData theme, ColorScheme colorScheme) {
    final descColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title pinned to top.
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: isCurrentEpisode ? FontWeight.bold : FontWeight.normal,
            color: isCurrentEpisode
                ? colorScheme.primary
                : isCompleted
                ? colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                : null,
          ),
        ),
        // Description fills remaining space; naturally hidden when the title
        // consumes all vertical room (same behaviour as Apple Podcasts).
        Expanded(
          child: description != null && description!.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    _stripHtml(description!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: descColor,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        // Metadata row pinned to bottom.
        const SizedBox(height: 3),
        Row(
          children: [
            Flexible(
              child: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (isNew) ...[
              const SizedBox(width: Spacing.sm),
              _NewBadge(color: colorScheme.primary),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildPlayButton(ColorScheme colorScheme) {
    if (isLoading) {
      return const SizedBox(
        width: _playButtonSize,
        height: _playButtonSize,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return IconButton(
      icon: Icon(
        isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
        size: 40,
      ),
      color: colorScheme.primary,
      onPressed: onPlayPause,
    );
  }

  Widget _buildActionRow(BuildContext context) {
    if (actionButtons.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: actionButtons,
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

/// Strips HTML tags and collapses whitespace for plain-text display.
String _stripHtml(String html) {
  return html
      .replaceAll(_htmlTagPattern, ' ')
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
      child: Image.network(
        url,
        width: _thumbnailSize,
        height: _thumbnailSize,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: _thumbnailSize,
          height: _thumbnailSize,
          color: colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.podcasts,
            size: 32,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
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
