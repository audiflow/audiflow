import 'package:audiflow/constants/app_sizes.dart';
import 'package:audiflow/features/player/model/sleep_mode.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

enum IconSize {
  small,
  middle,
  large;

  double get size {
    switch (this) {
      case IconSize.small:
        return 46;
      case IconSize.middle:
        return 60;
      case IconSize.large:
        return 70;
    }
  }

  double get iconSize {
    switch (this) {
      case IconSize.small:
        return 30;
      case IconSize.middle:
        return 40;
      case IconSize.large:
        return 50;
    }
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.iconSize,
    required this.onPressed,
  });

  final IconData icon;
  final IconSize iconSize;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: iconSize.size,
      height: iconSize.size,
      child: IconButton(
        iconSize: iconSize.iconSize,
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({
    required this.iconSize,
    required this.playIcon,
    required this.pauseIcon,
    required this.isPlaying,
    required this.onTap,
    super.key,
  });

  const PlayButton.large({
    required this.isPlaying,
    required this.onTap,
    super.key,
  })  : iconSize = IconSize.large,
        playIcon = Symbols.play_circle,
        pauseIcon = Symbols.pause_circle_filled;

  const PlayButton.small({
    required this.isPlaying,
    required this.onTap,
    super.key,
  })  : iconSize = IconSize.small,
        playIcon = Symbols.play_arrow,
        pauseIcon = Symbols.pause_rounded;

  final IconSize iconSize;
  final IconData pauseIcon;
  final IconData playIcon;
  final bool isPlaying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return isPlaying
        ? _IconButton(
            icon: pauseIcon,
            iconSize: iconSize,
            onPressed: onTap,
          )
        : _IconButton(
            icon: playIcon,
            iconSize: iconSize,
            onPressed: onTap,
          );
  }
}

class SkipButton extends StatelessWidget {
  const SkipButton({
    required this.forward,
    required this.onTap,
    super.key,
  });

  final bool forward;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _IconButton(
      icon: forward ? Symbols.forward_30 : Symbols.replay_10,
      iconSize: IconSize.middle,
      onPressed: onTap,
    );
  }
}

class PlaybackSpeedButton extends StatelessWidget {
  const PlaybackSpeedButton({
    required this.speed,
    required this.onTap,
    super.key,
  });

  final double speed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text('${speed}x'),
    );
  }
}

class SleepModeButton extends StatelessWidget {
  const SleepModeButton({
    required this.sleepMode,
    required this.onSelect,
    super.key,
  });

  final SleepMode sleepMode;
  final ValueChanged<SleepMode> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      onPressed: () async {
        final value = await _showSleepModeSelector(context, sleepMode);
        if (value != null) {
          onSelect(value);
        }
      },
      icon: Icon(
        Symbols.sleep,
        color: sleepMode.type == SleepType.none
            ? theme.dividerColor
            : theme.colorScheme.primary,
      ),
    );
  }
}

Future<SleepMode?> _showSleepModeSelector(
  BuildContext context,
  SleepMode current,
) async {
  final l10n = L10n.of(context);
  return showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (context) {
      final theme = Theme.of(context);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.sleepModeTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            gapH12,
            ...predefinedSleeps.reversed.mapIndexed((i, sleepMode) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: theme.dividerColor,
                      width: 0.2,
                    ),
                  ),
                ),
                child: ListTile(
                  selected: sleepMode == current,
                  title: Text(sleepMode.getLabel(context)),
                  visualDensity: const VisualDensity(vertical: -3),
                  // to compact
                  leading:
                      sleepMode == current ? const Icon(Symbols.check) : gapW20,
                  onTap: () => Navigator.of(context).pop(sleepMode),
                ),
              );
            }),
            gapH24,
          ],
        ),
      );
    },
  );
}
