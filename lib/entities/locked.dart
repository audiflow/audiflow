// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:isar/isar.dart';
import 'package:podcast_feed/podcast_feed.dart' as feed;

part 'locked.g.dart';

@collection
class Locked {
  Locked({
    required this.locked,
    required this.owner,
  });

  factory Locked.fromFeed(feed.Locked locked) {
    return Locked(
      locked: locked.locked,
      owner: locked.owner,
    );
  }

  Id? id;
  final bool locked;
  final String? owner;
}
