// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:isar/isar.dart';
import 'package:podcast_feed/podcast_feed.dart' as feed;

part 'funding.g.dart';

/// part of a [Podcast].
///
/// Part of the [podcast namespace](https://github.com/Podcastindex-org/podcast-namespace)
@collection
class Funding {
  Funding({
    required this.url,
    required this.value,
  });

  factory Funding.fromFeed(feed.Funding funding) {
    return Funding(
      url: funding.url!,
      value: funding.value ?? '',
    );
  }

  Id? id;

  /// The URL to the funding/donation/information page.
  final String url;

  /// The label for the link which will be presented to the user.
  final String value;
}
