// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/features/podcast_chart/podcast_chart_event.dart';
import 'package:seasoning/services/podcast/mobile_podcast_service.dart';

part 'podcast_chart_provider.freezed.dart';
part 'podcast_chart_provider.g.dart';

@riverpod
class PodcastChart extends _$PodcastChart {
  PodcastChart() {
    _input.listen(_inputHandler);
  }

  final BehaviorSubject<PodcastChartEvent> _input =
      BehaviorSubject<PodcastChartEvent>();

  // ignore: avoid_public_notifier_properties
  void Function(PodcastChartEvent) get input => _input.add;

  @override
  AsyncValue<PodcastChartState> build() {
    ref.onDispose(_input.close);
    return const AsyncData(PodcastChartState());
  }

  Future<void> _inputHandler(PodcastChartEvent event) async {
    if (event is NewPodcastChartEvent) {
      return _searchNewChart(event);
    }
  }

  Future<void> _searchNewChart(NewPodcastChartEvent event) async {
    state = const AsyncLoading();

    final result = await ref.read(podcastServiceProvider).charts(
          size: event.size,
          genre: event.genre,
          countryCode: event.countryCode,
        );

    if (result.successful) {
      final podcasts =
          result.items.map(PodcastSearchResultItem.fromSearchResultItem);
      state = AsyncData(
        PodcastChartState(
          size: event.size,
          genre: event.genre,
          countryCode: event.countryCode,
          podcasts: podcasts.toList(),
        ),
      );
    } else {
      state = AsyncError(Exception(result.lastError), StackTrace.current);
    }
    return;
  }
}

@freezed
class PodcastChartState with _$PodcastChartState {
  const factory PodcastChartState({
    int? size,
    String? genre,
    String? countryCode,
    @Default([]) List<PodcastSearchResultItem> podcasts,
  }) = _PodcastChartState;
}
