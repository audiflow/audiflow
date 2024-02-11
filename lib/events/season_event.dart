// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:seasoning/entities/season.dart';

abstract class SeasonEvent {
  SeasonEvent(this.season);

  final Season season;
}

class SeasonUpdateEvent extends SeasonEvent {
  SeasonUpdateEvent(super.season);
}

class SeasonDeleteEvent extends SeasonEvent {
  SeasonDeleteEvent(super.season);
}
