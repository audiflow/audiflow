// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/downloadable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_event.g.dart';

sealed class DownloadEvent {}

class DownloadUpdatedEvent implements DownloadEvent {
  const DownloadUpdatedEvent(this.download);

  final Downloadable download;
}

class DownloadDeletedEvent implements DownloadEvent {
  const DownloadDeletedEvent(this.download);

  final Downloadable download;
}

@Riverpod(keepAlive: true)
class DownloadEventStream extends _$DownloadEventStream {
  @override
  Stream<DownloadEvent> build() async* {}

  void add(DownloadEvent event) {
    state = AsyncData(event);
  }
}
