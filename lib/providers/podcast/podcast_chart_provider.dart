// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seasoning/entities/podcast_chart.dart';
import 'package:seasoning/errors/errors.dart';
import 'package:seasoning/events/podcast_chart_event.dart';
import 'package:seasoning/repository/repository_provider.dart';
import 'package:seasoning/services/error/error_manager.dart';
import 'package:seasoning/services/podcast/podcast_service_provider.dart';

part 'podcast_chart_provider.g.dart';

@Riverpod(keepAlive: true)
class PodcastChart extends _$PodcastChart {
  PodcastChart() {
    _input.throttleTime(const Duration(seconds: 5)).listen(_inputHandler);
  }

  static const _ttl = Duration(hours: 3);
  static const _errorKey = 'podcastChart';
  final _log = Logger('PodcastChart');

  final BehaviorSubject<PodcastChartEvent> _input =
      BehaviorSubject<PodcastChartEvent>();

  ErrorManager get _errorManager => ref.read(errorManagerProvider.notifier);

  Repository get _repository => ref.read(repositoryProvider);

  void dispose() {
    _input.close();
  }

  void input(PodcastChartEvent event) => _input.add(event);

  @override
  Future<PodcastChartState> build() async {
    final lastState = await _repository.loadPodcastChart();
    return lastState ?? const PodcastChartState();
  }

  Future<void> _inputHandler(PodcastChartEvent event) async {
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
              _inputHandler(event);
            }
          });
        },
        error: (_, __) => _searchNewChart(event),
      );
    }
  }

  Future<void> _searchNewChart(NewPodcastChartEvent event) async {
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
