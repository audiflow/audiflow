// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seasoning/entities/podcast.dart';
import 'package:seasoning/l10n/L.dart';
import 'package:seasoning/providers/settings_service_provider.dart';
import 'package:seasoning/ui/widgets/podcast_grid_tile.dart';
import 'package:seasoning/ui/widgets/podcast_tile.dart';

class PodcastList extends ConsumerWidget {
  const PodcastList({
    super.key,
    required this.results,
  });

  final List<Podcast> results;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (results.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.search,
                size: 75,
                color: Theme.of(context).primaryColor,
              ),
              Text(
                L.of(context)!.no_search_results_message,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final settings = ref.watch(settingsServiceProvider);
    final mode = settings.layoutMode;
    final size = mode == 1 ? 100.0 : 160.0;

    return mode == 0
        ? SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return PodcastTile(podcast: results[index]);
              },
              childCount: results.length,
              addAutomaticKeepAlives: false,
            ),
          )
        : SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: size,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return PodcastGridTile(podcast: results[index]);
              },
              childCount: results.length,
            ),
          );
  }
}
