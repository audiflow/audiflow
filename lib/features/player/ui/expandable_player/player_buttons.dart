import 'package:audiflow/constants/app_sizes.dart';
import 'package:audiflow/features/player/model/sleep.dart';
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
    required this.sleep,
    required this.onSelect,
    super.key,
  });

  final Sleep sleep;
  final ValueChanged<Sleep> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<Sleep>(
      onSelected: onSelect,
      position: PopupMenuPosition.under,
      itemBuilder: (context) {
        return predefinedSleeps.reversed
            .map(
              (value) => PopupMenuItem(
                value: value,
                child: Row(
                  children: [
                    value == sleep
                        ? const Icon(
                            Symbols.check,
                            size: 18,
                          )
                        : const SizedBox(width: 18),
                    gapW4,
                    Text(value.getLabel(context)),
                  ],
                ),
              ),
            )
            .toList();
      },
      child: Icon(
        Symbols.sleep,
        color: sleep.type == SleepType.none
            ? theme.dividerColor
            : theme.colorScheme.primary,
      ),
    );
  }
}
