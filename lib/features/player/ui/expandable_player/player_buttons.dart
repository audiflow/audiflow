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
