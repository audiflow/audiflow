import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mini_player.dart';

/// Animated wrapper for [MiniPlayer] that slides in/out based on playback state.
///
/// Slides up when audio is playing/paused and slides down when idle.
class AnimatedMiniPlayer extends ConsumerStatefulWidget {
  const AnimatedMiniPlayer({super.key, this.onTap});

  /// Callback when the mini player is tapped.
  final VoidCallback? onTap;

  @override
  ConsumerState<AnimatedMiniPlayer> createState() => _AnimatedMiniPlayerState();
}

class _AnimatedMiniPlayerState extends ConsumerState<AnimatedMiniPlayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 1), // Start below the screen
          end: Offset.zero, // End at normal position
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch playback state to determine visibility
    final playbackState = ref.watch(audioPlayerControllerProvider);
    final nowPlaying = ref.watch(nowPlayingControllerProvider);

    final shouldShow =
        nowPlaying != null &&
        playbackState.maybeWhen(
          playing: (_) => true,
          paused: (_) => true,
          loading: (_) => true,
          orElse: () => false,
        );

    // Animate based on playback state
    if (shouldShow) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: MiniPlayer(onTap: widget.onTap),
    );
  }
}
