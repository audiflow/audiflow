// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/repository/download_event.dart';
import 'package:audiflow/services/download/download_service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:audiflow/services/download/download_service.dart';

part 'download_progress_provider.g.dart';

@riverpod
class DownloadProgress extends _$DownloadProgress {
  @override
  Future<Downloadable?> build(Episode episode) async {
    _listen(episode);
    // initial
    return ref.watch(downloadServiceProvider).findDownloadByGuid(episode.guid);
  }

  void _listen(Episode episode) {
    ref.listen(downloadEventStreamProvider, (_, next) {
      final event = next.valueOrNull;
      switch (event) {
        case DownloadUpdatedEvent(download: final download):
          if (download.guid == episode.guid) {
            state = AsyncData(download);
          }
        case DownloadDeletedEvent(download: final download):
          if (download.guid == episode.guid) {
            state = const AsyncData(null);
          }
        case null:
      }
    });
  }
}
