import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'sleep_timer_numeric_panel.dart';

enum _SheetPanel { menu, minutes, episodes }

/// Sheet body for the sleep-timer feature.
///
/// Presents the menu on first open; swaps to the numeric panel when the
/// user taps "Set minutes" / "Set episodes" (first time) or long-presses
/// a remembered value. Short-tap on a remembered value fires the
/// corresponding onStart callback immediately.
class SleepTimerSheet extends StatefulWidget {
  const SleepTimerSheet({
    required this.state,
    required this.hasChapters,
    required this.onOff,
    required this.onEndOfEpisode,
    required this.onEndOfChapter,
    required this.onDurationStart,
    required this.onEpisodesStart,
    super.key,
  });

  final SleepTimerState state;
  final bool hasChapters;
  final VoidCallback onOff;
  final VoidCallback onEndOfEpisode;
  final VoidCallback onEndOfChapter;
  final ValueChanged<Duration> onDurationStart;
  final ValueChanged<int> onEpisodesStart;

  @override
  State<SleepTimerSheet> createState() => _SleepTimerSheetState();
}

class _SleepTimerSheetState extends State<SleepTimerSheet> {
  _SheetPanel _panel = _SheetPanel.menu;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    switch (_panel) {
      case _SheetPanel.menu:
        return _MenuPanel(
          l10n: l10n,
          state: widget.state,
          hasChapters: widget.hasChapters,
          onOff: widget.onOff,
          onEndOfEpisode: widget.onEndOfEpisode,
          onEndOfChapter: widget.onEndOfChapter,
          onShortTapMinutes: () {
            if (widget.state.lastMinutes == 0) {
              setState(() => _panel = _SheetPanel.minutes);
            } else {
              widget.onDurationStart(
                Duration(minutes: widget.state.lastMinutes),
              );
            }
          },
          onLongPressMinutes: () =>
              setState(() => _panel = _SheetPanel.minutes),
          onShortTapEpisodes: () {
            if (widget.state.lastEpisodes == 0) {
              setState(() => _panel = _SheetPanel.episodes);
            } else {
              widget.onEpisodesStart(widget.state.lastEpisodes);
            }
          },
          onLongPressEpisodes: () =>
              setState(() => _panel = _SheetPanel.episodes),
        );
      case _SheetPanel.minutes:
        return SleepTimerNumericPanel(
          title: l10n.sleepTimerNumericMinutesTitle,
          initialValue: widget.state.lastMinutes,
          maxValue: 999,
          startLabel: l10n.sleepTimerStart,
          onBack: () => setState(() => _panel = _SheetPanel.menu),
          onClose: () => Navigator.of(context).maybePop(),
          onStart: (v) => widget.onDurationStart(Duration(minutes: v)),
        );
      case _SheetPanel.episodes:
        return SleepTimerNumericPanel(
          title: l10n.sleepTimerNumericEpisodesTitle,
          initialValue: widget.state.lastEpisodes,
          maxValue: 99,
          startLabel: l10n.sleepTimerStart,
          onBack: () => setState(() => _panel = _SheetPanel.menu),
          onClose: () => Navigator.of(context).maybePop(),
          onStart: widget.onEpisodesStart,
        );
    }
  }
}

class _MenuPanel extends StatelessWidget {
  const _MenuPanel({
    required this.l10n,
    required this.state,
    required this.hasChapters,
    required this.onOff,
    required this.onEndOfEpisode,
    required this.onEndOfChapter,
    required this.onShortTapMinutes,
    required this.onLongPressMinutes,
    required this.onShortTapEpisodes,
    required this.onLongPressEpisodes,
  });

  final AppLocalizations l10n;
  final SleepTimerState state;
  final bool hasChapters;
  final VoidCallback onOff;
  final VoidCallback onEndOfEpisode;
  final VoidCallback onEndOfChapter;
  final VoidCallback onShortTapMinutes;
  final VoidCallback onLongPressMinutes;
  final VoidCallback onShortTapEpisodes;
  final VoidCallback onLongPressEpisodes;

  bool get _isOff => state.config is SleepTimerConfigOff;
  bool get _isEndOfEpisode => state.config is SleepTimerConfigEndOfEpisode;
  bool get _isEndOfChapter => state.config is SleepTimerConfigEndOfChapter;
  bool get _isDuration => state.config is SleepTimerConfigDuration;
  bool get _isEpisodes => state.config is SleepTimerConfigEpisodes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dimColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.sleepTimerTitle,
              style: theme.textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.close,
              color: _isOff ? dimColor : theme.colorScheme.error,
            ),
            title: Text(
              l10n.sleepTimerOff,
              style: TextStyle(
                color: _isOff ? dimColor : theme.colorScheme.error,
              ),
            ),
            enabled: !_isOff,
            onTap: _isOff ? null : onOff,
          ),
          ListTile(
            leading: _isEndOfEpisode
                ? const Icon(Icons.check)
                : const SizedBox(width: 24),
            title: Text(l10n.sleepTimerEndOfEpisode),
            onTap: onEndOfEpisode,
          ),
          if (hasChapters)
            ListTile(
              leading: _isEndOfChapter
                  ? const Icon(Icons.check)
                  : const SizedBox(width: 24),
              title: Text(l10n.sleepTimerEndOfChapter),
              onTap: onEndOfChapter,
            ),
          ListTile(
            leading: _isDuration
                ? const Icon(Icons.check)
                : const SizedBox(width: 24),
            title: Text(
              state.lastMinutes == 0
                  ? l10n.sleepTimerSetMinutes
                  : l10n.sleepTimerMinutesLabel(state.lastMinutes),
            ),
            trailing: state.lastMinutes == 0
                ? null
                : IconButton(
                    icon: Icon(Icons.edit_outlined, size: 16, color: dimColor),
                    tooltip: l10n.sleepTimerNumericMinutesTitle,
                    onPressed: onLongPressMinutes,
                  ),
            onTap: onShortTapMinutes,
            onLongPress: onLongPressMinutes,
          ),
          ListTile(
            leading: _isEpisodes
                ? const Icon(Icons.check)
                : const SizedBox(width: 24),
            title: Text(
              state.lastEpisodes == 0
                  ? l10n.sleepTimerSetEpisodes
                  : l10n.sleepTimerEpisodesLabel(state.lastEpisodes),
            ),
            trailing: state.lastEpisodes == 0
                ? null
                : IconButton(
                    icon: Icon(Icons.edit_outlined, size: 16, color: dimColor),
                    tooltip: l10n.sleepTimerNumericEpisodesTitle,
                    onPressed: onLongPressEpisodes,
                  ),
            onTap: onShortTapEpisodes,
            onLongPress: onLongPressEpisodes,
          ),
        ],
      ),
    );
  }
}
