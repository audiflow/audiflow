// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'person.freezed.dart';
part 'person.g.dart';

/// This class represents a person of interest to the podcast.
///
/// It is primarily intended to identify people like hosts, co-hosts and guests.
@freezed
class Person with _$Person {
  const factory Person({
    required String name,
    @Default('') String role,
    @Default('') String group,
    @Default('') String image,
    @Default('') String link,
  }) = _Person;

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
}
