import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'sleep_timer_numeric_panel.dart';
import 'sleep_timer_sheet_status_line.dart';

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
    required this.onCloseSheet,
    super.key,
  });

  final SleepTimerState state;
  final bool hasChapters;
  final VoidCallback onOff;
  final VoidCallback onEndOfEpisode;
  final VoidCallback onEndOfChapter;
  final ValueChanged<Duration> onDurationStart;
  final ValueChanged<int> onEpisodesStart;
  final VoidCallback onCloseSheet;

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
          onClose: widget.onCloseSheet,
          onStart: (v) => widget.onDurationStart(Duration(minutes: v)),
        );
      case _SheetPanel.episodes:
        return SleepTimerNumericPanel(
          title: l10n.sleepTimerNumericEpisodesTitle,
          initialValue: widget.state.lastEpisodes,
          maxValue: 99,
          startLabel: l10n.sleepTimerStart,
          onBack: () => setState(() => _panel = _SheetPanel.menu),
          onClose: widget.onCloseSheet,
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

  bool get _isActive => state.config is! SleepTimerConfigOff;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildStopOnCard(),
            const SizedBox(height: 12),
            _buildStopAfterCard(),
            if (_isActive) ...[
              const SizedBox(height: 16),
              _CancelButton(label: l10n.commonCancel, onPressed: onOff),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(l10n.sleepTimerTitle, style: theme.textTheme.titleMedium),
        if (_isActive) ...[
          const SizedBox(height: 4),
          SleepTimerSheetStatusLine(config: state.config),
        ],
      ],
    );
  }

  Widget _buildStopOnCard() {
    return _OptionCard(
      header: l10n.sleepTimerStopOnHeader,
      children: [
        _OptionTile(
          label: l10n.sleepTimerEndOfEpisode,
          isActive: state.config is SleepTimerConfigEndOfEpisode,
          onTap: onEndOfEpisode,
        ),
        if (hasChapters)
          _OptionTile(
            label: l10n.sleepTimerEndOfChapter,
            isActive: state.config is SleepTimerConfigEndOfChapter,
            onTap: onEndOfChapter,
          ),
      ],
    );
  }

  Widget _buildStopAfterCard() {
    final minutes = state.lastMinutes;
    final episodes = state.lastEpisodes;
    return _OptionCard(
      header: l10n.sleepTimerStopAfterHeader,
      children: [
        _OptionTile(
          label: minutes == 0
              ? l10n.sleepTimerSetMinutes
              : l10n.sleepTimerMinutesLabel(minutes),
          isActive: state.config is SleepTimerConfigDuration,
          onTap: onShortTapMinutes,
          onLongPress: onLongPressMinutes,
          editLabel: minutes == 0 ? null : l10n.sleepTimerEdit,
        ),
        _OptionTile(
          label: episodes == 0
              ? l10n.sleepTimerSetEpisodes
              : l10n.sleepTimerEpisodesLabel(episodes),
          isActive: state.config is SleepTimerConfigEpisodes,
          onTap: onShortTapEpisodes,
          onLongPress: onLongPressEpisodes,
          editLabel: episodes == 0 ? null : l10n.sleepTimerEdit,
        ),
      ],
    );
  }
}

/// Rounded card grouping related sleep-timer options under a small header.
class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.header, required this.children});

  final String header;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            header,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHigh,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

/// One option row inside an [_OptionCard]. The active option is
/// highlighted and carries a check mark.
///
/// [onLongPress] opens the numeric keypad. When [editLabel] is non-null
/// (a value is remembered) a trailing "Edit" control does the same, so
/// the keypad stays discoverable without knowing about long press.
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.onLongPress,
    this.editLabel,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final String? editLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      selected: isActive,
      selectedColor: colorScheme.onSecondaryContainer,
      selectedTileColor: colorScheme.secondaryContainer,
      leading: isActive ? const Icon(Icons.check) : const SizedBox(width: 24),
      title: Text(label),
      trailing: _buildEditControl(),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  Widget? _buildEditControl() {
    final label = editLabel;
    if (label == null) return null;
    return TextButton(onPressed: onLongPress, child: Text(label));
  }
}

/// Cancels the active timer; shown only while a timer is running.
class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.error,
        side: BorderSide(color: colorScheme.error),
        minimumSize: const Size.fromHeight(48),
      ),
      child: Text(label),
    );
  }
}
