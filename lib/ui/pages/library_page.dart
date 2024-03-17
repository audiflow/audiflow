// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/core/l10n.dart';
import 'package:audiflow/events/podcast_search_event.dart';
import 'package:audiflow/ui/app/navigation_helper.dart';
import 'package:audiflow/ui/pages/app_bars/basic_app_bar.dart';
import 'package:audiflow/ui/providers/podcast_search_provider.dart';
import 'package:audiflow/ui/widgets/error_notifier.dart';
import 'package:audiflow/ui/widgets/fill_remaining_error.dart';
import 'package:audiflow/ui/widgets/fill_remaining_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';

class LibraryPage extends HookConsumerWidget {
  const LibraryPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(podcastSearchProvider);

    final controller = useScrollController();
    final l10n = L10n.of(context)!;
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
                BasicAppBar(title: L10n.of(context)!.library),
                if (state.isLoading)
                  const FillRemainingLoading()
                else if (state.hasError ||
                    (state.valueOrNull?.notFound == true))
                  FillRemainingError.podcastNoResults()
                else
                  SliverFixedExtentList(
                    itemExtent: 60,
                    delegate: SliverChildListDelegate(
                      [
                        ListTile(
                          leading: const Icon(Symbols.history),
                          title: Text(l10n.recentlyPlayed),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: NavigationHelper.pushRecentlyPlayed,
                        ),
                      ],
                    ),
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
