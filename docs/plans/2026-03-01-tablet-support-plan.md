# Tablet Support Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Support iPad and Android tablets with landscape orientation, following Apple Podcasts' iPad design language. Phones remain portrait-only.

**Architecture:** Add a responsive utility layer in `audiflow_core` (constants + device detection) and `audiflow_ui` (grid helper). Refactor `ScaffoldWithNavBar` into an adaptive navigation shell that switches between bottom bar (phone), top tab bar (tablet portrait), and sidebar (tablet landscape). Apply responsive layout adaptations to all content screens.

**Tech Stack:** Flutter 3.38+, Material 3, Riverpod, go_router `StatefulShellRoute`

**Design doc:** `docs/plans/2026-03-01-tablet-support-design.md`

---

### Task 1: Layout Constants

**Files:**
- Create: `packages/audiflow_core/lib/src/constants/layout_constants.dart`
- Test: `packages/audiflow_core/test/constants/layout_constants_test.dart`

**Step 1: Write the test**

```dart
import 'package:audiflow_core/audiflow_core.dart';
import 'package:test/test.dart';

void main() {
  group('LayoutConstants', () {
    test('tabletBreakpoint is 600', () {
      expect(LayoutConstants.tabletBreakpoint, 600.0);
    });

    test('contentMaxWidth is 560', () {
      expect(LayoutConstants.contentMaxWidth, 560.0);
    });

    test('podcastGridItemWidth is 130', () {
      expect(LayoutConstants.podcastGridItemWidth, 130.0);
    });

    test('sidebarWidth is 280', () {
      expect(LayoutConstants.sidebarWidth, 280.0);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test packages/audiflow_core/test/constants/layout_constants_test.dart`
Expected: FAIL (file not found / class not defined)

**Step 3: Write implementation**

```dart
/// Layout constants for responsive design.
///
/// Defines breakpoints and dimension targets for adaptive
/// phone/tablet layouts following Apple Podcasts' iPad patterns.
class LayoutConstants {
  LayoutConstants._();

  /// Shortest-side threshold separating phone from tablet.
  ///
  /// Devices with `tabletBreakpoint <= shortestSide` are tablets.
  static const double tabletBreakpoint = 600.0;

  /// Maximum content width for centered layouts (player, settings).
  static const double contentMaxWidth = 560.0;

  /// Target width per podcast grid item for column count calculation.
  static const double podcastGridItemWidth = 130.0;

  /// Width of the sidebar in tablet landscape mode.
  static const double sidebarWidth = 280.0;
}
```

**Step 4: Export from package**

Add to `packages/audiflow_core/lib/audiflow_core.dart`:

```dart
export 'src/constants/layout_constants.dart';
```

**Step 5: Run test to verify it passes**

Run: `flutter test packages/audiflow_core/test/constants/layout_constants_test.dart`
Expected: PASS

**Step 6: Commit**

```
feat(core): add layout constants for tablet breakpoints
```

---

### Task 2: Device Form Factor Utility

**Files:**
- Create: `packages/audiflow_core/lib/src/utils/device_utils.dart`
- Test: `packages/audiflow_core/test/utils/device_utils_test.dart`

**Step 1: Write the test**

```dart
import 'package:audiflow_core/audiflow_core.dart';
import 'package:test/test.dart';

void main() {
  group('DeviceFormFactor', () {
    test('has phone and tablet values', () {
      expect(DeviceFormFactor.values, contains(DeviceFormFactor.phone));
      expect(DeviceFormFactor.values, contains(DeviceFormFactor.tablet));
    });
  });

  group('DeviceUtils.formFactor', () {
    test('returns phone for shortestSide below breakpoint', () {
      expect(DeviceUtils.formFactor(599), DeviceFormFactor.phone);
    });

    test('returns tablet for shortestSide at breakpoint', () {
      expect(DeviceUtils.formFactor(600), DeviceFormFactor.tablet);
    });

    test('returns tablet for shortestSide above breakpoint', () {
      expect(DeviceUtils.formFactor(744), DeviceFormFactor.tablet);
    });

    test('returns phone for zero', () {
      expect(DeviceUtils.formFactor(0), DeviceFormFactor.phone);
    });
  });

  group('DeviceUtils.isTablet', () {
    test('returns false for phone-sized screen', () {
      expect(DeviceUtils.isTablet(390), false);
    });

    test('returns true for tablet-sized screen', () {
      expect(DeviceUtils.isTablet(744), true);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test packages/audiflow_core/test/utils/device_utils_test.dart`
Expected: FAIL

**Step 3: Write implementation**

```dart
import '../constants/layout_constants.dart';

/// Device form factor classification.
enum DeviceFormFactor {
  /// Phone-sized device (portrait only).
  phone,

  /// Tablet-sized device (portrait + landscape).
  tablet,
}

/// Utilities for device form factor detection.
class DeviceUtils {
  DeviceUtils._();

  /// Returns the [DeviceFormFactor] based on the screen's shortest side.
  static DeviceFormFactor formFactor(double shortestSide) {
    if (LayoutConstants.tabletBreakpoint <= shortestSide) {
      return DeviceFormFactor.tablet;
    }
    return DeviceFormFactor.phone;
  }

  /// Returns true if [shortestSide] indicates a tablet.
  static bool isTablet(double shortestSide) {
    return formFactor(shortestSide) == DeviceFormFactor.tablet;
  }
}
```

**Step 4: Export from package**

Add to `packages/audiflow_core/lib/audiflow_core.dart`:

```dart
export 'src/utils/device_utils.dart';
```

**Step 5: Run test to verify it passes**

Run: `flutter test packages/audiflow_core/test/utils/device_utils_test.dart`
Expected: PASS

**Step 6: Commit**

```
feat(core): add device form factor detection utility
```

---

### Task 3: Responsive Grid Helper

**Files:**
- Create: `packages/audiflow_ui/lib/src/utils/responsive_grid.dart`
- Test: `packages/audiflow_ui/test/utils/responsive_grid_test.dart`

**Step 1: Write the test**

```dart
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:test/test.dart';

void main() {
  group('ResponsiveGrid.columnCount', () {
    test('returns 3 for phone width (~390dp)', () {
      expect(ResponsiveGrid.columnCount(availableWidth: 390), 3);
    });

    test('returns 5 for tablet portrait (~744dp)', () {
      expect(ResponsiveGrid.columnCount(availableWidth: 744), 5);
    });

    test('returns 5 for tablet landscape minus sidebar (~744dp)', () {
      expect(ResponsiveGrid.columnCount(availableWidth: 744), 5);
    });

    test('returns at least 2 for very narrow width', () {
      expect(ResponsiveGrid.columnCount(availableWidth: 100), 2);
    });

    test('respects custom itemWidth', () {
      expect(
        ResponsiveGrid.columnCount(availableWidth: 600, itemWidth: 200),
        3,
      );
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test packages/audiflow_ui/test/utils/responsive_grid_test.dart`
Expected: FAIL

**Step 3: Write implementation**

```dart
import 'dart:math' as math;

import 'package:audiflow_core/audiflow_core.dart';

/// Utilities for responsive grid layouts.
class ResponsiveGrid {
  ResponsiveGrid._();

  /// Minimum number of columns in a podcast grid.
  static const int _minColumns = 2;

  /// Calculates the number of grid columns based on available width.
  ///
  /// Divides [availableWidth] by [itemWidth] (defaults to
  /// [LayoutConstants.podcastGridItemWidth]) and enforces a minimum
  /// of 2 columns.
  static int columnCount({
    required double availableWidth,
    double itemWidth = LayoutConstants.podcastGridItemWidth,
  }) {
    final columns = availableWidth ~/ itemWidth;
    return math.max(_minColumns, columns);
  }
}
```

**Step 4: Export from package**

Add to `packages/audiflow_ui/lib/audiflow_ui.dart`:

```dart
export 'src/utils/responsive_grid.dart';
```

**Step 5: Run test to verify it passes**

Run: `flutter test packages/audiflow_ui/test/utils/responsive_grid_test.dart`
Expected: PASS

**Step 6: Commit**

```
feat(ui): add responsive grid column calculator
```

---

### Task 4: Conditional Orientation Lock

**Files:**
- Modify: `packages/audiflow_app/lib/main.dart:48-52`

**Step 1: Modify `_startApp` to detect device form factor**

Replace the hardcoded portrait lock in `_startApp()` (lines 49-52):

```dart
// OLD:
await SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,
  DeviceOrientation.portraitDown,
]);

// NEW:
final view = WidgetsBinding.instance.platformDispatcher.views.firstOrNull;
final logicalSize = view != null
    ? view.physicalSize / view.devicePixelRatio
    : Size.zero;
final isTablet = DeviceUtils.isTablet(logicalSize.shortestSide);

await SystemChrome.setPreferredOrientations(
  isTablet
      ? DeviceOrientation.values
      : const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
);
```

Requires import at top of file:
```dart
import 'dart:ui' show Size;
```

Note: `DeviceUtils` is already available via `audiflow_core` import.

**Step 2: Run analysis to verify no errors**

Run: `analyze_files` tool on `packages/audiflow_app/lib/main.dart`
Expected: No errors

**Step 3: Manual test (if device available)**

Run on tablet simulator to verify landscape works.
Run on phone simulator to verify portrait-only lock.

**Step 4: Commit**

```
feat(app): enable landscape orientation on tablets
```

---

### Task 5: Adaptive Navigation Shell

This is the largest task. Refactor `ScaffoldWithNavBar` to switch between three navigation modes.

**Files:**
- Modify: `packages/audiflow_app/lib/routing/scaffold_with_nav_bar.dart`

**Step 1: Refactor ScaffoldWithNavBar**

Replace the entire `ScaffoldWithNavBar` class. The new implementation detects form factor + orientation and builds one of three navigation shells.

```dart
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../features/player/presentation/screens/player_screen.dart';
import '../features/player/presentation/widgets/animated_mini_player.dart';
import '../features/voice/presentation/widgets/voice_command_fab.dart';
import '../features/voice/presentation/widgets/voice_listening_overlay.dart';

/// Adaptive navigation shell providing phone or tablet navigation.
///
/// Switches between three modes based on device form factor and orientation:
/// - Phone portrait: bottom [NavigationBar]
/// - Tablet portrait: top tab bar in [AppBar] with sidebar toggle
/// - Tablet landscape: persistent sidebar on left
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

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
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

    final Widget shell;
    if (isTablet && isLandscape) {
      shell = _TabletLandscapeShell(
        navigationShell: navigationShell,
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        onMiniPlayerTap: () => _onMiniPlayerTap(context),
      );
    } else if (isTablet) {
      shell = _TabletPortraitShell(
        navigationShell: navigationShell,
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        onMiniPlayerTap: () => _onMiniPlayerTap(context),
      );
    } else {
      shell = _PhoneShell(
        navigationShell: navigationShell,
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        onMiniPlayerTap: () => _onMiniPlayerTap(context),
      );
    }

    return Stack(
      children: [
        shell,
        if (showOverlay) const VoiceListeningOverlay(),
      ],
    );
  }
}

/// Phone: bottom NavigationBar (current layout).
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
      floatingActionButton: const VoiceCommandFab(),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedMiniPlayer(onTap: onMiniPlayerTap),
          NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: [
              for (final d in ScaffoldWithNavBar._destinations)
                NavigationDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon, fill: 1),
                  label: d.label,
                ),
            ],
          ),
        ],
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
      floatingActionButton: const VoiceCommandFab(),
      body: Column(
        children: [
          Expanded(child: navigationShell),
          AnimatedMiniPlayer(onTap: onMiniPlayerTap),
        ],
      ),
    );
  }
}

/// Tablet landscape: persistent sidebar on left.
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
      floatingActionButton: const VoiceCommandFab(),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            leading: const SizedBox(height: 8),
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
          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
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

/// Navigation destination data for reuse across all navigation modes.
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
```

**Step 2: Run analysis**

Run: `analyze_files` tool on `packages/audiflow_app/lib/routing/scaffold_with_nav_bar.dart`
Expected: No errors

**Step 3: Run existing tests**

Run: `run_tests` tool on `packages/audiflow_app`
Expected: All pass (or any existing tests related to navigation)

**Step 4: Commit**

```
feat(app): adaptive navigation shell for phone/tablet
```

---

### Task 6: Player Screen Max-Width Constraint

**Files:**
- Modify: `packages/audiflow_app/lib/features/player/presentation/screens/player_screen.dart:79-127`

**Step 1: Wrap the player content with a centered max-width container**

In the `build` method of `_PlayerScreenState`, wrap the inner `Padding` widget with a `Center` and `ConstrainedBox`:

Replace lines 81-125 (the `SafeArea` child):

```dart
child: Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(
      maxWidth: LayoutConstants.contentMaxWidth,
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const _DragHandle(),
          _SheetHeaderWithTabs(
            tabController: _tabController!,
            hasTranscript: hasTranscriptTab,
            closeLabel: l10n.playerCloseLabel,
          ),
          Expanded(
            child: _PlayerTabBody(
              tabController: _tabController!,
              hasTranscript: hasTranscriptTab,
              episodeId: episodeId,
              artworkUrl: nowPlaying.artworkUrl,
              episodeTitle: nowPlaying.episodeTitle,
              podcastTitle: nowPlaying.podcastTitle,
            ),
          ),
          const SizedBox(height: 24),
          _PlayerProgressBar(
            progress: progress,
            onSeekStart: () => _beginSeek(isPlaying),
            onSeekEnd: _endSeek,
          ),
          const SizedBox(height: 16),
          _PlayerControls(
            isPlaying: displayIsPlaying,
            isLoading: displayIsLoading,
            onSkipBackward: () => _handleSkip(
              ref.read(audioPlayerControllerProvider.notifier).skipBackward,
              isPlaying,
            ),
            onSkipForward: () => _handleSkip(
              ref.read(audioPlayerControllerProvider.notifier).skipForward,
              isPlaying,
            ),
          ),
          const _PlaybackSpeedButton(),
          const SizedBox(height: 16),
        ],
      ),
    ),
  ),
),
```

Add import at top:
```dart
import 'package:audiflow_core/audiflow_core.dart';
```

**Step 2: Run analysis**

Run: `analyze_files` tool
Expected: No errors

**Step 3: Commit**

```
feat(player): constrain player content width for tablets
```

---

### Task 7: Library Screen Responsive Grid

**Files:**
- Modify: `packages/audiflow_app/lib/features/library/presentation/screens/library_screen.dart:99-114`

**Step 1: Replace `SliverList` with responsive `SliverGrid`**

Replace the `SliverList` (lines 99-114) in `_buildContent` with a `LayoutBuilder` that computes grid columns:

```dart
SliverLayoutBuilder(
  builder: (context, constraints) {
    final columnCount = ResponsiveGrid.columnCount(
      availableWidth: constraints.crossAxisExtent,
    );
    // Single column: keep list tile layout
    if (columnCount <= 3) {
      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final subscription = subscriptions[index];
          return SubscriptionListTile(
            key: ValueKey(subscription.itunesId),
            subscription: subscription,
            onTap: () {
              final podcast = subscription.toPodcast();
              context.push(
                '${AppRoutes.library}/podcast/${podcast.id}',
                extra: podcast,
              );
            },
          );
        }, childCount: subscriptions.length),
      );
    }
    // Multi-column: grid of artwork cards
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
        mainAxisSpacing: Spacing.sm,
        crossAxisSpacing: Spacing.sm,
        childAspectRatio: 0.8,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final subscription = subscriptions[index];
        return _SubscriptionGridItem(
          subscription: subscription,
          onTap: () {
            final podcast = subscription.toPodcast();
            context.push(
              '${AppRoutes.library}/podcast/${podcast.id}',
              extra: podcast,
            );
          },
        );
      }, childCount: subscriptions.length),
    );
  },
),
```

**Step 2: Add the grid item widget**

Add this private widget class to the bottom of `library_screen.dart`:

```dart
class _SubscriptionGridItem extends StatelessWidget {
  const _SubscriptionGridItem({
    required this.subscription,
    required this.onTap,
  });

  final Subscription subscription;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final artworkUrl = subscription.artworkUrl;

    return InkWell(
      onTap: onTap,
      borderRadius: AppBorders.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: AppBorders.sm,
              child: artworkUrl != null
                  ? Image.network(
                      artworkUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.podcasts,
                          size: 40,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.podcasts,
                        size: 40,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            subscription.title,
            style: theme.textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
```

**Step 3: Add imports**

Add to the top of `library_screen.dart`:

```dart
import 'package:audiflow_ui/audiflow_ui.dart'; // already imported
// ResponsiveGrid is now available via audiflow_ui
```

**Step 4: Run analysis**

Run: `analyze_files` tool
Expected: No errors

**Step 5: Commit**

```
feat(library): responsive podcast grid for tablets
```

---

### Task 8: Search Screen Responsive Grid

**Files:**
- Modify: `packages/audiflow_app/lib/features/search/presentation/screens/search_screen.dart:174-187`

**Step 1: Replace `ListView.builder` with responsive layout**

Replace `_buildResultsList` method:

```dart
Widget _buildResultsList(SearchResult result) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final columnCount = ResponsiveGrid.columnCount(
        availableWidth: constraints.maxWidth,
      );
      // Phone: keep list layout
      if (columnCount <= 3) {
        return ListView.builder(
          key: const Key('search_results_list'),
          itemCount: result.podcasts.length,
          itemBuilder: (context, index) {
            final podcast = result.podcasts[index];
            return PodcastSearchResultTile(
              key: Key('search_result_tile_$index'),
              podcast: podcast,
              onTap: () => _navigateToPodcastDetail(podcast),
            );
          },
        );
      }
      // Tablet: grid layout
      return GridView.builder(
        key: const Key('search_results_grid'),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnCount,
          mainAxisSpacing: Spacing.sm,
          crossAxisSpacing: Spacing.sm,
          childAspectRatio: 0.8,
        ),
        itemCount: result.podcasts.length,
        itemBuilder: (context, index) {
          final podcast = result.podcasts[index];
          return _SearchResultGridItem(
            podcast: podcast,
            onTap: () => _navigateToPodcastDetail(podcast),
          );
        },
      );
    },
  );
}
```

**Step 2: Add the grid item widget**

Add to the bottom of `search_screen.dart`:

```dart
class _SearchResultGridItem extends StatelessWidget {
  const _SearchResultGridItem({
    required this.podcast,
    required this.onTap,
  });

  final Podcast podcast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppBorders.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: AppBorders.sm,
              child: podcast.artworkUrl != null
                  ? Image.network(
                      podcast.artworkUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.podcasts,
                          size: 40,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.podcasts,
                        size: 40,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            podcast.title,
            style: theme.textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
```

**Step 3: Add import**

```dart
import 'package:audiflow_ui/audiflow_ui.dart'; // already imported
```

**Step 4: Run analysis**

Run: `analyze_files` tool
Expected: No errors

**Step 5: Commit**

```
feat(search): responsive search results grid for tablets
```

---

### Task 9: Settings Screen Adaptive Grid

**Files:**
- Modify: `packages/audiflow_app/lib/features/settings/presentation/screens/settings_screen.dart:22-67`

**Step 1: Replace fixed `GridView.count` with responsive layout**

Replace the `GridView.count` in the `build` method:

```dart
body: LayoutBuilder(
  builder: (context, constraints) {
    final columnCount = ResponsiveGrid.columnCount(
      availableWidth: constraints.maxWidth,
      itemWidth: 180,
    );
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: LayoutConstants.contentMaxWidth * 1.5,
        ),
        child: GridView.count(
          crossAxisCount: columnCount,
          padding: const EdgeInsets.all(16),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.95,
          children: [
            SettingsCategoryCard(
              icon: Symbols.palette,
              title: l10n.settingsAppearanceTitle,
              subtitle: l10n.settingsAppearanceSubtitle,
              onTap: () => context.go(AppRoutes.settingsAppearance),
            ),
            SettingsCategoryCard(
              icon: Symbols.play_circle,
              title: l10n.settingsPlaybackTitle,
              subtitle: l10n.settingsPlaybackSubtitle,
              onTap: () => context.go(AppRoutes.settingsPlayback),
            ),
            SettingsCategoryCard(
              icon: Symbols.download,
              title: l10n.settingsDownloadsTitle,
              subtitle: l10n.settingsDownloadsSubtitle,
              onTap: () => context.go(AppRoutes.settingsDownloads),
            ),
            SettingsCategoryCard(
              icon: Symbols.sync,
              title: l10n.settingsFeedSyncTitle,
              subtitle: l10n.settingsFeedSyncSubtitle,
              onTap: () => context.go(AppRoutes.settingsFeedSync),
            ),
            SettingsCategoryCard(
              icon: Symbols.storage,
              title: l10n.settingsStorageTitle,
              subtitle: l10n.settingsStorageSubtitle,
              onTap: () => context.go(AppRoutes.settingsStorage),
            ),
            SettingsCategoryCard(
              icon: Symbols.info,
              title: l10n.settingsAboutTitle,
              subtitle: l10n.settingsAboutSubtitle,
              onTap: () => context.go(AppRoutes.settingsAbout),
            ),
          ],
        ),
      ),
    );
  },
),
```

**Step 2: Add imports**

```dart
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
```

**Step 3: Run analysis**

Run: `analyze_files` tool
Expected: No errors

**Step 4: Commit**

```
feat(settings): responsive grid and max-width for tablets
```

---

### Task 10: Post-Implementation Verification

**Step 1: Format all modified files**

Run: `dart_format` tool

**Step 2: Analyze all packages**

Run: `analyze_files` tool on the entire project
Expected: Zero errors, zero warnings

**Step 3: Run all tests**

Run: `run_tests` tool
Expected: All tests pass

**Step 4: Create bookmark**

Run: `jj bookmark create feat/tablet-support`

**Step 5: Final commit (if any formatting/analysis fixes)**

```
chore: format and fix analysis issues for tablet support
```
