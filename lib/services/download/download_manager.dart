// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:seasoning/entities/downloadable.dart';

class DownloadProgress {
  DownloadProgress(
    this.id,
    this.percentage,
    this.status,
  );

  final String id;
  final int percentage;
  final DownloadState status;
}

abstract class DownloadManager {
  Future<void> setup();

  Future<String?> enqueueTask(String url, String downloadPath, String fileName);

  Stream<DownloadProgress> get downloadProgress;

  void dispose();
}
