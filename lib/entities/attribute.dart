// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// An enum that provides a list of valid attributes for podcasts.
enum Attribute {
  none(attribute: ''),
  title(attribute: 'titleTerm'),
  language(attribute: 'languageTerm'),
  author(attribute: 'authorTerm'),
  genre(attribute: 'genreIndex'),
  artist(attribute: 'artistTerm'),
  rating(attribute: 'ratingIndex'),
  keywords(attribute: 'keywordsTerm'),
  description(attribute: 'descriptionTerm');

  const Attribute({
    required this.attribute,
  });

  final String attribute;
}
