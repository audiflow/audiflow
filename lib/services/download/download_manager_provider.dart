// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/services/download/download_manager.dart';
import 'package:audiflow/services/download/mobile_download_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:audiflow/services/download/download_manager.dart';

part 'download_manager_provider.g.dart';

@Riverpod(keepAlive: true)
DownloadManager downloadManager(DownloadManagerRef ref) =>
    MobileDownloaderManager(ref);
