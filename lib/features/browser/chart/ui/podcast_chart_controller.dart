import 'dart:async';

import 'package:audiflow/common/data/connectivity.dart';
import 'package:audiflow/constants/country.dart';
import 'package:audiflow/core/exception/app_exception.dart';
import 'package:audiflow/features/browser/common/data/podcast_api_repository.dart';
import 'package:audiflow/features/browser/common/data/podcast_genres.dart';
import 'package:audiflow/features/browser/common/model/itunes_chart_item.dart';
import 'package:audiflow/services/error/error_manager.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_chart_controller.freezed.dart';
part 'podcast_chart_controller.g.dart';

@Riverpod(keepAlive: true)
class PodcastChartController extends _$PodcastChartController
    with ConnectivityMixin<PodcastChartState> {
  static const _ttl = Duration(hours: 3);

  ErrorManager get _errorManager => ref.read(errorManagerProvider.notifier);

  @override
  Future<PodcastChartState> build({
    String? genre,
    Country? country,
    int size = 20,
  }) async {
    return _fetchNewChart(
      genre: genre,
      country: country,
      size: size,
    );
  }

  Future<PodcastChartState> _fetchNewChart({
    required String? genre,
    required Country? country,
    required int size,
  }) async {
    await waitForConnectivity();

    try {
      final chartItems = await ref.read(podcastApiRepositoryProvider).charts(
            size: size,
            genre: ref.read(podcastGenresProvider.notifier).decodeGenre(genre),
            country: country ?? Country.none,
          );

      return PodcastChartState(
        size: size,
        genre: genre,
        country: country,
        chartItems: chartItems.toList(),
        expiresAt: DateTime.now().add(_ttl),
      );
    } on NetworkException catch (e) {
      logger.w('Network error: $e');
      _errorManager.noticeError(e);
      rethrow;
    }
  }
}

@freezed
class PodcastChartState with _$PodcastChartState {
  const factory PodcastChartState({
    String? genre,
    Country? country,
    int? size,
    @Default([]) List<ITunesChartItem> chartItems,
    DateTime? expiresAt,
  }) = _PodcastChartState;
}

extension PodcastChartStateExt on PodcastChartState {
  bool get isExpired => expiresAt?.isBefore(DateTime.now()) ?? true;
}
