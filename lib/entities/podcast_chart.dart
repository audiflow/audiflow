// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'podcast_chart.freezed.dart';

@freezed
class PodcastChartState with _$PodcastChartState {
  const factory PodcastChartState({
    int? size,
    String? genre,
    String? countryCode,
    @Default([]) List<Podcast> podcasts,
    DateTime? expiresAt,
  }) = _PodcastChartState;
}

extension PodcastChartStateExt on PodcastChartState {
  bool get isExpired => expiresAt?.isBefore(DateTime.now()) ?? true;
}
