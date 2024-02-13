// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seasoning/bloc/search/search_state_event.dart';
import 'package:seasoning/l10n/L.dart';
import 'package:seasoning/providers/podcast_search_provider.dart';
import 'package:seasoning/ui/search/search_results.dart';

/// This widget renders the search bar and allows the user to search for
/// podcasts.
class SearchPage extends HookConsumerWidget {
  const SearchPage({
    super.key,
    this.searchTerm,
  });

  final String? searchTerm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();

    useEffect(
      () {
        if (searchTerm?.isNotEmpty == true) {
          ref
              .read(podcastSearchProvider.notifier)
              .search(SearchTermEvent(searchTerm!));
        }
        return null;
      },
      [searchTerm],
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            leading: IconButton(
              tooltip: L.of(context)!.search_back_button_label,
              icon: Platform.isAndroid
                  ? Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).appBarTheme.foregroundColor,
                    )
                  : const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context),
            ),
            title: Semantics(
              label: L.of(context)!.search_for_podcasts_hint,
              textField: true,
              child: TextField(
                controller: searchController,
                focusNode: searchFocusNode,
                autofocus: searchTerm != null,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
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
                      .search(SearchTermEvent(value));
                },
              ),
            ),
            pinned: true,
            actions: <Widget>[
              IconButton(
                tooltip: L.of(context)!.clear_search_button_label,
                icon: const Icon(Icons.clear),
                onPressed: () {
                  searchController.clear();
                  FocusScope.of(context).requestFocus(searchFocusNode);
                  SystemChannels.textInput
                      .invokeMethod<String>('TextInput.show');
                },
              ),
            ],
          ),
          const SearchResults(),
        ],
      ),
    );
  }
}
