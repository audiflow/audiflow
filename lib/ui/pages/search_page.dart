// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seasoning/events/podcast_search_event.dart';
import 'package:seasoning/l10n/L.dart';
import 'package:seasoning/providers/podcast/podcast_search_provider.dart';
import 'package:seasoning/ui/pages/app_bars/basic_app_bar.dart';
import 'package:seasoning/ui/podcast/podcast_list.dart';
import 'package:seasoning/ui/widgets/error_notifier.dart';
import 'package:seasoning/ui/widgets/fill_remaining_error.dart';
import 'package:seasoning/ui/widgets/fill_remaining_loading.dart';
import 'package:sliver_tools/sliver_tools.dart';

class SearchPage extends HookConsumerWidget {
  const SearchPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(podcastSearchProvider);

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: <Widget>[
              BasicAppBar.search(),
              const SliverPinnedHeader(child: SearchBar()),
              if (state.isLoading)
                const FillRemainingLoading()
              else if (state.hasError || (state.valueOrNull?.notFound == true))
                FillRemainingError.podcastNoResults()
              else
                PodcastList(results: state.value!.podcasts),
            ],
          ),
          const ErrorNotifier(),
        ],
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

    return Semantics(
      label: L.of(context)!.search_for_podcasts_hint,
      textField: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Theme.of(context).appBarTheme.backgroundColor,
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
            hintText: L.of(context)!.search_for_podcasts_hint,
            border: InputBorder.none,
          ),
          style: TextStyle(
            color: Theme.of(context).primaryIconTheme.color,
            fontSize: 18,
            decorationColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          onSubmitted: (value) {
            SemanticsService.announce(
              L.of(context)!.semantic_announce_searching,
              TextDirection.ltr,
            );
            ref
                .read(podcastSearchProvider.notifier)
                .input(NewPodcastSearchEvent(term: value));
          },
        ),
      ),
    );
  }
}
