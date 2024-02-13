// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seasoning/l10n/L.dart';
import 'package:seasoning/ui/search/search_page.dart';
import 'package:seasoning/ui/widgets/search_slide_route.dart';

class PodcastSearchBar extends HookConsumerWidget {
  const PodcastSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 16),
      title: TextField(
        controller: searchController,
        focusNode: searchFocusNode,
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
        onSubmitted: (value) async {
          await Navigator.push(
            context,
            SlideRightRoute(
              widget: SearchPage(searchTerm: value),
              settings: const RouteSettings(name: 'search'),
            ),
          );
          searchController.clear();
        },
      ),
      trailing: IconButton(
        padding: EdgeInsets.zero,
        tooltip: searchFocusNode.hasFocus
            ? L.of(context)!.clear_search_button_label
            : null,
        color: searchFocusNode.hasFocus
            ? Theme.of(context).iconTheme.color
            : null,
        splashColor: searchFocusNode.hasFocus
            ? Theme.of(context).splashColor
            : Colors.transparent,
        highlightColor: searchFocusNode.hasFocus
            ? Theme.of(context).highlightColor
            : Colors.transparent,
        icon: Icon(
          searchController.text.isEmpty && !searchFocusNode.hasFocus
              ? Icons.search
              : Icons.clear,
        ),
        onPressed: () {
          searchController.clear();
          FocusScope.of(context).requestFocus(FocusNode());
          SystemChannels.textInput.invokeMethod<String>('TextInput.show');
        },
      ),
    );
  }
}
