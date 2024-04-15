// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/errors/errors.dart';
import 'package:audiflow/events/podcast_chart_event.dart';
import 'package:audiflow/services/error/error_manager.dart';
import 'package:audiflow/services/podcast/podcast_service_provider.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_chart_provider.g.dart';

@Riverpod(keepAlive: true)
class PodcastChart extends _$PodcastChart {
  static const _ttl = Duration(hours: 3);
  static const _errorKey = 'podcastChart';
  final _log = Logger('PodcastChart');

  ErrorManager get _errorManager => ref.read(errorManagerProvider.notifier);

  @override
  Future<PodcastChartState> build() async {
    return const PodcastChartState();
  }

  Future<void> input(PodcastChartEvent event) async {
    if (event is NewPodcastChartEvent) {
      await state.when(
        data: (data) {
          if (data.isExpired ||
              data.genre != event.genre ||
              data.country != event.country) {
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
      final chartItems = await ref.read(podcastServiceProvider).charts(
            size: event.size,
            genre: event.genre,
            country: event.country ?? Country.none,
          );

      final newState = PodcastChartState(
        size: event.size,
        genre: event.genre,
        country: event.country,
        chartItems: chartItems.toList(),
        expiresAt: DateTime.now().add(_ttl),
      );
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
