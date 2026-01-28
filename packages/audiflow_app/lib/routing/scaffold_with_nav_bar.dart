import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../features/player/presentation/screens/player_screen.dart';
import '../features/player/presentation/widgets/animated_mini_player.dart';
import '../features/voice/presentation/widgets/voice_command_fab.dart';
import '../features/voice/presentation/widgets/voice_listening_overlay.dart';

/// Navigation shell widget providing a bottom navigation bar.
///
/// Wraps the app content with a Material 3 [NavigationBar] containing
/// three destinations: Search, Library, and Settings. Each destination
/// maintains its own navigation state through [StatefulShellRoute].
///
/// Also includes a voice command FAB and listening overlay for hands-free
/// podcast control.
class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  /// The navigation shell managing the tab branches.
  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  void _onMiniPlayerTap(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (context) => const PlayerScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceCommandOrchestratorProvider);
    final showOverlay = voiceState is! VoiceIdle;

    return Stack(
      children: [
        Scaffold(
          body: navigationShell,
          floatingActionButton: const VoiceCommandFab(),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedMiniPlayer(onTap: () => _onMiniPlayerTap(context)),
              NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _onDestinationSelected,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Symbols.search),
                    selectedIcon: Icon(Symbols.search, fill: 1),
                    label: 'Search',
                  ),
                  NavigationDestination(
                    icon: Icon(Symbols.library_music),
                    selectedIcon: Icon(Symbols.library_music, fill: 1),
                    label: 'Library',
                  ),
                  NavigationDestination(
                    icon: Icon(Symbols.queue_music),
                    selectedIcon: Icon(Symbols.queue_music, fill: 1),
                    label: 'Queue',
                  ),
                  NavigationDestination(
                    icon: Icon(Symbols.settings),
                    selectedIcon: Icon(Symbols.settings, fill: 1),
                    label: 'Settings',
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showOverlay) const VoiceListeningOverlay(),
      ],
    );
  }
}
