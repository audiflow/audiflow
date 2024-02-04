// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:seasoning/entities/season.dart';

abstract class SeasonState {
  SeasonState(this.season);

  final Season season;
}

class SeasonUpdateState extends SeasonState {
  SeasonUpdateState(super.season);
}

class SeasonDeleteState extends SeasonState {
  SeasonDeleteState(super.season);
}
