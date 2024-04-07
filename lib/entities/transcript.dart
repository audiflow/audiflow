// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';
import 'package:podcast_feed/podcast_feed.dart' as feed;

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
@collection
class TranscriptUrl {
  TranscriptUrl({
    this.url = '',
    this.type = TranscriptFormat.unsupported,
    this.language = '',
    this.rel = '',
  });

  factory TranscriptUrl.fromFeed(feed.TranscriptUrl t) {
    TranscriptFormat type;
    switch (t.type) {
      case feed.TranscriptFormat.subrip:
        type = TranscriptFormat.subrip;
      case feed.TranscriptFormat.json:
        type = TranscriptFormat.json;
      case feed.TranscriptFormat.unsupported:
        type = TranscriptFormat.unsupported;
    }
    return TranscriptUrl(
      url: t.url,
      type: type,
      language: t.language,
      rel: t.rel,
    );
  }

  Id? id;

  /// The URL for the transcript.
  final String url;

  /// The type of transcript: json or srt
  @enumerated
  final TranscriptFormat type;

  /// The language for the transcript
  final String language;

  /// If set to captions, shows that this is a closed-caption file
  final String rel;
}

/// This class represents a Podcasting 2.0 transcript container.
/// [docs](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#transcript)
@freezed
class Transcript with _$Transcript {
  const factory Transcript({
    int? id,
    required String pguid,
    required String guid,
    @Default(<Subtitle>[]) List<Subtitle> subtitles,
    @Default(false) bool filtered,
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
