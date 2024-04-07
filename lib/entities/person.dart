// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:isar/isar.dart';
import 'package:podcast_feed/podcast_feed.dart' as feed;

part 'person.g.dart';

/// This class represents a person of interest to the podcast.
///
/// It is primarily intended to identify people like hosts, co-hosts and guests.
@collection
class Person {
  Person({
    required this.name,
    this.role,
    this.group,
    this.image,
    this.link,
  });

  factory Person.fromFeed(feed.Person person) => Person(
        name: person.name,
        role: person.role,
        group: person.group,
        image: person.image,
        link: person.link,
      );

  Id? id;
  final String name;
  final String? role;
  final String? group;
  final String? image;
  final String? link;
}
