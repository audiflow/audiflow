// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A class that represents the genre(s) the podcast is related to.
class Genre {
  const Genre(
    this.id,
    this.name,
  );

  /// Genre ID.
  final int id;

  /// Genre name.
  final String name;

  @override
  String toString() {
    return '$id: $name';
  }
}
