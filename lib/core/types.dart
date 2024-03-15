// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:flutter/widgets.dart';

/// The order in which episodes are played.
enum PlayOrder {
  /// Play episodes in ascending order.
  timeAscend,

  /// Play episodes in descending order.
  timeDescend,
}

class PlayButtonTappedNotification extends Notification {
  PlayButtonTappedNotification(this.episode, {this.index});

  final Episode episode;
  final int? index;
}
