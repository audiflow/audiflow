// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/country.dart';

sealed class PodcastChartEvent {}

class NewPodcastChartEvent implements PodcastChartEvent {
  const NewPodcastChartEvent({
    this.size = 20,
    this.genre,
    this.country,
    this.refresh = false,
  });

  final int size;
  final String? genre;
  final Country? country;
  final bool refresh;
}
