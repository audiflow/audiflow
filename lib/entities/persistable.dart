// Copyright 2020 Ben Hills. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'persistable.freezed.dart';
part 'persistable.g.dart';

enum LastState { none, completed, stopped, paused }

/// This class is used to persist information about the currently playing episode to disk.
///
/// This allows the background audio service to persist state (whilst the UI is not visible)
/// and for the episode play and position details to be restored when the UI becomes visible
/// again - either when bringing it to the foreground or upon next start.
@freezed
class Persistable with _$Persistable {
  const factory Persistable({
    /// The Podcast GUID.
    required String pguid,

    /// The episode ID (provided by the DB layer).
    required int episodeId,

    /// The current position in seconds;
    required int position,

    /// The current playback state.
    required LastState state,

    /// Date & time episode was last updated.
    DateTime? lastUpdated,
  }) = _Persistable;

  factory Persistable.fromJson(Map<String, dynamic> json) =>
      _$PersistableFromJson(json);

  // ignore: prefer_constructors_over_static_methods
  static Persistable empty() => Persistable(
        pguid: '',
        episodeId: 0,
        position: 0,
        state: LastState.none,
        lastUpdated: DateTime.now(),
      );
}
