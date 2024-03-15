// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:podcast_search/podcast_search.dart' as search;

part 'person.freezed.dart';
part 'person.g.dart';

/// This class represents a person of interest to the podcast.
///
/// It is primarily intended to identify people like hosts, co-hosts and guests.
@freezed
class Person with _$Person {
  const factory Person({
    required String name,
    String? role,
    String? group,
    String? image,
    String? link,
  }) = _Person;

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);

  factory Person.fromSearch(search.Person person) => Person(
        name: person.name,
        role: person.role,
        group: person.group,
        image: person.image,
        link: person.link,
      );
}
