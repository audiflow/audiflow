// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/podcast_chart.dart';
import 'package:seasoning/errors/errors.dart';
import 'package:seasoning/events/podcast_chart_event.dart';
import 'package:seasoning/repository/repository_provider.dart';
import 'package:seasoning/services/error/error_manager.dart';
import 'package:seasoning/services/podcast/podcast_service_provider.dart';

part 'podcast_chart_provider.g.dart';

@Riverpod(keepAlive: true)
class PodcastChart extends _$PodcastChart {
  static const _ttl = Duration(hours: 3);
  static const _errorKey = 'podcastChart';
  final _log = Logger('PodcastChart');

  ErrorManager get _errorManager => ref.read(errorManagerProvider.notifier);

  Repository get _repository => ref.read(repositoryProvider);

  @override
  Future<PodcastChartState> build() async {
    final lastState = await _repository.loadPodcastChart();
    return lastState?.isExpired == false
        ? lastState!
        : const PodcastChartState();
  }

  Future<void> input(PodcastChartEvent event) async {
    if (event is NewPodcastChartEvent) {
      await state.when(
        data: (data) {
          if (data.isExpired ||
              data.genre != event.genre ||
              data.countryCode != event.countryCode) {
            return _searchNewChart(event);
          }
        },
        loading: () {
          var handled = false;
          ref.listenSelf((_, next) {
            if (!handled && next.hasValue || next.hasError) {
              handled = true;
              input(event);
            }
          });
        },
        error: (_, __) => _searchNewChart(event),
      );
    }
  }

  Future<void> _searchNewChart(NewPodcastChartEvent event) async {
    _log.fine('_searchNewChart $event');
    _errorManager.unregisterRetry(_errorKey);

    try {
      final podcasts = await ref.read(podcastServiceProvider).charts(
            size: event.size,
            genre: event.genre,
            countryCode: event.countryCode,
          );

      final newState = PodcastChartState(
        size: event.size,
        genre: event.genre,
        countryCode: event.countryCode,
        podcasts: podcasts.toList(),
        expiresAt: DateTime.now().add(_ttl),
      );
      await _repository.savePodcastChart(newState);
      state = AsyncData(newState);
    } on NetworkError catch (e) {
      _log.warning('Network error: ${e.type}');
      if (e is NoConnectivityError) {
        _errorManager.retryOnReconnect(
          key: _errorKey,
          retry: () => _searchNewChart(event),
        );
      } else {
        if (!state.hasValue) {
          state = AsyncError(e, StackTrace.current);
        }
        _errorManager.noticeError(e);
      }
    }
  }
}
