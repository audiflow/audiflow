// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:audiflow/api/podcast/mobile_podcast_api.dart';
import 'package:podcast_feed/podcast_feed.dart';

/// This Mock version of the Podcast API replaces loading via URL
/// with loading via local file. This allows use to test API
/// loading without requiring an Internet connection.
class MockPodcastApi extends MobilePodcastApi {
  MockPodcastApi(super._ref);

  @override
  Future<(ChannelValues?, ItemParser?)> loadFeed(String? url) async {
    final f = File(url!);
    if (!f.existsSync()) {
      return (null, null);
    }
    final rss = f.readAsStringSync();
    final (channelParser, itemParser) = await createPodcastFeedParsers(rss);
    final channelValue = await channelParser.parseWith((value) => value).first;
    return (channelValue, itemParser);
  }
}
