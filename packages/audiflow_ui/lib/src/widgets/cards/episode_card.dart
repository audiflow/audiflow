import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../styles/borders.dart';
import '../../styles/spacing.dart';
import '../../themes/app_colors.dart';
import '../../themes/text_styles.dart';
import '../artwork_image.dart';
import '../buttons/episode_play_pill.dart';
import '../indicators/progress_line.dart';

const double _thumbnailSize = 56.0;
const double _paddingTop = 12.0;
const double _dateRowHeight = 18.0;
const double _textGap = 4.0;

/// Title and description share this block: the title takes up to three
/// lines and the description fills what is left, up to two lines.
const double _textBlockHeight = 84.0;
const double _actionRowHeight = 44.0;
const double _paddingBottom = 4.0;

/// Fixed height of an episode row, used as `itemExtent` in sliver lists so
/// long back catalogues scroll without measuring every row.
const double episodeCardExtent =
    _paddingTop +
    _dateRowHeight +
    _textGap +
    _textBlockHeight +
    _textGap +
    _actionRowHeight +
    _paddingBottom +
    1;

/// Episode row (redesign 4.2): date line (accent dot when new), title,
/// description, artwork on the right, then the action row with the play
/// pill and the caller's actions. Played episodes fade their title and
/// artwork; a bottom-edge line shows progress once playback has started.
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
    this.newLabel,
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

  @visibleForTesting
  static const Key newDotKey = ValueKey('episodeCardNewDot');

  final String title;

  /// Pre-formatted state label rendered inside the play pill.
  final String pillLabel;

  /// Pre-formatted publish date shown above the title. Null hides it.
  final String? dateLabel;

  /// Episode description snippet, shown in the space the title leaves.
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

  /// Marks an unplayed episode published since the last refresh.
  final bool isNew;

  /// Screen-reader label for the new-episode dot.
  final String? newLabel;
  final bool isCompleted;
  final bool isInProgress;
  final bool isCurrentEpisode;

  /// Progress through the episode in `[0.0, 1.0]`. Drawn as a bottom-edge
  /// line while [isInProgress]; [isCompleted] always draws it full.
  final double? progressFraction;

  /// Whether the episode has a transcript available.
  final bool hasTranscript;

  /// Accessibility label for the transcript indicator.
  final String? transcriptLabel;

  final VoidCallback? onTap;
  final VoidCallback? onPlayPause;
  final VoidCallback? onLongPress;

  /// Action buttons (queue, download, more) at the end of the action row.
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

  double? get _edgeProgress {
    if (isCompleted) return 1;
    return isInProgress ? progressFraction : null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SizedBox(
      height: episodeCardExtent,
      child: BottomEdgeProgress(
        fraction: _edgeProgress,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.rowHorizontal,
                  _paddingTop,
                  Spacing.rowHorizontal,
                  _paddingBottom,
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: onTap,
                      onLongPress: onLongPress,
                      child: _mainArea(colors),
                    ),
                    const SizedBox(height: _textGap),
                    SizedBox(height: _actionRowHeight, child: _actionRow()),
                  ],
                ),
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: colors.hairline,
              indent: Spacing.rowHorizontal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _mainArea(AppColors colors) {
    return SizedBox(
      height: _dateRowHeight + _textGap + _textBlockHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: _dateRowHeight, child: _dateRow(colors)),
                const SizedBox(height: _textGap),
                SizedBox(height: _textBlockHeight, child: _textBlock(colors)),
              ],
            ),
          ),
          if (_showThumbnail) ...[
            const SizedBox(width: Spacing.sm + Spacing.xs),
            Opacity(
              opacity: isCompleted ? 0.5 : 1,
              child: _Thumbnail(url: _displayThumbnailUrl!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dateRow(AppColors colors) {
    return Row(
      children: [
        if (isNew) ...[
          Semantics(
            label: newLabel,
            child: SizedBox.square(
              dimension: 6,
              child: DecoratedBox(
                key: newDotKey,
                decoration: BoxDecoration(
                  color: colors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: Spacing.xs + Spacing.xxs),
        ],
        if (dateLabel != null)
          Flexible(
            child: Text(
              dateLabel!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(color: colors.inkTertiary),
            ),
          ),
        if (hasTranscript) ...[
          const SizedBox(width: Spacing.xs),
          Semantics(
            label: transcriptLabel,
            child: Icon(
              Symbols.closed_caption,
              size: 16,
              color: colors.inkTertiary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _textBlock(AppColors colors) {
    final titleColor = isCurrentEpisode
        ? colors.accent
        : isCompleted
        ? colors.inkTertiary
        : colors.ink;
    final titleStyle = AppTextStyles.rowTitle.copyWith(color: titleColor);
    final descriptionStyle = AppTextStyles.meta.copyWith(
      color: isCompleted ? colors.inkTertiary : colors.inkSecondary,
    );
    final text = description?.htmlToPlainText.trim() ?? '';
    return LayoutBuilder(
      builder: (context, constraints) {
        final titleText = title.htmlEntityDecode;
        final titleHeight = _measure(
          titleText,
          titleStyle,
          3,
          constraints.maxWidth,
          context,
        );
        final lineHeight = _measure(
          'A',
          descriptionStyle,
          1,
          constraints.maxWidth,
          context,
        );
        // Whole description lines that fit under the title, at most two.
        final room = constraints.maxHeight - titleHeight - Spacing.xxs;
        final descriptionLines = text.isEmpty || lineHeight <= 0
            ? 0
            : (room / lineHeight).floor().clamp(0, 2);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titleText,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: titleStyle,
            ),
            if (0 < descriptionLines) ...[
              const SizedBox(height: Spacing.xxs),
              Text(
                text,
                maxLines: descriptionLines,
                overflow: TextOverflow.ellipsis,
                style: descriptionStyle,
              ),
            ],
          ],
        );
      },
    );
  }

  static double _measure(
    String text,
    TextStyle style,
    int maxLines,
    double width,
    BuildContext context,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: width);
    final height = painter.height;
    painter.dispose();
    return height;
  }

  Widget _actionRow() {
    return Row(
      children: [
        EpisodePlayPill(
          label: pillLabel,
          isPlaying: isPlaying,
          isLoading: isLoading,
          isCompleted: isCompleted,
          onPressed: onPlayPause,
        ),
        const Spacer(),
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

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return ClipRRect(
      borderRadius: AppBorders.artworkList,
      child: ArtworkImage(
        url: url,
        width: _thumbnailSize,
        height: _thumbnailSize,
        loading: const ArtworkLoadingIndicator(),
        placeholder: Container(
          width: _thumbnailSize,
          height: _thumbnailSize,
          color: colors.surfaceSunken,
          child: Icon(Icons.podcasts, size: 24, color: colors.inkQuaternary),
        ),
      ),
    );
  }
}
