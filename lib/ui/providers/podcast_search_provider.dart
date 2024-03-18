// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/errors/errors.dart';
import 'package:audiflow/events/podcast_search_event.dart';
import 'package:audiflow/repository/repository_provider.dart';
import 'package:audiflow/services/error/error_manager.dart';
import 'package:audiflow/services/podcast/podcast_service_provider.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_search_provider.freezed.dart';
part 'podcast_search_provider.g.dart';

@Riverpod(keepAlive: true)
class PodcastSearch extends _$PodcastSearch {
  static const _errorKey = 'podcastSearch';
  final _log = Logger('PodcastSearch');

  ErrorManager get _errorManager => ref.read(errorManagerProvider.notifier);

  Repository get _repository => ref.read(repositoryProvider);

  @override
  Future<PodcastSearchState> build() async {
    return const PodcastSearchState();
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
    _log.fine('_search $event');
    _errorManager.unregisterRetry(_errorKey);
    state = const AsyncValue.loading();

    try {
      final metadataList = await ref.read(podcastServiceProvider).search(
            term: event.term,
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
        podcasts: metadataList,
      );
      await _repository.savePodcastMetadataList(metadataList);
      state = AsyncData(newState);
    } on NetworkError catch (e) {
      _log.warning('Network error: ${e.type}');
      if (e is NoConnectivityError) {
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
    String? country,
    String? attribute,
    @Default(20) int limit,
    String? language,
    @Default(0) int version,
    @Default(false) bool explicit,
    @Default([]) List<PodcastMetadata> podcasts,
  }) = _PodcastSearchState;

  factory PodcastSearchState.fromJson(Map<String, dynamic> json) =>
      _$PodcastSearchStateFromJson(json);
}

extension PodcastSearchStateExt on PodcastSearchState {
  bool get notFound => term?.isNotEmpty == true && podcasts.isEmpty;
}
