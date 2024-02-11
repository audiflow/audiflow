// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart' as search;
import 'package:seasoning/events/bloc_state.dart';
import 'package:seasoning/l10n/L.dart';
import 'package:seasoning/ui/widgets/platform_progress_indicator.dart';
import 'package:seasoning/ui/widgets/podcast_list.dart';

class SearchResults extends StatelessWidget {
  const SearchResults({
    super.key,
    required this.data,
  });
  final Stream<BlocState> data;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BlocState>(
      stream: data,
      builder: (BuildContext context, AsyncSnapshot<BlocState> snapshot) {
        final state = snapshot.data;

        if (state is BlocPopulatedState) {
          return PodcastList(results: state.results as search.SearchResult);
        } else {
          if (state is BlocLoadingState) {
            return const SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  PlatformProgressIndicator(),
                ],
              ),
            );
          } else if (state is BlocErrorState) {
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

          return SliverFillRemaining(
            hasScrollBody: false,
            child: Container(),
          );
        }
      },
    );
  }
}
