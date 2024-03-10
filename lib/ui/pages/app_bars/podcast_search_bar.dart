// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/core/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// import 'package:audiflow/providers/podcast_search_provider.dart';
// import 'package:audiflow/ui/search/search_results.dart';

class PodcastSearchBar extends HookConsumerWidget {
  const PodcastSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();

    return SliverAppBar(
      // leading: IconButton(
      //   tooltip: L10n.of(context)!.search_back_button_label,
      //   icon: Platform.isAndroid
      //       ? Icon(
      //           Icons.arrow_back,
      //           color: Theme.of(context).appBarTheme.foregroundColor,
      //         )
      //       : const Icon(Icons.arrow_back_ios),
      //   onPressed: () => Navigator.pop(context),
      // ),
      pinned: true,
      expandedHeight: 100,
      flexibleSpace: const FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: EdgeInsetsDirectional.only(start: 20, bottom: 20),
        title: Text('Search'),
      ),
      title: Semantics(
        label: L10n.of(context)!.search_for_podcasts_hint,
        textField: true,
        child: TextField(
          controller: searchController,
          focusNode: searchFocusNode,
          // autofocus: searchTerm != null,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: L10n.of(context)!.search_for_podcasts_hint,
            border: InputBorder.none,
          ),
          style: TextStyle(
            color: Theme.of(context).primaryIconTheme.color,
            fontSize: 18,
            decorationColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          onSubmitted: (value) {
            SemanticsService.announce(
              L10n.of(context)!.semantic_announce_searching,
              TextDirection.ltr,
            );
            // ref
            //     .read(podcastSearchProvider.notifier)
            //     .search(SearchTermEvent(value));
          },
        ),
      ),
      actions: <Widget>[
        IconButton(
          tooltip: L10n.of(context)!.clear_search_button_label,
          icon: const Icon(Icons.clear),
          onPressed: () {
            searchController.clear();
            FocusScope.of(context).requestFocus(searchFocusNode);
            SystemChannels.textInput.invokeMethod<String>('TextInput.show');
          },
        ),
      ],
    );
  }
}
