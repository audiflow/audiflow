// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/ui/podcast/podcast_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PodcastList extends ConsumerWidget {
  const PodcastList({
    super.key,
    required this.results,
  });

  final List<PodcastMetadata> results;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (results.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return PodcastTile(metadata: results[index]);
        },
        childCount: results.length,
        addAutomaticKeepAlives: false,
      ),
    );
  }
}
