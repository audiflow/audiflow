import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Navigation shell widget providing a bottom navigation bar.
///
/// Wraps the app content with a Material 3 [NavigationBar] containing
/// three destinations: Search, Library, and Settings. Each destination
/// maintains its own navigation state through [StatefulShellRoute].
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  /// The navigation shell managing the tab branches.
  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
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
            icon: Icon(Symbols.settings),
            selectedIcon: Icon(Symbols.settings, fill: 1),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
