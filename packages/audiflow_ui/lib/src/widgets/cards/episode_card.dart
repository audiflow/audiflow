import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../haptics/haptic_long_press.dart';
import '../../haptics/haptics_scope.dart';
import '../../styles/borders.dart';
import '../../styles/spacing.dart';
import '../../themes/app_colors.dart';
import '../../themes/text_styles.dart';
import '../artwork_image.dart';
import '../buttons/episode_play_pill.dart';
import '../indicators/progress_line.dart';

const double _thumbnailSize = 56.0;
const double _actionRowHeight = 44.0;

/// Full-year dates for every month, the widest forms `formatEpisodeDate`
/// produces; month names differ in width, so no single date covers all.
List<String> _fullYearDateSamples() => [
  for (var month = 1; month <= 12; month++)
    DateTime(2000, month, 28).formatEpisodeDate(),
];

final Map<String, double> _dateSlotWidthCache = {};

/// Width of the widest full-year date in [style], cached per locale
/// output, font size, and text scale since every row asks for it.
double _dateSlotWidth(TextStyle style, TextScaler textScaler) {
  final samples = _fullYearDateSamples();
  final key = '${samples.join('|')}|${style.fontSize}|${textScaler.scale(1)}';
  return _dateSlotWidthCache.putIfAbsent(key, () {
    var widest = 0.0;
    for (final sample in samples) {
      final painter = TextPainter(
        text: TextSpan(text: sample, style: style),
        maxLines: 1,
        textScaler: textScaler,
        textDirection: TextDirection.ltr,
      )..layout();
      if (widest < painter.width) widest = painter.width;
      painter.dispose();
    }
    return widest.ceilToDouble();
  });
}

/// Episode row (redesign 4.2): date line (accent dot when new), title,
/// description, artwork on the right, then the action row with the play
/// pill and the caller's actions. Played episodes fade their title and
/// artwork; a bottom-edge line shows progress once playback has started.
///
/// Height follows the content, so a short title leaves no gap between the
/// text and the action row; rows run full width and end in a hairline.
class EpisodeCard extends StatelessWidget {
  const EpisodeCard({
    super.key,
    required this.title,
    required this.pillLabel,
    this.dateLabel,
    this.numberLabel,
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

  /// Episode number label (e.g. "#12") for series lists, where order
  /// matters more than recency: it takes the date's place above the
  /// title and the date moves next to the play pill.
  final String? numberLabel;

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
    return BottomEdgeProgress(
      fraction: _edgeProgress,
      inset: Spacing.screenHorizontal,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.screenHorizontal,
              Spacing.md - Spacing.xxs,
              Spacing.screenHorizontal,
              Spacing.xs,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  // Long presses play the catalog token; the framework's vibration
                  // would double up, and wrapForTap keeps the Android click sound.
                  enableFeedback: false,
                  onTap: Feedback.wrapForTap(onTap, context),
                  onLongPress: HapticsScope.of(
                    context,
                  ).longPressHaptic(onLongPress),
                  child: _mainArea(colors),
                ),
                const SizedBox(height: Spacing.xs),
                SizedBox(
                  height: _actionRowHeight,
                  child: _actionRow(context, colors),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: colors.hairline,
            indent: Spacing.screenHorizontal,
          ),
        ],
      ),
    );
  }

  Widget _mainArea(AppColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dateRow(colors),
              const SizedBox(height: Spacing.xs),
              _textBlock(colors),
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
        if (numberLabel ?? dateLabel case final label?)
          Flexible(
            child: Text(
              label,
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
    // A two-line preview has no room for decorative rules (section 5).
    final text = description?.withoutSeparatorRuns.htmlToPlainText.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.htmlEntityDecode,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.rowTitle.copyWith(color: titleColor),
        ),
        if (text.isNotEmpty) ...[
          const SizedBox(height: Spacing.xxs),
          Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.meta.copyWith(
              color: isCompleted ? colors.inkTertiary : colors.inkSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _actionRow(BuildContext context, AppColors colors) {
    final date = numberLabel == null ? null : dateLabel;
    return Row(
      children: [
        EpisodePlayPill(
          label: pillLabel,
          isPlaying: isPlaying,
          isLoading: isLoading,
          isCompleted: isCompleted,
          onPressed: onPlayPause,
        ),
        if (date != null) ...[
          const SizedBox(width: Spacing.sm),
          // The gap shrinks with the date on narrow phones instead of
          // pushing the buttons off the row.
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(right: Spacing.md),
              child: _dateSlot(context, date, colors),
            ),
          ),
        ] else
          const SizedBox(width: Spacing.md),
        ...actionButtons,
      ],
    );
  }

  /// Reserves the width of the widest date format so the action buttons
  /// that follow line up across rows ("Today" vs "Dec 28, 2025"), rather
  /// than drifting with each label or hugging the far edge on wide screens.
  /// A label wider than the slot ellipsizes instead of widening it.
  Widget _dateSlot(BuildContext context, String date, AppColors colors) {
    final style = AppTextStyles.caption.copyWith(color: colors.inkTertiary);
    return SizedBox(
      width: _dateSlotWidth(style, MediaQuery.textScalerOf(context)),
      child: Text(
        date,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
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
