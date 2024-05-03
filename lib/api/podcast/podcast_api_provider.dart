// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/api/podcast/mobile_podcast_api.dart';
import 'package:audiflow/api/podcast/podcast_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:audiflow/api/podcast/podcast_api.dart';

part 'podcast_api_provider.g.dart';

@Riverpod(keepAlive: true)
PodcastApi podcastApi(PodcastApiRef ref) =>
    MobilePodcastApi()..ensureInitialized();
