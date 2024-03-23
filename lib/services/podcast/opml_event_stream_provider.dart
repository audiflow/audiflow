//  Copyright (c) 2024 by HANAI, Tohru.
//  Copyright (c) 2024 Reedom, Inc.
//  Additional contributions from project contributors.
//  All rights reserved.
//  Use of this source code is governed by a BSD-style license that can be
//  found in the LICENSE file.

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'opml_event_stream_provider.g.dart';

@Riverpod(dependencies: [])
class OpmlEventStream extends _$OpmlEventStream {
  @override
  Stream<OPMLEvent> build() async* {}

  void add(OPMLEvent event) {
    state = AsyncData(event);
  }
}

sealed class OPMLEvent {}

class OPMLLoadingEvent implements OPMLEvent {
  OPMLLoadingEvent({
    required this.current,
    required this.total,
    required this.podcastTitle,
  });

  final int current;
  final int total;
  final String podcastTitle;
}

class OPMLCompletedEvent implements OPMLEvent {}

class OPMLErrorEvent implements OPMLEvent {}
