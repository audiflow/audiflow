// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';

abstract class DownloadService {
  Future<bool> downloadEpisode(Episode episode);

  Future<bool> downloadEpisodes(Iterable<Episode> episodes);

  Future<void> deleteDownload(Episode episode);

  Future<Downloadable?> findDownloadByGuid(String guid);

  void dispose();
}
