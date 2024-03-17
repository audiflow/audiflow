//  Copyright (c) 2024 by HANAI, Tohru.
//  Copyright (c) 2024 Reedom, Inc.
//  Additional contributions from project contributors.
//  All rights reserved.
//  Use of this source code is governed by a BSD-style license that can be
//  found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'episodes_list_event_provider.g.dart';

@Riverpod(dependencies: [])
class EpisodesListEventStream extends _$EpisodesListEventStream {
  @override
  Stream<EpisodesListEvent> build() async* {}

  void add(EpisodesListEvent event) {
    state = AsyncData(event);
  }
}

sealed class EpisodesListEvent {}

class MenuScrollToEpisodeEvent implements EpisodesListEvent {
  const MenuScrollToEpisodeEvent();
}

@riverpod
class EpisodesListActionStream extends _$EpisodesListActionStream {
  @override
  Stream<EpisodesListAction> build() async* {}

  void add(EpisodesListAction action) {
    state = AsyncData(action);
  }
}

sealed class EpisodesListAction {}

class ScrollToWidgetAction implements EpisodesListAction {
  const ScrollToWidgetAction(this.key);

  final Key key;
}
