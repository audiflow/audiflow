// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
