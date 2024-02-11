// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:seasoning/entities/transcript.dart';

part 'transcript_event.freezed.dart';

@freezed
class TranscriptEvent with _$TranscriptEvent {
  const factory TranscriptEvent.clear() = TranscriptClearEvent;

  const factory TranscriptEvent.filter({
    required String search,
  }) = TranscriptFilterEvent;
}

/// State
@freezed
class TranscriptState with _$TranscriptState {
  const factory TranscriptState.unavailable() = TranscriptUnavailableState;

  const factory TranscriptState.loading() = TranscriptLoadingState;

  const factory TranscriptState.update({
    required Transcript transcript,
    @Default(false) bool isFiltered,
  }) = TranscriptUpdateState;
}
