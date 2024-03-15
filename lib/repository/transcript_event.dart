// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transcript_event.g.dart';

sealed class TranscriptEvent {}

class TranscriptClearEvent implements TranscriptEvent {
  const TranscriptClearEvent();
}

class TranscriptFilterEvent implements TranscriptEvent {
  const TranscriptFilterEvent({
    required this.search,
  });

  final String search;
}

@Riverpod(keepAlive: true)
class TranscriptEventStream extends _$TranscriptEventStream {
  @override
  Stream<TranscriptEvent> build() async* {}

  void add(TranscriptEvent event) {
    state = AsyncData(event);
  }
}
