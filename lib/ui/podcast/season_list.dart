// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/providers/podcast/podcast_info_provider.dart';
import 'package:audiflow/providers/podcast/podcast_seasons_provider.dart';
import 'package:audiflow/ui/podcast/season_tile.dart';
import 'package:audiflow/ui/widgets/fill_remaining_error.dart';
import 'package:audiflow/ui/widgets/fill_remaining_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SeasonList extends ConsumerWidget {
  const SeasonList({
    super.key,
    required this.podcast,
    this.icon = _defaultIcon,
    this.emptyMessage = '',
  });

  final Podcast podcast;
  final IconData icon;
  final String emptyMessage;

  static const _defaultIcon = Icons.add_alert;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonsState = ref.watch(podcastSeasonsProvider(podcast.metadata));
    final podcastState = ref.watch(podcastInfoProvider(podcast.metadata));
    if (seasonsState.isLoading || podcastState.isLoading) {
      return const FillRemainingLoading();
    } else if (seasonsState.hasError || seasonsState.value!.isEmpty) {
      return FillRemainingError.podcastNoResults();
    }

    final ascend = podcastState.valueOrNull?.stats?.ascend ?? false;
    final seasons =
        ascend ? seasonsState.value!.reversed.toList() : seasonsState.value!;
    return SliverSafeArea(
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return SeasonTile(
              podcast: podcast,
              season: seasons[index],
            );
          },
          childCount: seasons.length,
          addAutomaticKeepAlives: false,
        ),
      ),
    );
  }
}
