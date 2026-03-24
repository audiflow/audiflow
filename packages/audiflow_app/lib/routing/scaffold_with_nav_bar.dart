import 'dart:async';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../features/player/presentation/screens/player_screen.dart';
import '../features/player/presentation/widgets/animated_mini_player.dart';
import '../features/settings/presentation/controllers/last_tab_controller.dart';
import '../features/voice/presentation/widgets/voice_listening_overlay.dart';

/// Adaptive navigation shell for phone or tablet navigation.
///
/// Switches between three modes based on form factor and orientation:
/// - Phone portrait: bottom custom nav bar with center voice button
/// - Tablet portrait: top tab bar in [AppBar]
/// - Tablet landscape: [NavigationRail] on left
class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    _NavDestination(
      icon: Symbols.search,
      selectedIcon: Symbols.search,
      label: 'Search',
    ),
    _NavDestination(
      icon: Symbols.library_music,
      selectedIcon: Symbols.library_music,
      label: 'Library',
    ),
    _NavDestination(
      icon: Symbols.queue_music,
      selectedIcon: Symbols.queue_music,
      label: 'Queue',
    ),
    _NavDestination(
      icon: Symbols.settings,
      selectedIcon: Symbols.settings,
      label: 'Settings',
    ),
  ];

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
    final voiceState = ref.watch(voiceCommandOrchestratorProvider);
    final showOverlay = voiceState is! VoiceIdle;
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
      children: [shell, if (showOverlay) const VoiceListeningOverlay()],
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

/// Custom bottom nav bar with 4 nav destinations and a center voice button.
///
/// Positions the voice button between Library (index 1) and Queue (index 2),
/// raised slightly above the bar to create a docked FAB effect.
class _CustomNavBar extends StatelessWidget {
  const _CustomNavBar({
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  // Nav destinations split at center: [Search, Library] | voice | [Queue, Settings]
  static const _leftDestinations = [
    (index: 0, destination: ScaffoldWithNavBar._destinations[0]),
    (index: 1, destination: ScaffoldWithNavBar._destinations[1]),
  ];

  static const _rightDestinations = [
    (index: 2, destination: ScaffoldWithNavBar._destinations[2]),
    (index: 3, destination: ScaffoldWithNavBar._destinations[3]),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navBarTheme = theme.navigationBarTheme;
    final colorScheme = theme.colorScheme;

    final backgroundColor =
        navBarTheme.backgroundColor ?? colorScheme.surfaceContainer;

    return Container(
      height: 80,
      color: backgroundColor,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              // Left destinations: Search, Library
              for (final item in _leftDestinations)
                Expanded(
                  child: _NavItem(
                    destination: item.destination,
                    isSelected: currentIndex == item.index,
                    onTap: () => onDestinationSelected(item.index),
                  ),
                ),
              // Center placeholder so the voice button has visual space
              const SizedBox(width: 72),
              // Right destinations: Queue, Settings
              for (final item in _rightDestinations)
                Expanded(
                  child: _NavItem(
                    destination: item.destination,
                    isSelected: currentIndex == item.index,
                    onTap: () => onDestinationSelected(item.index),
                  ),
                ),
            ],
          ),
          // Voice button raised above bar
          Positioned(top: -8, child: const _VoiceNavButton()),
        ],
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
    final iconColor = isSelected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;
    final labelColor = isSelected
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant;

    return InkWell(
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
            destination.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: labelColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

/// Center voice button in the nav bar, slightly raised for a docked-FAB effect.
class _VoiceNavButton extends ConsumerStatefulWidget {
  const _VoiceNavButton();

  @override
  ConsumerState<_VoiceNavButton> createState() => _VoiceNavButtonState();
}

class _VoiceNavButtonState extends ConsumerState<_VoiceNavButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap(bool isListening) {
    final orchestrator = ref.read(voiceCommandOrchestratorProvider.notifier);
    if (isListening) {
      orchestrator.cancelVoiceCommand();
    } else {
      orchestrator.startVoiceCommand();
    }
  }

  Widget _buildIcon(VoiceRecognitionState state) {
    return switch (state) {
      VoiceIdle() => const Icon(Symbols.mic, size: 28),
      VoiceListening() => const Icon(Symbols.mic, fill: 1, size: 28),
      VoiceProcessing() => const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      VoiceExecuting() => const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      VoiceSuccess() => const Icon(Symbols.check_circle, size: 28),
      VoiceError() => const Icon(Symbols.error, size: 28),
      VoiceSettingsAutoApplied() => const Icon(Symbols.check_circle, size: 28),
      VoiceSettingsDisambiguation() => const Icon(
        Symbols.help_outline,
        size: 28,
      ),
      VoiceSettingsLowConfidence() => const Icon(
        Symbols.help_outline,
        size: 28,
      ),
    };
  }

  Color _backgroundColor(BuildContext context, VoiceRecognitionState state) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (state) {
      VoiceIdle() => colorScheme.primaryContainer,
      VoiceListening() => colorScheme.primary,
      VoiceProcessing() => colorScheme.primaryContainer,
      VoiceExecuting() => colorScheme.primaryContainer,
      VoiceSuccess() => colorScheme.tertiaryContainer,
      VoiceError() => colorScheme.errorContainer,
      VoiceSettingsAutoApplied() => colorScheme.tertiaryContainer,
      VoiceSettingsDisambiguation() => colorScheme.primaryContainer,
      VoiceSettingsLowConfidence() => colorScheme.primaryContainer,
    };
  }

  Color _foregroundColor(BuildContext context, VoiceRecognitionState state) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (state) {
      VoiceIdle() => colorScheme.onPrimaryContainer,
      VoiceListening() => colorScheme.onPrimary,
      VoiceProcessing() => colorScheme.onPrimaryContainer,
      VoiceExecuting() => colorScheme.onPrimaryContainer,
      VoiceSuccess() => colorScheme.onTertiaryContainer,
      VoiceError() => colorScheme.onErrorContainer,
      VoiceSettingsAutoApplied() => colorScheme.onTertiaryContainer,
      VoiceSettingsDisambiguation() => colorScheme.onPrimaryContainer,
      VoiceSettingsLowConfidence() => colorScheme.onPrimaryContainer,
    };
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceCommandOrchestratorProvider);
    final isListening = voiceState is VoiceListening;
    final isProcessing =
        voiceState is VoiceProcessing || voiceState is VoiceExecuting;

    if (isListening) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.reset();
      }
    }

    final bgColor = _backgroundColor(context, voiceState);
    final fgColor = _foregroundColor(context, voiceState);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = isListening ? _pulseAnimation.value : 1.0;
        return Transform.scale(
          scale: scale,
          child: Material(
            color: bgColor,
            shape: const CircleBorder(),
            elevation: 4,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: isProcessing ? null : () => _handleTap(isListening),
              child: SizedBox(
                width: 48,
                height: 48,
                child: IconTheme(
                  data: IconThemeData(color: fgColor),
                  child: _buildIcon(voiceState),
                ),
              ),
            ),
          ),
        );
      },
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
          Padding(padding: EdgeInsets.only(right: 8), child: _VoiceNavButton()),
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
              child: _VoiceNavButton(),
            ),
            destinations: [
              for (final d in ScaffoldWithNavBar._destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon, fill: 1),
                  label: Text(d.label),
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
          destination.label,
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
class _NavDestination {
  const _NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
