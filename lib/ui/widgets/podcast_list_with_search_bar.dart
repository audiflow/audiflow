// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:podcast_search/podcast_search.dart' as search;
import 'package:seasoning/ui/search/search_bar.dart' as search;
import 'package:seasoning/ui/widgets/podcast_list.dart';

class PodcastListWithSearchBar extends StatelessWidget {

  const PodcastListWithSearchBar({super.key, required this.results});
  final search.SearchResult results;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ShrinkWrappingViewport(
        offset: ViewportOffset.zero(),
        slivers: [
          const SliverToBoxAdapter(child: search.SearchBar()),
          PodcastList(results: results),
        ],
      ),
    );
  }
}
