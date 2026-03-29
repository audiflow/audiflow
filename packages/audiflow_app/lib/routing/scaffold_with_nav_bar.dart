import 'dart:async';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../l10n/app_localizations.dart';
import '../features/player/presentation/screens/player_screen.dart';
import '../features/player/presentation/widgets/animated_mini_player.dart';
import '../features/settings/presentation/controllers/last_tab_controller.dart';
import '../features/voice/presentation/widgets/voice_command_panel.dart';
import '../features/voice/presentation/widgets/voice_trigger_button.dart';

/// Adaptive navigation shell for phone or tablet navigation.
///
/// Switches between three modes based on form factor and orientation:
/// - Phone portrait: bottom custom nav bar
/// - Tablet portrait: top tab bar in [AppBar]
/// - Tablet landscape: [NavigationRail] on left
///
/// A [VoiceCommandPanel] is overlaid in the top-right corner across all modes.
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
      builder: (context) => const PlayerScreen(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = DeviceUtils.isTablet(size.shortestSide);
    final isLandscape = size.height < size.width;

    void onDestinationSelected(int index) => _onDestinationSelected(ref, index);

    final Widget shell;
    if (isTablet && isLandscape) {
      shell = _TabletLandscapeShell(
        navigationShell: navigationShell,
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: onDestinationSelected,
        onMiniPlayerTap: () => _onMiniPlayerTap(context),
      );
    } else if (isTablet) {
      shell = _TabletPortraitShell(
        navigationShell: navigationShell,
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: onDestinationSelected,
        onMiniPlayerTap: () => _onMiniPlayerTap(context),
      );
    } else {
      shell = _PhoneShell(
        navigationShell: navigationShell,
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: onDestinationSelected,
        onMiniPlayerTap: () => _onMiniPlayerTap(context),
      );
    }

    return Stack(
      children: [
        shell,
        const Positioned(
          top: 0,
          right: 8,
          child: SafeArea(child: VoiceCommandPanel()),
        ),
      ],
    );
  }
}

/// Phone: bottom custom nav bar with center voice button.
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
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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

/// A single nav item: icon (filled when selected with indicator pill) + label.
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
    final iconColor = isSelected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;
    final labelColor = isSelected
        ? colorScheme.onSurface
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
            // Indicator pill behind icon when selected
            Container(
              width: 64,
              height: 32,
              decoration: isSelected
                  ? BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    )
                  : null,
              child: Icon(
                isSelected ? destination.selectedIcon : destination.icon,
                fill: isSelected ? 1 : 0,
                size: 24,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: labelColor,
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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: VoiceTriggerButton(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: navigationShell),
          AnimatedMiniPlayer(onTap: onMiniPlayerTap),
        ],
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
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            leading: const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: VoiceTriggerButton(),
            ),
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
            child: Column(
              children: [
                Expanded(child: navigationShell),
                AnimatedMiniPlayer(onTap: onMiniPlayerTap),
              ],
            ),
          ),
        ],
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
