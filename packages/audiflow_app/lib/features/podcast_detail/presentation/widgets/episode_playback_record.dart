import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/duration_label.dart';
import 'detail_hero_layout.dart';

part 'episode_playback_record.freezed.dart';

/// "Playback history" grouped list (redesign 4.9). Title, podcast,
/// duration and publish date are left to the hero.
///
/// Follows the episode's history live, rebuilding only when a shown value
/// changes; the rest of episode detail does not watch it.
class EpisodePlaybackRecord extends ConsumerWidget {
  const EpisodePlaybackRecord({
    super.key,
    required this.episodeId,
    this.history,
  });

  /// Shown before the first play in place of counts and durations.
  static const String noValue = '—';

  /// The saved episode whose history is followed; null for an episode not
  /// saved yet, which shows [history] as is.
  final int? episodeId;

  /// Snapshot shown until the live history first arrives.
  final PlaybackHistory? history;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final record = _watchRecord(ref);
    final header = AppLocalizations.of(context).episodeDetailPlaybackRecord;
    final totals = _totalRows(AppLocalizations.of(context), record);
    final dates = _dateRows(context, record);
    if (!DetailHeroLayout.isSideBySide(context)) {
      return GroupedSection(
        header: header,
        separatorIndent: 0,
        children: [...totals, ...dates],
      );
    }
    return _TabletPlaybackRecord(header: header, totals: totals, dates: dates);
  }

  List<Widget> _totalRows(AppLocalizations l10n, PlaybackRecordValues? record) {
    String count(int Function(PlaybackRecordValues) of) =>
        record == null ? noValue : l10n.episodeDetailTimes(of(record));
    String time(int Function(PlaybackRecordValues) of) => record == null
        ? noValue
        : l10n.durationLabel(Duration(minutes: of(record)));
    return [
      _RecordRow(
        label: l10n.statsTimesCompleted,
        value: count((r) => r.completedCount),
      ),
      _RecordRow(
        label: l10n.statsTimesStarted,
        value: count((r) => r.playCount),
      ),
      _RecordRow(
        label: l10n.statsTotalListened,
        value: time((r) => r.listenedMinutes),
      ),
      _RecordRow(
        label: l10n.statsRealtime,
        value: time((r) => r.realtimeMinutes),
      ),
    ];
  }

  List<Widget> _dateRows(BuildContext context, PlaybackRecordValues? record) {
    final l10n = AppLocalizations.of(context);
    final dates = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    );
    String date(DateTime? value) =>
        value == null ? l10n.statsNever : dates.format(value);
    return [
      _RecordRow(
        label: l10n.statsFirstPlayed,
        value: date(record?.firstPlayedDay),
      ),
      _RecordRow(
        label: l10n.statsLastPlayed,
        value: date(record?.lastPlayedDay),
      ),
    ];
  }

  /// Every progress save emits a new history; selecting the shown values
  /// keeps those saves from rebuilding the section until a label changes.
  /// The snapshot stands in while the live history loads or has failed.
  PlaybackRecordValues? _watchRecord(WidgetRef ref) {
    final id = episodeId;
    if (id == null) return PlaybackRecordValues.of(history);
    return ref.watch(
      episodePlaybackHistoryProvider(id).select(
        (live) => PlaybackRecordValues.of(live.hasValue ? live.value : history),
      ),
    );
  }
}

/// What the playback record shows, at the resolution it is shown:
/// durations in whole minutes ([DurationLabel.durationLabel] truncates)
/// and dates as calendar days ([DateFormat.yMMMd]). Equal values render
/// identically, which is what lets the record skip rebuilds.
@freezed
sealed class PlaybackRecordValues with _$PlaybackRecordValues {
  const factory PlaybackRecordValues({
    required int completedCount,
    required int playCount,
    required int listenedMinutes,
    required int realtimeMinutes,
    required DateTime? firstPlayedDay,
    required DateTime? lastPlayedDay,
  }) = _PlaybackRecordValues;

  /// Null before the first play, when there is no history.
  static PlaybackRecordValues? of(PlaybackHistory? history) {
    if (history == null) return null;
    return PlaybackRecordValues(
      completedCount: history.completedCount,
      playCount: history.playCount,
      listenedMinutes: _minutes(history.totalListenedMs),
      realtimeMinutes: _minutes(history.totalRealtimeMs),
      firstPlayedDay: _day(history.firstPlayedAt),
      lastPlayedDay: _day(history.lastPlayedAt),
    );
  }

  static int _minutes(int milliseconds) =>
      Duration(milliseconds: milliseconds).inMinutes;

  static DateTime? _day(DateTime? value) =>
      value == null ? null : DateTime(value.year, value.month, value.day);
}

/// Tablet layout: label / value rows stretched across a tablet-wide screen
/// put the value too far from its label, so the record keeps to a
/// readable width at the start edge. Totals and dates sit in two columns
/// when both fit, and stack in one capped column otherwise.
class _TabletPlaybackRecord extends StatelessWidget {
  const _TabletPlaybackRecord({
    required this.header,
    required this.totals,
    required this.dates,
  });

  /// Widest a column grows; wider, the value drifts away from its label.
  static const double _columnMaxWidth = 360;

  /// Narrowest column that still fits a label and its value on one line.
  static const double _columnMinWidth = 280;

  static const double _columnGap = Spacing.md;

  final String header;
  final List<Widget> totals;
  final List<Widget> dates;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.screenHorizontal),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const twoColumnsMinWidth = 2 * _columnMinWidth + _columnGap;
          if (constraints.maxWidth < twoColumnsMinWidth) {
            return _singleColumn();
          }
          final width = (constraints.maxWidth - _columnGap) / 2;
          return _twoColumns(width < _columnMaxWidth ? width : _columnMaxWidth);
        },
      ),
    );
  }

  Widget _singleColumn() {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: LayoutConstants.contentMaxWidth,
        ),
        child: _section([...totals, ...dates], header: header),
      ),
    );
  }

  Widget _twoColumns(double columnWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GroupedSectionHeader(text: header),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: columnWidth, child: _section(totals)),
            const SizedBox(width: _columnGap),
            SizedBox(width: columnWidth, child: _section(dates)),
          ],
        ),
      ],
    );
  }

  /// The outer padding already holds the screen gutter.
  static Widget _section(List<Widget> rows, {String? header}) {
    return GroupedSection(
      header: header,
      separatorIndent: 0,
      margin: EdgeInsets.zero,
      children: rows,
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
              // Large text in a narrow row ("123時間45分" at 2x in a 280pt
              // tablet column) would overflow; the value wraps instead.
              // Expanded, not Flexible, so every value ends at the row's
              // trailing edge.
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: AppTextStyles.tabular(
                    AppTextStyles.body.copyWith(
                      color: colors.ink,
                      fontWeight: FontWeight.w600,
                    ),
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
