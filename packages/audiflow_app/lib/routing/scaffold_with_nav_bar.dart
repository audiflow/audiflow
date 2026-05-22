import 'dart:async';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../l10n/app_localizations.dart';
import '../features/player/presentation/controllers/sleep_timer_ui_controller.dart';
import '../features/player/presentation/screens/player_screen.dart';
import '../features/player/presentation/widgets/animated_mini_player.dart';
import '../features/player/presentation/widgets/sleep_timer_chip.dart';
import '../features/settings/presentation/controllers/last_tab_controller.dart';

/// Adaptive navigation shell for phone or tablet navigation.
///
/// Switches between three modes based on form factor and orientation:
/// - Phone portrait: bottom custom nav bar
/// - Tablet portrait: top tab bar in [AppBar]
/// - Tablet landscape: [NavigationRail] on left
class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    _NavDestination(
      icon: Symbols.search,
      selectedIcon: Symbols.search,
      resolveLabel: _resolveNavSearch,
    ),
    _NavDestination(
      icon: Symbols.library_music,
      selectedIcon: Symbols.library_music,
      resolveLabel: _resolveNavLibrary,
    ),
    _NavDestination(
      icon: Symbols.queue_music,
      selectedIcon: Symbols.queue_music,
      resolveLabel: _resolveNavQueue,
    ),
    _NavDestination(
      icon: Symbols.settings,
      selectedIcon: Symbols.settings,
      resolveLabel: _resolveNavSettings,
    ),
  ];

  static String _resolveNavSearch(AppLocalizations l10n) => l10n.navSearch;
  static String _resolveNavLibrary(AppLocalizations l10n) => l10n.navLibrary;
  static String _resolveNavQueue(AppLocalizations l10n) => l10n.navQueue;
  static String _resolveNavSettings(AppLocalizations l10n) => l10n.navSettings;

  void _onDestinationSelected(WidgetRef ref, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
    unawaited(ref.read(lastTabControllerProvider.notifier).setLastTab(index));
  }

  void _onMiniPlayerTap(BuildContext context) {
    showCupertinoSheet<void>(
      context: context,
      scrollableBuilder: (context, controller) => const PlayerScreen(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = DeviceUtils.isTablet(size.shortestSide);
    final isLandscape = size.height < size.width;

    void onDestinationSelected(int index) => _onDestinationSelected(ref, index);

    if (isTablet && isLandscape) {
      return _TabletLandscapeShell(
        navigationShell: navigationShell,
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: onDestinationSelected,
        onMiniPlayerTap: () => _onMiniPlayerTap(context),
      );
    }
    if (isTablet) {
      return _TabletPortraitShell(
        navigationShell: navigationShell,
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: onDestinationSelected,
        onMiniPlayerTap: () => _onMiniPlayerTap(context),
      );
    }
    return _PhoneShell(
      navigationShell: navigationShell,
      currentIndex: navigationShell.currentIndex,
      onDestinationSelected: onDestinationSelected,
      onMiniPlayerTap: () => _onMiniPlayerTap(context),
    );
  }
}

/// Phone: bottom custom nav bar.
class _PhoneShell extends StatelessWidget {
  const _PhoneShell({
    required this.navigationShell,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.onMiniPlayerTap,
  });

  final Widget navigationShell;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onMiniPlayerTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SleepTimerSnackbarHost(child: navigationShell),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SleepTimerChip(),
          AnimatedMiniPlayer(onTap: onMiniPlayerTap),
          _CustomNavBar(
            currentIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
          ),
        ],
      ),
    );
  }
}

/// Custom bottom nav bar with 4 nav destinations.
class _CustomNavBar extends StatelessWidget {
  const _CustomNavBar({
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navBarTheme = theme.navigationBarTheme;
    final colorScheme = theme.colorScheme;

    final backgroundColor =
        navBarTheme.backgroundColor ?? colorScheme.surfaceContainer;

    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Material(
      color: backgroundColor,
      child: SizedBox(
        height: 80 + bottomInset,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Row(
            children: [
              for (var i = 0; i < ScaffoldWithNavBar._destinations.length; i++)
                Expanded(
                  child: _NavItem(
                    destination: ScaffoldWithNavBar._destinations[i],
                    isSelected: currentIndex == i,
                    onTap: () => onDestinationSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single nav item: icon + label, both colored by selected state.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final _NavDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final label = destination.resolveLabel(l10n);
    final foreground = isSelected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 32,
              child: Icon(
                isSelected ? destination.selectedIcon : destination.icon,
                fill: isSelected ? 1 : 0,
                size: 24,
                color: foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tablet portrait: top tab bar in AppBar.
class _TabletPortraitShell extends StatelessWidget {
  const _TabletPortraitShell({
    required this.navigationShell,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.onMiniPlayerTap,
  });

  final Widget navigationShell;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onMiniPlayerTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < ScaffoldWithNavBar._destinations.length; i++)
              _TopTabButton(
                destination: ScaffoldWithNavBar._destinations[i],
                isSelected: currentIndex == i,
                onTap: () => onDestinationSelected(i),
                colorScheme: colorScheme,
              ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: SleepTimerSnackbarHost(
          child: Column(
            children: [
              Expanded(child: navigationShell),
              const SleepTimerChip(),
              AnimatedMiniPlayer(onTap: onMiniPlayerTap),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tablet landscape: NavigationRail on left.
class _TabletLandscapeShell extends StatelessWidget {
  const _TabletLandscapeShell({
    required this.navigationShell,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.onMiniPlayerTap,
  });

  final Widget navigationShell;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onMiniPlayerTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final d in ScaffoldWithNavBar._destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon, fill: 1),
                    label: Text(d.resolveLabel(AppLocalizations.of(context))),
                  ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              child: SleepTimerSnackbarHost(
                child: Column(
                  children: [
                    Expanded(child: navigationShell),
                    const SleepTimerChip(),
                    AnimatedMiniPlayer(onTap: onMiniPlayerTap),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Top tab button for tablet portrait mode.
class _TopTabButton extends StatelessWidget {
  const _TopTabButton({
    required this.destination,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
  });

  final _NavDestination destination;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(
          destination.icon,
          fill: isSelected ? 1 : 0,
          size: 20,
          color: isSelected
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
        ),
        label: Text(
          destination.resolveLabel(AppLocalizations.of(context)),
          style: TextStyle(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Navigation destination data for reuse across all modes.
///
/// Uses a label resolver function instead of a static string so that
/// labels are resolved from [AppLocalizations] at build time.
class _NavDestination {
  const _NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.resolveLabel,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String Function(AppLocalizations l10n) resolveLabel;
}
