import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/duration_label.dart';

/// "Playback history" grouped list (redesign 4.9). Title, podcast,
/// duration and publish date are left to the hero.
class EpisodePlaybackRecord extends StatelessWidget {
  const EpisodePlaybackRecord({super.key, required this.history});

  /// Shown before the first play in place of counts and durations.
  static const String noValue = '—';

  final PlaybackHistory? history;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dates = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    );
    final record = history;
    String count(int Function(PlaybackHistory) of) =>
        record == null ? noValue : l10n.episodeDetailTimes(of(record));
    String time(int Function(PlaybackHistory) of) => record == null
        ? noValue
        : l10n.durationLabel(Duration(milliseconds: of(record)));
    String date(DateTime? value) =>
        value == null ? l10n.statsNever : dates.format(value);

    return GroupedSection(
      header: l10n.episodeDetailPlaybackRecord,
      separatorIndent: 0,
      children: [
        _RecordRow(
          label: l10n.statsTimesCompleted,
          value: count((h) => h.completedCount),
        ),
        _RecordRow(
          label: l10n.statsTimesStarted,
          value: count((h) => h.playCount),
        ),
        _RecordRow(
          label: l10n.statsTotalListened,
          value: time((h) => h.totalListenedMs),
        ),
        _RecordRow(
          label: l10n.statsRealtime,
          value: time((h) => h.totalRealtimeMs),
        ),
        _RecordRow(
          label: l10n.statsFirstPlayed,
          value: date(record?.firstPlayedAt),
        ),
        _RecordRow(
          label: l10n.statsLastPlayed,
          value: date(record?.lastPlayedAt),
        ),
      ],
    );
  }
}

/// Label / value row; a long press copies the value.
class _RecordRow extends StatelessWidget {
  const _RecordRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return InkWell(
      // Long presses play the catalog token; the framework's vibration
      // would double up, and wrapForTap keeps the Android click sound.
      enableFeedback: false,
      onLongPress: HapticsScope.of(
        context,
      ).longPressHaptic(() => _copy(context)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 50),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.rowHorizontal + Spacing.xs,
            vertical: Spacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.body.copyWith(color: colors.ink),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Text(
                value,
                style: AppTextStyles.tabular(
                  AppTextStyles.body.copyWith(
                    color: colors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _copy(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = AppLocalizations.of(context).commonCopiedToClipboard;
    await Clipboard.setData(ClipboardData(text: value));
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}
