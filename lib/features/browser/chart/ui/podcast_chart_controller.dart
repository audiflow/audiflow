import 'dart:async';

import 'package:audiflow/common/data/connectivity.dart';
import 'package:audiflow/common/service/error_manager.dart';
import 'package:audiflow/constants/country.dart';
import 'package:audiflow/exceptions/app_exception.dart';
import 'package:audiflow/features/browser/common/data/podcast_api_repository.dart';
import 'package:audiflow/features/browser/common/data/podcast_genres.dart';
import 'package:audiflow/features/browser/common/model/itunes_chart_item.dart';
import 'package:audiflow/features/preference/data/preference_repository.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:audiflow/utils/widget.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_chart_controller.freezed.dart';
part 'podcast_chart_controller.g.dart';

@Riverpod(keepAlive: true)
class PodcastChartController extends _$PodcastChartController
    with ConnectivityMixin<PodcastChartState> {
  static const _ttl = Duration(hours: 3);

  PreferenceRepository get _preferenceRepository =>
      ref.read(preferenceRepositoryProvider.notifier);

  ErrorManager get _errorManager => ref.read(errorManagerProvider.notifier);

  @override
  FutureOr<PodcastChartState> build() {
    _listen();
    return const PodcastChartState(size: 50);
  }

  void _listen() {
    ref.listen(
      preferenceRepositoryProvider
          .select((pref) => pref.chartCountries.join(',')),
      (_, newJoinedChartCountries) {
        logger.i('Chart countries changed: $newJoinedChartCountries');
        final joinedChartCountries =
            state.valueOrNull?.chartCountries.map((e) => e.code).join(',');
        if (newJoinedChartCountries == joinedChartCountries) {
          return;
        }

        final chartCountries = newJoinedChartCountries
            .split(',')
            .map(Country.fromCode)
            .where((c) => c != Country.none)
            .toList();
        if (chartCountries.isEmpty) {
          chartCountries.add(Country.japan);
        }
        onNextFrame(() {
          state = AsyncData(
            state.requireValue.copyWith(
              chartCountry: chartCountries.first,
              chartCountries: chartCountries,
              chartItems: [],
              expiresAt: null,
            ),
          );
          fetchNewChart();
        });
      },
      fireImmediately: true,
    );
  }

  void setCountry(String countryCode) {
    final country = Country.fromCode(countryCode);
    if (country == state.requireValue.chartCountry) {
      return;
    }

    _preferenceRepository.update(
      PreferenceUpdateParam(
        chartCountries: [
          country.code,
          ...state.requireValue.chartCountries
              .where((e) => e != country)
              .map((e) => e.code),
        ],
      ),
    );
  }

  void setGenre(String genre) {
    if (state.requireValue.genre == genre) {
      return;
    }

    state = AsyncData(
      state.requireValue.copyWith(
        genre: genre,
        chartItems: [],
        expiresAt: null,
      ),
    );
    fetchNewChart();
  }

  Future<void> fetchNewChart() async {
    final value = state.requireValue;
    try {
      final chartItems = await ref.read(podcastApiRepositoryProvider).charts(
            size: value.size,
            genre: ref
                .read(podcastGenresProvider.notifier)
                .decodeGenre(value.genre),
            country: value.chartCountry,
          );

      state = AsyncData(
        value.copyWith(
          chartItems: chartItems.toList(),
          expiresAt: DateTime.now().add(_ttl),
        ),
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
    @Default(Country.none) Country chartCountry,
    @Default(<Country>[]) List<Country> chartCountries,
    required int size,
    @Default([]) List<ITunesChartItem> chartItems,
    DateTime? expiresAt,
  }) = _PodcastChartState;
}

extension PodcastChartStateExt on PodcastChartState {
  bool get isExpired => expiresAt?.isBefore(DateTime.now()) ?? true;
}
