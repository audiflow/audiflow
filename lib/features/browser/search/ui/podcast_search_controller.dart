import 'dart:async';

import 'package:audiflow/common/data/connectivity.dart';
import 'package:audiflow/common/service/error_manager.dart';
import 'package:audiflow/constants/attribute.dart';
import 'package:audiflow/constants/country.dart';
import 'package:audiflow/events/podcast_search_event.dart';
import 'package:audiflow/exceptions/app_exception.dart';
import 'package:audiflow/features/browser/common/data/podcast_api_repository.dart';
import 'package:audiflow/features/browser/common/model/itunes_search_item.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_search_controller.freezed.dart';
part 'podcast_search_controller.g.dart';

@Riverpod(keepAlive: true)
class PodcastSearchController extends _$PodcastSearchController
    with ConnectivityMixin<PodcastSearchState> {
  static const _errorKey = 'podcastSearch';

  ErrorManager get _errorManager => ref.read(errorManagerProvider.notifier);

  @override
  Future<PodcastSearchState> build() {
    return Future.value(const PodcastSearchState());
  }

  Future<void> input(PodcastSearchEvent event) async {
    if (event is ClearPodcastSearchEvent) {
      state = const AsyncData(PodcastSearchState());
      return;
    }

    if (event is NewPodcastSearchEvent) {
      await state.when(
        data: (data) {
          if (event.term != data.term ||
              event.country != data.country ||
              event.attribute != data.attribute ||
              event.limit != data.limit ||
              event.language != data.language ||
              event.version != data.version ||
              event.explicit != data.explicit) {
            return _search(event);
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
        error: (_, __) => _search(event),
      );
    }
  }

  Future<void> _search(NewPodcastSearchEvent event) async {
    logger.d('_search $event');
    _errorManager.unregisterRetry(_errorKey);
    state = const AsyncValue.loading();

    try {
      final items = await ref.read(podcastApiRepositoryProvider).search(
            event.term,
            country: event.country,
            attribute: event.attribute,
            limit: event.limit,
            language: event.language,
            version: event.version,
            explicit: event.explicit,
          );

      final newState = PodcastSearchState(
        term: event.term,
        country: event.country,
        attribute: event.attribute,
        limit: event.limit,
        language: event.language,
        version: event.version,
        explicit: event.explicit,
        items: items,
      );
      state = AsyncData(newState);
    } on NetworkException catch (e) {
      logger.w('Network error: ${e.message}');
      if (e is NoConnectivityException) {
        _errorManager.retryOnReconnect(
          key: _errorKey,
          retry: () => _search(event),
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
class PodcastSearchState with _$PodcastSearchState {
  const factory PodcastSearchState({
    String? term,
    Country? country,
    Attribute? attribute,
    @Default(20) int limit,
    String? language,
    @Default(0) int version,
    @Default(false) bool explicit,
    @Default([]) List<ITunesSearchItem> items,
  }) = _PodcastSearchState;
}

extension PodcastSearchStateExt on PodcastSearchState {
  bool get notFound => term?.isNotEmpty == true && items.isEmpty;
}
