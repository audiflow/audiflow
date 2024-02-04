// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transcript.freezed.dart';
part 'transcript.g.dart';

enum TranscriptFormat {
  json,
  subrip,
  unsupported,
}

/// This class represents a Podcasting 2.0 transcript URL.
///
/// [docs](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#transcript)
@freezed
class TranscriptUrl with _$TranscriptUrl {
  const factory TranscriptUrl({
    required String url,
    required TranscriptFormat type,
    @Default('') String language,
    @Default('') String rel,
    DateTime? lastUpdated,
  }) = _TranscriptUrl;

  factory TranscriptUrl.fromJson(Map<String, dynamic> json) =>
      _$TranscriptUrlFromJson(json);
}

/// This class represents a Podcasting 2.0 transcript container.
/// [docs](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#transcript)
@freezed
class Transcript with _$Transcript {
  const factory Transcript({
    int? id,
    required String guid,
    @Default(<Subtitle>[]) List<Subtitle> subtitles,
    @Default(false) bool filtered,
    DateTime? lastUpdated,
  }) = _Transcript;

  factory Transcript.fromJson(Map<String, dynamic> json) =>
      _$TranscriptFromJson(json);
}

/// Represents an individual line within a transcript.
@freezed
class Subtitle with _$Subtitle {
  const factory Subtitle({
    required int index,
    required Duration start,
    Duration? end,
    String? data,
    @Default('') String speaker,
  }) = _Subtitle;

  factory Subtitle.fromJson(Map<String, dynamic> json) =>
      _$SubtitleFromJson(json);
}
