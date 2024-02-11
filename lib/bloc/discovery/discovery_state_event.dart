// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Events
class DiscoveryEvent {}

class DiscoveryChartEvent extends DiscoveryEvent {
  DiscoveryChartEvent({
    required this.count,
    this.genre = '',
    this.countryCode = '',
  });
  final int count;
  String genre;
  String countryCode;
}

/// States
class DiscoveryState {}

class DiscoveryLoadingState extends DiscoveryState {}

class DiscoveryPopulatedState<T> extends DiscoveryState {
  DiscoveryPopulatedState({
    this.genre,
    this.index = 0,
    this.results,
  });
  final String? genre;
  final int index;
  final T? results;
}
