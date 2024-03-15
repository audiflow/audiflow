// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/repository/repository_provider.dart';
import 'package:audiflow/services/podcast/mobile_opml_service.dart';
import 'package:audiflow/services/podcast/opml_service.dart';
import 'package:audiflow/services/podcast/podcast_service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:audiflow/services/podcast/opml_service.dart';

part 'opml_service_provider.g.dart';

@riverpod
OPMLService opmlService(OpmlServiceRef ref) {
  final repository = ref.watch(repositoryProvider);
  final podcastService = ref.watch(podcastServiceProvider);
  return MobileOPMLService(
    repository: repository,
    podcastService: podcastService,
  );
}
