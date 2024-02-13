// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/ui/search/podcast_search_bar.dart';
import 'package:seasoning/ui/widgets/podcast_list.dart';

class PodcastListWithSearchBar extends StatelessWidget {
  const PodcastListWithSearchBar({super.key, this.results = const []});

  final List<Podcast> results;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ShrinkWrappingViewport(
        offset: ViewportOffset.zero(),
        slivers: [
          const SliverToBoxAdapter(child: PodcastSearchBar()),
          PodcastList(results: results),
        ],
      ),
    );
  }
}
