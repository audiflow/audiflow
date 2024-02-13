// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seasoning/l10n/L.dart';
import 'package:seasoning/providers/podcast_search_provider.dart';
import 'package:seasoning/ui/widgets/platform_progress_indicator.dart';
import 'package:seasoning/ui/widgets/podcast_list.dart';

class SearchResults extends ConsumerWidget {
  const SearchResults({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(podcastSearchProvider);

    if (state.isLoading) {
      print('!!! isLoading');
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            PlatformProgressIndicator(),
          ],
        ),
      );
    }

    if (state.hasError) {
      print('!!! hasError');
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

    if (state.hasValue && state.value!.term.isNotEmpty) {
      print('!!! PodcastList');
      return PodcastList(results: state.value!.results);
    } else {
      print('!!! SliverFillRemaining');
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Container(),
      );
    }
  }
}
