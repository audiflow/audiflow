import 'dart:math' as math;

import 'package:audiflow/features/bootstrap/service/app_wide_initializer.dart';
import 'package:audiflow/features/player/ui/expandable_player/expandable_player.dart';
import 'package:audiflow/features/player/ui/expandable_player/mini_player_height_provider.dart';
import 'package:audiflow/features/player/ui/expandable_player_frame/utils.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

double playerMaxHeight(BuildContext content) {
  final mediaQuery = MediaQuery.of(content);
  return mediaQuery.size.height - mediaQuery.padding.vertical;
}

const kAppBottomNavigationBarHeight = 89.0;

class Wrapper extends ConsumerWidget {
  const Wrapper({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appWideProvider);
    return child;
  }
}

class AppBottomNavigationBar extends HookConsumerWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final miniPlayerHeight = ref.watch(miniPlayerHeightProvider);
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: constraints.maxHeight - miniPlayerHeight,
                child: navigationShell,
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ExpandablePlayer(
              minHeight: playerMinHeight,
              maxHeight: playerMaxHeight(context),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: ValueNotifier(0.toDouble()), // playerExpandProgress,
        builder: (BuildContext context, double playerHeight, Widget? child) {
          final value = percentageFromValueInRange(
            min: playerMinHeight,
            max: playerMaxHeight(context),
            value: playerHeight,
          );

          final height = math
              .max(
                0,
                kAppBottomNavigationBarHeight -
                    kAppBottomNavigationBarHeight * value,
              )
              .toDouble();
          final offset = kAppBottomNavigationBarHeight * value * 0.5;
          final opacity = borderDouble(1 - value);
          return SizedBox(
            height: height,
            child: Transform.translate(
              offset: Offset(0, offset),
              child: Opacity(
                opacity: opacity,
                child: OverflowBox(
                  maxHeight: kAppBottomNavigationBarHeight,
                  child: child,
                ),
              ),
            ),
          );
        },
        child: BottomNavigationBar(
          backgroundColor: theme.colorScheme.surfaceContainer,
          type: BottomNavigationBarType.fixed,
          currentIndex: navigationShell.currentIndex,
          onTap: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          selectedFontSize: 12,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Symbols.home),
              label: l10n.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Symbols.search),
              label: l10n.search,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Symbols.video_library),
              label: l10n.library,
            ),
          ],
        ),
      ),
    );
  }
}
