import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// How a station picks a podcast's episodes.
enum EpisodeLimitMode {
  /// Follow the station-wide default (per-podcast sheet only).
  stationDefault,
  all,
  latest,
}

/// Bottom-sheet body for choosing how many episodes a station takes.
///
/// A segmented control picks the mode. "Default" and "All" save as soon
/// as they are tapped; "Latest N" takes its count from the keypad and
/// saves with the Set button. Typing a digit selects "Latest N", so the
/// count can be entered without choosing the mode first.
class EpisodeLimitSheet extends StatefulWidget {
  const EpisodeLimitSheet({
    super.key,
    required this.subtitle,
    required this.initialMode,
    required this.initialCount,
    required this.onAll,
    required this.onLatest,
    this.defaultLabel,
    this.onDefault,
  }) : assert((defaultLabel == null) == (onDefault == null));

  /// Largest count the keypad accepts; beyond it "All" is the choice.
  static const int maxCount = 99;

  /// The podcast's title, or a note that the station default is edited.
  final String subtitle;
  final EpisodeLimitMode initialMode;

  /// Count pre-filled on the keypad, shown dimmed outside "Latest N".
  final int initialCount;
  final VoidCallback onAll;
  final ValueChanged<int> onLatest;

  /// Label of the "Default" segment; null hides it.
  final String? defaultLabel;
  final VoidCallback? onDefault;

  @override
  State<EpisodeLimitSheet> createState() => _EpisodeLimitSheetState();
}

class _EpisodeLimitSheetState extends State<EpisodeLimitSheet> {
  late EpisodeLimitMode _mode = widget.initialMode;
  late NumberEntry _entry = NumberEntry.initial(widget.initialCount);

  bool get _isLatest => _mode == EpisodeLimitMode.latest;

  void _onModeChanged(EpisodeLimitMode mode) {
    switch (mode) {
      case EpisodeLimitMode.stationDefault:
        widget.onDefault?.call();
      case EpisodeLimitMode.all:
        widget.onAll();
      case EpisodeLimitMode.latest:
        setState(() => _mode = mode);
    }
  }

  void _onDigit(String digit) => setState(() {
    _mode = EpisodeLimitMode.latest;
    _entry = _entry.appendDigit(digit, maxValue: EpisodeLimitSheet.maxCount);
  });

  void _onBackspace() => setState(() {
    _mode = EpisodeLimitMode.latest;
    _entry = _entry.backspace();
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canSet = _isLatest && 0 < _entry.value;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.md,
          0,
          Spacing.md,
          Spacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(context, l10n),
            const SizedBox(height: Spacing.md),
            AppSegmentedControl<EpisodeLimitMode>(
              segments: _segments(l10n),
              selected: _mode,
              onChanged: _onModeChanged,
            ),
            const SizedBox(height: Spacing.md),
            _readout(context, l10n),
            NumberKeypad(
              onDigit: _onDigit,
              onBackspace: _onBackspace,
              dimmed: !_isLatest,
            ),
            const SizedBox(height: Spacing.sm),
            FilledButton(
              onPressed: canSet ? () => widget.onLatest(_entry.value) : null,
              child: Text(l10n.stationEpisodeLimitSet),
            ),
          ],
        ),
      ),
    );
  }

  List<(EpisodeLimitMode, String)> _segments(AppLocalizations l10n) {
    final defaultLabel = widget.defaultLabel;
    return [
      if (defaultLabel != null) (EpisodeLimitMode.stationDefault, defaultLabel),
      (EpisodeLimitMode.all, l10n.stationAllEpisodes),
      (EpisodeLimitMode.latest, l10n.stationEpisodeLimitLatestSegment),
    ];
  }

  Widget _header(BuildContext context, AppLocalizations l10n) {
    final colors = AppColors.of(context);
    return Column(
      children: [
        Text(
          l10n.stationEpisodes,
          style: AppTextStyles.rowTitle.copyWith(color: colors.ink),
        ),
        const SizedBox(height: Spacing.xxs),
        Text(
          widget.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.meta.copyWith(color: colors.inkTertiary),
        ),
      ],
    );
  }

  Widget _readout(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final color = _isLatest ? null : theme.disabledColor;
    final count = _entry.value;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          _entry.text.isEmpty ? '0' : _entry.text,
          style: theme.textTheme.displayMedium?.copyWith(
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: Spacing.xs),
        Text(
          l10n.stationEpisodeLimitUnit(count),
          style: AppTextStyles.body.copyWith(
            color: color ?? AppColors.of(context).inkSecondary,
          ),
        ),
      ],
    );
  }
}
