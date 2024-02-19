import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seasoning/services/audio/mobile_audio_player_service.dart';
import 'package:seasoning/ui/app/player.dart';
import 'package:seasoning/ui/mini_player/utils.dart';

const double playerMinHeight = 94;
const double playerMaxHeight = 600;
const miniPlayerPercentageDeclaration = 0.2;
const kAppBottomNavigationBarHeight = 89.0;

class AppBottomNavigationBar extends ConsumerWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingEpisode = ref.watch(
      mobileAudioPlayerServiceProvider.select((state) => state?.episode),
    );
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: playingEpisode == null
                      ? null
                      : constraints.maxHeight - playerMinHeight,
                  child: navigationShell,
                );
              },
            ),
            if (playingEpisode != null)
              const Align(
                alignment: Alignment.bottomCenter,
                child: DetailedPlayer(),
              ),
          ],
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: playerExpandProgress,
        builder: (BuildContext context, double playerHeight, Widget? child) {
          final value = percentageFromValueInRange(
            min: playerMinHeight,
            max: playerMaxHeight,
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
          type: BottomNavigationBarType.fixed,
          currentIndex: navigationShell.currentIndex,
          onTap: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'settings',
            ),
          ],
        ),
      ),
    );
  }
}
