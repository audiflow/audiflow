// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_providers.freezed.dart';
part 'search_providers.g.dart';

/// Anytime can support multiple search providers.
///
/// This class represents a provider.
@freezed
class SearchProvider with _$SearchProvider {
  const factory SearchProvider({
    required String key,
    required String name,
  }) = _SearchProvider;

  factory SearchProvider.fromJson(Map<String, dynamic> json) =>
      _$SearchProviderFromJson(json);
}
