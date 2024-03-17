// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.

import 'dart:math' as math;

import 'package:audiflow/services/audio/audio_player_service.dart';
import 'package:audiflow/services/podcast/podcast_service_provider.dart';
import 'package:audiflow/ui/mini_player/utils.dart';
import 'package:audiflow/ui/player/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages_all.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const double playerMinHeight = 80;

double playerMaxHeight(BuildContext content) {
  final mediaQuery = MediaQuery.of(content);
  return mediaQuery.size.height - mediaQuery.padding.horizontal;
}

const miniPlayerPercentageDeclaration = 0.2;
const kAppBottomNavigationBarHeight = 89.0;

class AppBottomNavigationBar extends HookConsumerWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context);
    useEffect(
      () {
        ref.read(podcastServiceProvider).setup(locale);
        return null;
      },
      [],
    );

    final playingEpisode = ref.watch(
      audioPlayerServiceProvider.select((state) => state?.episode),
    );
    final theme = Theme.of(context);
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
              Align(
                alignment: Alignment.bottomCenter,
                child: DetailedPlayer(
                  minHeight: playerMinHeight,
                  maxHeight: playerMaxHeight(context),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: playerExpandProgress,
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
          // FIXME(reedom): replace with surface container
          backgroundColor: theme.colorScheme.surfaceVariant,
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
              icon: const Icon(Icons.home),
              label: AppLocalizations.of(context)!.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.search),
              label: AppLocalizations.of(context)!.search,
            ),
            // const BottomNavigationBarItem(
            //   icon: Icon(Icons.settings),
            //   label: 'settings',
            // ),
          ],
        ),
      ),
    );
  }
}
