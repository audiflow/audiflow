import 'package:audiflow/constants/country.dart';
import 'package:audiflow/core/exception/app_exception.dart';
import 'package:audiflow/features/browser/common/data/podcast_api_repository.dart';
import 'package:audiflow/features/browser/common/data/podcast_genres.dart';
import 'package:audiflow/features/browser/common/model/itunes_chart_item.dart';
import 'package:audiflow/services/connectivity/connectivity.dart';
import 'package:audiflow/services/error/error_manager.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_chart_controller.freezed.dart';
part 'podcast_chart_controller.g.dart';

@Riverpod(keepAlive: true)
class PodcastChartController extends _$PodcastChartController {
  static const _ttl = Duration(hours: 3);
  static const _errorKey = 'podcastChart';

  ErrorManager get _errorManager => ref.read(errorManagerProvider.notifier);

  @override
  Future<PodcastChartState> build() async {
    return const PodcastChartState();
  }

  Future<void> fetch({
    String? genre,
    Country? country,
    int size = 20,
    bool refresh = false,
  }) async {
    await state.when(
      data: (data) {
        if (data.isExpired || data.genre != genre || data.country != country) {
          return _fetchNewChart(
            genre: genre,
            country: country,
            size: size,
            refresh: refresh,
          );
        }
      },
      loading: () {
        var handled = false;
        ref.listenSelf((_, next) {
          if (!handled && next.hasValue || next.hasError) {
            handled = true;
            fetch(
              genre: genre,
              country: country,
              size: size,
              refresh: refresh,
            );
          }
        });
      },
      error: (_, __) => _fetchNewChart(
        genre: genre,
        country: country,
        size: size,
        refresh: refresh,
      ),
    );
  }

  Future<void> _fetchNewChart({
    required String? genre,
    required Country? country,
    required int size,
    required bool refresh,
  }) async {
    _errorManager.unregisterRetry(_errorKey);

    try {
      if (!await hasConnectivity()) {
        logger.d('no network');
        throw NoConnectivityException();
      }

      final chartItems = await ref.read(podcastApiRepositoryProvider).charts(
            size: size,
            genre: ref.read(podcastGenresProvider.notifier).decodeGenre(genre),
            country: country ?? Country.none,
          );

      final newState = PodcastChartState(
        size: size,
        genre: genre,
        country: country,
        chartItems: chartItems.toList(),
        expiresAt: DateTime.now().add(_ttl),
      );
      state = AsyncData(newState);
    } on NetworkException catch (e) {
      logger.w('Network error: $e');
      if (e is NoConnectivityException) {
        _errorManager.retryOnReconnect(
          key: _errorKey,
          retry: () => _fetchNewChart(
            genre: genre,
            country: country,
            size: size,
            refresh: refresh,
          ),
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

@freezed
class PodcastChartState with _$PodcastChartState {
  const factory PodcastChartState({
    int? size,
    String? genre,
    Country? country,
    @Default([]) List<ITunesChartItem> chartItems,
    DateTime? expiresAt,
  }) = _PodcastChartState;
}

extension PodcastChartStateExt on PodcastChartState {
  bool get isExpired => expiresAt?.isBefore(DateTime.now()) ?? true;
}
