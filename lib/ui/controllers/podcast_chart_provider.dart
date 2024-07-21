import 'package:audiflow/core/exception/app_exception.dart';
import 'package:audiflow/core/logger.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/events/podcast_chart_event.dart';
import 'package:audiflow/services/error/error_manager.dart';
import 'package:audiflow/services/podcast/podcast_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_chart_provider.g.dart';

@Riverpod(keepAlive: true)
class PodcastChart extends _$PodcastChart {
  static const _ttl = Duration(hours: 3);
  static const _errorKey = 'podcastChart';

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
    logger.d('_searchNewChart $event');
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
    } on NetworkException catch (e) {
      logger.w('Network error: $e');
      if (e is NoConnectivityException) {
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
