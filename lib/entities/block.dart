// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:isar/isar.dart';

part 'block.g.dart';

/// This class represents a PC2.0 [block](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#block) tag.
@collection
class Block {
  Block({
    required this.block,
    this.blockId,
  });

  Id? id;
  final bool block;
  final String? blockId;
}
