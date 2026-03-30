import 'dart:async';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
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
    final repo = ref.watch(appSettingsRepositoryProvider);
    final voiceEnabled = repo.getVoiceEnabled();

    void onDestinationSelected(int index) => _onDestinationSelected(ref, index);

    final Widget shell;
    if (isTablet && isLandscape) {
      shell = _TabletLandscapeShell(
        navigationShell: navigationShell,
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: onDestinationSelected,
        onMiniPlayerTap: () => _onMiniPlayerTap(context),
        voiceEnabled: voiceEnabled,
      );
    } else if (isTablet) {
      shell = _TabletPortraitShell(
        navigationShell: navigationShell,
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: onDestinationSelected,
        onMiniPlayerTap: () => _onMiniPlayerTap(context),
        voiceEnabled: voiceEnabled,
      );
    } else {
      shell = _PhoneShell(
        navigationShell: navigationShell,
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: onDestinationSelected,
        onMiniPlayerTap: () => _onMiniPlayerTap(context),
        voiceEnabled: voiceEnabled,
      );
    }

    return Stack(
      children: [
        shell,
        if (voiceEnabled)
          Positioned(
            top: MediaQuery.paddingOf(context).top + kToolbarHeight,
            right: 8,
            child: const VoiceCommandPanel(),
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
    required this.voiceEnabled,
  });

  final Widget navigationShell;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onMiniPlayerTap;
  final bool voiceEnabled;

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
            voiceEnabled: voiceEnabled,
          ),
        ],
      ),
    );
  }
}

/// Custom bottom nav bar with 4 nav destinations and a center-docked voice button.
class _CustomNavBar extends StatelessWidget {
  const _CustomNavBar({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.voiceEnabled,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool voiceEnabled;

  static final _leftDestinations = [
    (index: 0, destination: ScaffoldWithNavBar._destinations[0]),
    (index: 1, destination: ScaffoldWithNavBar._destinations[1]),
  ];

  static final _rightDestinations = [
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

    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    if (!voiceEnabled) {
      return Material(
        color: backgroundColor,
        child: SizedBox(
          height: 80 + bottomInset,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Row(
              children: [
                for (
                  var i = 0;
                  i < ScaffoldWithNavBar._destinations.length;
                  i++
                )
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

    return Material(
      color: backgroundColor,
      child: SizedBox(
        height: 80 + bottomInset,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Row(
                children: [
                  for (final item in _leftDestinations)
                    Expanded(
                      child: _NavItem(
                        destination: item.destination,
                        isSelected: currentIndex == item.index,
                        onTap: () => onDestinationSelected(item.index),
                      ),
                    ),
                  const SizedBox(width: 72),
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
            ),
            Positioned(
              top: -8,
              left: 0,
              right: 0,
              child: const Center(child: _VoiceCenterButton()),
            ),
          ],
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
    required this.voiceEnabled,
  });

  final Widget navigationShell;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onMiniPlayerTap;
  final bool voiceEnabled;

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
        actions: [if (voiceEnabled) const VoiceTriggerButton()],
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
    required this.voiceEnabled,
  });

  final Widget navigationShell;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onMiniPlayerTap;
  final bool voiceEnabled;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            leading: voiceEnabled
                ? const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: VoiceTriggerButton(),
                  )
                : const SizedBox.shrink(),
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

/// Center-docked 48x48 circular voice button for the phone bottom nav bar.
///
/// Mirrors the state-aware color and icon logic of [VoiceTriggerButton] but
/// uses a larger circular shape suited for the raised docked-FAB position.
class _VoiceCenterButton extends ConsumerStatefulWidget {
  const _VoiceCenterButton();

  @override
  ConsumerState<_VoiceCenterButton> createState() => _VoiceCenterButtonState();
}

class _VoiceCenterButtonState extends ConsumerState<_VoiceCenterButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap(VoiceRecognitionState state) {
    final orchestrator = ref.read(voiceCommandOrchestratorProvider.notifier);
    switch (state) {
      case VoiceIdle():
        unawaited(orchestrator.startVoiceCommand());
      case VoiceListening():
        unawaited(orchestrator.cancelVoiceCommand());
      case VoiceSuccess():
        orchestrator.resetToIdle();
      case VoiceError():
        orchestrator.resetToIdle();
      case VoiceProcessing():
      case VoiceExecuting():
      case VoiceSettingsAutoApplied():
      case VoiceSettingsDisambiguation():
      case VoiceSettingsLowConfidence():
    }
  }

  bool _isTapDisabled(VoiceRecognitionState state) {
    return switch (state) {
      VoiceIdle() => false,
      VoiceListening() => false,
      VoiceSuccess() => false,
      VoiceError() => false,
      VoiceProcessing() => true,
      VoiceExecuting() => true,
      VoiceSettingsAutoApplied() => true,
      VoiceSettingsDisambiguation() => true,
      VoiceSettingsLowConfidence() => true,
    };
  }

  Color _backgroundColor(BuildContext context, VoiceRecognitionState state) {
    final cs = Theme.of(context).colorScheme;
    return switch (state) {
      VoiceIdle() => cs.primary,
      VoiceListening() => cs.primary,
      VoiceProcessing() => cs.primary.withValues(alpha: 0.7),
      VoiceExecuting() => cs.primary.withValues(alpha: 0.7),
      VoiceSuccess() => cs.tertiary,
      VoiceError() => cs.error,
      VoiceSettingsAutoApplied() => cs.secondary,
      VoiceSettingsDisambiguation() => cs.secondary,
      VoiceSettingsLowConfidence() => cs.secondary,
    };
  }

  Color _iconColor(BuildContext context, VoiceRecognitionState state) {
    final cs = Theme.of(context).colorScheme;
    return switch (state) {
      VoiceIdle() => cs.onPrimary,
      VoiceListening() => const Color(0xFFFFC107),
      VoiceProcessing() => cs.onPrimary,
      VoiceExecuting() => cs.onPrimary,
      VoiceSuccess() => cs.onTertiary,
      VoiceError() => cs.onError,
      VoiceSettingsAutoApplied() => cs.onSecondary,
      VoiceSettingsDisambiguation() => cs.onSecondary,
      VoiceSettingsLowConfidence() => cs.onSecondary,
    };
  }

  double _iconFill(VoiceRecognitionState state) {
    return switch (state) {
      VoiceListening() => 1,
      VoiceIdle() => 0,
      VoiceProcessing() => 0,
      VoiceExecuting() => 0,
      VoiceSuccess() => 0,
      VoiceError() => 0,
      VoiceSettingsAutoApplied() => 0,
      VoiceSettingsDisambiguation() => 0,
      VoiceSettingsLowConfidence() => 0,
    };
  }

  List<BoxShadow> _boxShadows(
    BuildContext context,
    VoiceRecognitionState state,
  ) {
    final cs = Theme.of(context).colorScheme;
    return switch (state) {
      VoiceListening() => [
        BoxShadow(
          color: cs.primary.withValues(alpha: 0.5),
          blurRadius: 16,
          spreadRadius: 2,
        ),
      ],
      _ => [
        BoxShadow(
          color: cs.shadow.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceCommandOrchestratorProvider);

    final isPulsing =
        voiceState is VoiceProcessing || voiceState is VoiceExecuting;
    if (isPulsing) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController
          ..stop()
          ..reset();
      }
    }

    final bgColor = _backgroundColor(context, voiceState);
    final iconColor = _iconColor(context, voiceState);
    final fill = _iconFill(voiceState);
    final shadows = _boxShadows(context, voiceState);
    final disabled = _isTapDisabled(voiceState);

    return Semantics(
      button: true,
      enabled: !disabled,
      label: AppLocalizations.of(context).voiceCommandButton,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final opacity = isPulsing ? _pulseAnimation.value : 1.0;
          return Opacity(opacity: opacity, child: child);
        },
        child: GestureDetector(
          onTap: disabled ? null : () => _handleTap(voiceState),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow: shadows,
            ),
            child: Icon(Symbols.mic, fill: fill, size: 24, color: iconColor),
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
