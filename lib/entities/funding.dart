// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:podcast_search/podcast_search.dart' as search;

part 'funding.freezed.dart';
part 'funding.g.dart';

/// part of a [Podcast].
///
/// Part of the [podcast namespace](https://github.com/Podcastindex-org/podcast-namespace)
@freezed
class Funding with _$Funding {
  const factory Funding({
    /// The URL to the funding/donation/information page.
    required String url,

    /// The label for the link which will be presented to the user.
    required String value,
  }) = _Funding;

  factory Funding.fromJson(Map<String, dynamic> json) =>
      _$FundingFromJson(json);

  factory Funding.fromSearch(search.Funding funding) {
    return Funding(
      url: funding.url!,
      value: funding.value ?? '',
    );
  }
}
