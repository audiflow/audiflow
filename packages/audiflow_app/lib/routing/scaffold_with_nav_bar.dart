import 'dart:async';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
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

    // Hide the Search tab while Restricted Mode is on and the gate is locked.
    final restricted = ref.watch(isRestrictedModeOnProvider);
    final unlocked = ref.watch(isUnlockedProvider);
    final hideSearch = restricted && !unlocked;

    void onDestinationSelected(int index) => _onDestinationSelected(ref, index);

    if (isTablet && isLandscape) {
      return _TabletLandscapeShell(
        navigationShell: navigationShell,
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: onDestinationSelected,
        onMiniPlayerTap: () => _onMiniPlayerTap(context),
        hideSearch: hideSearch,
      );
    }
    if (isTablet) {
      return _TabletPortraitShell(
        navigationShell: navigationShell,
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: onDestinationSelected,
        onMiniPlayerTap: () => _onMiniPlayerTap(context),
        hideSearch: hideSearch,
      );
    }
    return _PhoneShell(
      navigationShell: navigationShell,
      currentIndex: navigationShell.currentIndex,
      onDestinationSelected: onDestinationSelected,
      onMiniPlayerTap: () => _onMiniPlayerTap(context),
      hideSearch: hideSearch,
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
    required this.hideSearch,
  });

  final Widget navigationShell;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onMiniPlayerTap;
  final bool hideSearch;

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
            hideSearch: hideSearch,
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
    required this.hideSearch,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  /// When true the Search tab (index 0) is rendered disabled.
  /// Indices are kept stable so [StatefulShellRoute.indexedStack] is unaffected.
  final bool hideSearch;

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
                    // Disable Search tab when restricted and locked.
                    onTap: (hideSearch && i == 0)
                        ? null
                        : () => onDestinationSelected(i),
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
///
/// When [onTap] is null the item is rendered disabled (restricted mode).
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final _NavDestination destination;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final label = destination.resolveLabel(l10n);
    final disabled = onTap == null;
    final foreground = disabled
        ? colorScheme.onSurface.withValues(alpha: 0.38)
        : isSelected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: !disabled,
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
    required this.hideSearch,
  });

  final Widget navigationShell;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onMiniPlayerTap;
  final bool hideSearch;

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
                // Disable Search tab when restricted and locked.
                onTap: (hideSearch && i == 0)
                    ? null
                    : () => onDestinationSelected(i),
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
    required this.hideSearch,
  });

  final Widget navigationShell;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onMiniPlayerTap;
  final bool hideSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (
                  var i = 0;
                  i < ScaffoldWithNavBar._destinations.length;
                  i++
                )
                  NavigationRailDestination(
                    // Disable Search destination when restricted and locked.
                    disabled: hideSearch && i == 0,
                    icon: Icon(ScaffoldWithNavBar._destinations[i].icon),
                    selectedIcon: Icon(
                      ScaffoldWithNavBar._destinations[i].selectedIcon,
                      fill: 1,
                    ),
                    label: Text(
                      ScaffoldWithNavBar._destinations[i].resolveLabel(l10n),
                    ),
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
///
/// When [onTap] is null the button is rendered disabled (restricted mode).
class _TopTabButton extends StatelessWidget {
  const _TopTabButton({
    required this.destination,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
  });

  final _NavDestination destination;
  final bool isSelected;
  final VoidCallback? onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    final foreground = disabled
        ? colorScheme.onSurface.withValues(alpha: 0.38)
        : isSelected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(
          destination.icon,
          fill: isSelected ? 1 : 0,
          size: 20,
          color: foreground,
        ),
        label: Text(
          destination.resolveLabel(AppLocalizations.of(context)),
          style: TextStyle(
            color: foreground,
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
