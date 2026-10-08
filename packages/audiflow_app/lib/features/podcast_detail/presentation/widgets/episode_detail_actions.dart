import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'episode_pill_duration_label.dart';

/// Playback state the episode detail primary pill reads (redesign 4.9).
enum EpisodePlayState { unplayed, inProgress, playing, played }

/// Height of the primary pill and diameter of the circular buttons.
const double _actionHeight = 50;

/// Primary play pill of the episode detail action row. Its fill and
/// label follow [state]; it never shows progress itself.
class EpisodePrimaryPill extends StatelessWidget {
  const EpisodePrimaryPill({
    super.key,
    required this.state,
    required this.duration,
    required this.isLoading,
    required this.onPressed,
  });

  @visibleForTesting
  static const Key surfaceKey = ValueKey('episodePrimaryPillSurface');

  final EpisodePlayState state;

  /// Shown on the unplayed label ("Play · 28m") when known.
  final Duration? duration;

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final (background, foreground) = _palette(colors);
    return SizedBox(
      height: _actionHeight,
      child: DecoratedBox(
        key: surfaceKey,
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppBorders.pill,
          boxShadow: state == EpisodePlayState.played
              ? AppShadows.groupedSurface
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: AppBorders.pill,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: _content(context, foreground),
          ),
        ),
      ),
    );
  }

  (Color, Color) _palette(AppColors colors) => switch (state) {
    EpisodePlayState.unplayed ||
    EpisodePlayState.inProgress => (colors.accent, colors.onAccent),
    EpisodePlayState.playing => (colors.accentTint, colors.accent),
    EpisodePlayState.played => (colors.surface, colors.ink),
  };

  Widget _content(BuildContext context, Color foreground) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _leading(foreground),
          const SizedBox(width: Spacing.sm),
          Flexible(
            child: Text(
              _label(AppLocalizations.of(context)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.tabular(
                AppTextStyles.label.copyWith(fontSize: 16, color: foreground),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _leading(Color color) {
    if (isLoading) {
      return SizedBox.square(
        dimension: 18,
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      );
    }
    final icon = switch (state) {
      EpisodePlayState.playing => Icons.pause_rounded,
      EpisodePlayState.played => Icons.replay_rounded,
      _ => Icons.play_arrow_rounded,
    };
    return Icon(icon, size: 24, color: color);
  }

  String _label(AppLocalizations l10n) {
    final known = duration;
    return switch (state) {
      EpisodePlayState.unplayed when known != null && Duration.zero < known =>
        l10n.episodeDetailPlayWithDuration(
          episodePillDurationLabel(known, l10n),
        ),
      EpisodePlayState.unplayed => l10n.episodeDetailPlay,
      EpisodePlayState.inProgress => l10n.episodeDetailResume,
      EpisodePlayState.playing => l10n.episodeDetailPause,
      EpisodePlayState.played => l10n.episodeDetailPlayAgain,
    };
  }
}

/// 50px circular button beside the primary pill: `surface` normally,
/// `accentTint` with an `accent` glyph when [highlighted].
class EpisodeActionCircle extends StatelessWidget {
  const EpisodeActionCircle({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.highlighted = false,
    this.iconColor,
    this.progress,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool highlighted;

  /// Overrides the glyph color (e.g. `error` for a failed download).
  final Color? iconColor;

  /// Draws a ring around the glyph, e.g. download progress. Null hides it.
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final glyph = iconColor ?? (highlighted ? colors.accent : colors.ink);
    return SizedBox.square(
      dimension: _actionHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: highlighted ? colors.accentTint : colors.surface,
          shape: BoxShape.circle,
          boxShadow: highlighted ? null : AppShadows.groupedSurface,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (progress != null)
              SizedBox.square(
                dimension: 34,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 2.5,
                  color: colors.accent,
                  backgroundColor: colors.progressTrack,
                ),
              ),
            IconButton(
              tooltip: tooltip,
              onPressed: onPressed,
              icon: Icon(icon, size: progress == null ? 24 : 16),
              color: glyph,
              constraints: const BoxConstraints.tightFor(
                width: _actionHeight,
                height: _actionHeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Queue circle: a tap opens a two-choice popover under the button,
/// "play next" or "add to end of queue", since the listener picks one.
class EpisodeQueueCircle extends StatelessWidget {
  const EpisodeQueueCircle({
    super.key,
    required this.onPlayNext,
    required this.onAddToEnd,
  });

  final VoidCallback onPlayNext;
  final VoidCallback onAddToEnd;

  @override
  Widget build(BuildContext context) {
    return EpisodeActionCircle(
      icon: Icons.playlist_add_rounded,
      tooltip: AppLocalizations.of(context).addToQueue,
      // This widget's context sizes to the circle, so the popover
      // anchors to the button.
      onPressed: () => _showChoices(context),
    );
  }

  Future<void> _showChoices(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final box = context.findRenderObject()! as RenderBox;
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final bottomLeft = box.localToGlobal(
      box.size.bottomLeft(Offset.zero) + const Offset(0, Spacing.xs),
      ancestor: overlay,
    );
    final chosen = await showMenu<VoidCallback>(
      context: context,
      position: RelativeRect.fromRect(
        bottomLeft & Size(box.size.width, 0),
        Offset.zero & overlay.size,
      ),
      items: [
        _choice(Icons.playlist_play_rounded, l10n.playNext, onPlayNext),
        _choice(
          Icons.playlist_add_rounded,
          l10n.episodeDetailAddToEnd,
          onAddToEnd,
        ),
      ],
    );
    chosen?.call();
  }

  PopupMenuItem<VoidCallback> _choice(
    IconData icon,
    String label,
    VoidCallback action,
  ) {
    return PopupMenuItem(
      value: action,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: Spacing.md),
          Flexible(child: Text(label)),
        ],
      ),
    );
  }
}

/// Download circle: its glyph and ring follow the download task.
class EpisodeDownloadCircle extends StatelessWidget {
  const EpisodeDownloadCircle({
    super.key,
    required this.task,
    required this.onPressed,
  });

  final DownloadTask? task;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = task?.downloadStatus;
    final progress = task?.progress;
    return switch (status) {
      DownloadStatusCompleted() => EpisodeActionCircle(
        icon: Icons.download_rounded,
        tooltip: l10n.removeDownload,
        highlighted: true,
        onPressed: onPressed,
      ),
      DownloadStatusDownloading() => EpisodeActionCircle(
        icon: Icons.pause_rounded,
        tooltip: l10n.downloadStatusDownloading,
        progress: progress,
        onPressed: onPressed,
      ),
      DownloadStatusPaused() => EpisodeActionCircle(
        icon: Icons.play_arrow_rounded,
        tooltip: l10n.downloadStatusPaused,
        progress: progress ?? 0,
        onPressed: onPressed,
      ),
      DownloadStatusPending() => EpisodeActionCircle(
        icon: Icons.schedule_rounded,
        tooltip: l10n.downloadStatusPending,
        onPressed: onPressed,
      ),
      DownloadStatusFailed() => EpisodeActionCircle(
        icon: Icons.error_outline_rounded,
        tooltip: l10n.downloadStatusFailed,
        iconColor: Theme.of(context).colorScheme.error,
        onPressed: onPressed,
      ),
      _ => EpisodeActionCircle(
        icon: Icons.download_rounded,
        tooltip: l10n.downloadEpisode,
        onPressed: onPressed,
      ),
    };
  }
}

/// Standalone progress line under the action row (redesign 4.9 / 3.1):
/// a full-width 3px line with the remaining time, or a played mark with
/// the line full. Callers hide it while the episode is unplayed.
class EpisodeProgressStatus extends StatelessWidget {
  const EpisodeProgressStatus({
    super.key,
    required this.fraction,
    required this.remaining,
    required this.isCompleted,
  });

  final double fraction;
  final Duration? remaining;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ProgressLine.thickness / 2),
            child: ProgressLine(
              fraction: isCompleted ? 1 : fraction,
              trackColor: colors.progressTrack,
            ),
          ),
        ),
        const SizedBox(width: Spacing.rowVertical),
        _status(AppLocalizations.of(context), colors),
      ],
    );
  }

  Widget _status(AppLocalizations l10n, AppColors colors) {
    final style = AppTextStyles.tabular(AppTextStyles.caption);
    if (isCompleted) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 14, color: colors.accent),
          const SizedBox(width: Spacing.xxs),
          Text(
            l10n.episodePillCompleted,
            style: style.copyWith(
              color: colors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }
    final left = remaining;
    if (left == null) return const SizedBox.shrink();
    return Text(
      l10n.episodePillRemaining(episodePillDurationLabel(left, l10n)),
      style: style.copyWith(color: colors.inkTertiary),
    );
  }
}
