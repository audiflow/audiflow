// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';

abstract class DownloadService {
  Future<bool> downloadEpisode(Episode episode);

  Future<void> deleteDownload(Episode episode);

  Future<Downloadable?> findDownloadByGuid(String guid);

  void dispose();
}
