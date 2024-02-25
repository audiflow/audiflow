// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'downloadable.freezed.dart';
part 'downloadable.g.dart';

enum DownloadState {
  none,
  queued,
  downloading,
  failed,
  cancelled,
  paused,
  downloaded
}

/// A Downloadable is an object that holds information about a podcast episode
/// and its download status.
///
/// Downloadable can be used to determine if a download has been successful and
/// if an episode can be played from the filesystem.
@freezed
class Downloadable with _$Downloadable {
  const factory Downloadable({
    /// The GUID for an associated podcast.
    required String pguid,

    /// Unique identifier for the episode.
    required String guid,

    /// Unique identifier for the download
    required String url,

    /// Destination directory
    required String directory,

    /// Name of file
    required String filename,

    /// Current task ID for the download
    required String taskId,

    /// Current state of the download
    required DownloadState state,

    /// Percentage of MP3 downloaded
    @Default(0) int percentage,
  }) = _Downloadable;

  factory Downloadable.fromJson(Map<String, dynamic> json) =>
      _$DownloadableFromJson(json);
}

extension DownloadableExt on Downloadable {
  bool get downloaded => state == DownloadState.downloaded;
}
