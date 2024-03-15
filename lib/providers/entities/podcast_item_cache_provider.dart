// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:podcast_search/podcast_search.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_item_cache_provider.g.dart';

@riverpod
class PodcastItemCache extends _$PodcastItemCache {
  @override
  Map<String, Item> build() => {};

  Future<void> add(Item item) async {
    state = {...state, item.feedUrl!: item};
  }

  Future<void> remove(Item item) async {
    state = Map<String, Item>.fromEntries(
      state.entries.where((i) => i.key != item.feedUrl),
    );
  }
}
