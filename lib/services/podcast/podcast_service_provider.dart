// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/services/podcast/mobile_podcast_service.dart';
import 'package:audiflow/services/podcast/podcast_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:audiflow/services/podcast/podcast_service.dart';

part 'podcast_service_provider.g.dart';

@Riverpod(keepAlive: true)
PodcastService podcastService(PodcastServiceRef ref) =>
    MobilePodcastService(ref);
