// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'queue.freezed.dart';
part 'queue.g.dart';

/// The current persistable queue.

@freezed
class Queue with _$Queue {
  const factory Queue({
    @Default(<String>[]) List<String> primary,
    @Default(<String>[]) List<String> adhoc,
  }) = _Queue;

  factory Queue.fromJson(Map<String, dynamic> json) => _$QueueFromJson(json);
}
