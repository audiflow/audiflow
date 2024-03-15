// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sleep.freezed.dart';
part 'sleep.g.dart';

enum SleepType {
  none,
  time,
  episode,
}

@freezed
class Sleep with _$Sleep {
  const factory Sleep({
    required SleepType type,
    @Default(Duration.zero) Duration duration,
  }) = _Sleep;

  factory Sleep.fromJson(Map<String, dynamic> json) => _$SleepFromJson(json);
}

extension SleepExt on Sleep {
  // Custom getter to calculate endTime based on current time and duration
  DateTime get endTime => DateTime.now().add(duration);
}
