// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/core/l10n.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/events/podcast_search_event.dart';
import 'package:audiflow/ui/pages/app_bars/sub_page_app_bar.dart';
import 'package:audiflow/ui/podcast/episode_list.dart';
import 'package:audiflow/ui/providers/podcast_search_provider.dart';
import 'package:audiflow/ui/providers/recently_played_episodes_provider.dart';
import 'package:audiflow/ui/widgets/error_notifier.dart';
import 'package:audiflow/ui/widgets/fill_remaining_error.dart';
import 'package:audiflow/ui/widgets/fill_remaining_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';

class RecentlyPlayedPage extends HookConsumerWidget {
  const RecentlyPlayedPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recentlyPlayedEpisodesProvider);

    final controller = useScrollController();
    return ScrollsToTop(
      onScrollsToTop: (event) async {
        await controller.animateTo(
          event.to,
          duration: event.duration,
          curve: event.curve,
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              controller: controller,
              slivers: <Widget>[
                SubPageAppBar(title: L10n.of(context)!.recentlyPlayed),
                if (state.isLoading)
                  const FillRemainingLoading()
                else if (state.hasError ||
                    state.valueOrNull?.episodes.isEmpty == true)
                  FillRemainingError.podcastNoResults()
                else
                  EpisodeList(
                    episodeGroupKey: const Key('recentlyPlayed'),
                    episodes: state.value!.episodes
                        .map((e) => e.toPartialEpisode())
                        .toList(),
                    scrollController: controller,
                  ),
              ],
            ),
            const ErrorNotifier(),
          ],
        ),
      ),
    );
  }
}

class SearchBar extends HookConsumerWidget {
  const SearchBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();

    final term = useState('');

    useEffect(() {
      void onChange() => term.value = searchController.text;
      searchController.addListener(onChange);
      return () => searchController.removeListener(onChange);
    });

    final theme = Theme.of(context);
    return Semantics(
      label: L10n.of(context)!.search_for_podcasts_hint,
      textField: true,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Container(
          color: theme.colorScheme.surface,
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.dividerColor,
              width: 0.5,
            ),
          ),
          child: TextField(
            controller: searchController,
            focusNode: searchFocusNode,
            autocorrect: false,
            // autofocus: searchTerm != null,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              suffixIcon: term.value.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(
                        Icons.clear,
                        size: 32,
                      ),
                      onPressed: searchController.clear,
                    ),
              hintText: L10n.of(context)!.search_for_podcasts_hint,
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 18),
            onSubmitted: (value) {
              SemanticsService.announce(
                L10n.of(context)!.semantic_announce_searching,
                TextDirection.ltr,
              );
              ref
                  .read(podcastSearchProvider.notifier)
                  .input(NewPodcastSearchEvent(term: value));
            },
          ),
        ),
      ),
    );
  }
}
