// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/errors/errors.dart';
import 'package:audiflow/repository/podcast_event.dart';
import 'package:audiflow/repository/repository_provider.dart';
import 'package:audiflow/services/podcast/podcast_service_provider.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_info_provider.freezed.dart';
part 'podcast_info_provider.g.dart';

@riverpod
class PodcastInfo extends _$PodcastInfo {
  final _log = Logger('PodcastInfo');

  Repository get _repository => ref.read(repositoryProvider);

  PodcastService get _podcastService => ref.read(podcastServiceProvider);

  @override
  Future<PodcastInfoState> build(
    String guid, {
    required bool needsEpisodes,
  }) async {
    _log.fine('build $guid');

    final list = await Future.wait([
      _repository.findPodcast(guid),
      _repository.findPodcastStats(guid),
    ]);
    var podcast = list[0] as Podcast?;
    final podcastStats = list[1] as PodcastStats?;
    if (needsEpisodes && podcast?.episodes.isEmpty == true) {
      podcast =
          await _podcastService.loadPodcast(podcast!.metadata, refresh: true);
    }
    if (podcast == null) {
      throw NotFoundError();
    }

    _listen();
    return PodcastInfoState(
      podcast: podcast,
      stats: podcastStats,
    );
  }

  void _listen() {
    ref.listen(podcastEventStreamProvider, (_, next) {
      next.whenData((event) {
        switch (event) {
          case PodcastSubscribedEvent(
                  podcast: final podcast,
                  stats: final stats
                ) ||
                PodcastUnsubscribedEvent(
                  podcast: final podcast,
                  stats: final stats
                ):
            if (podcast.guid == state.valueOrNull?.podcast.guid) {
              state = AsyncData(
                PodcastInfoState(
                  podcast: podcast,
                  stats: stats,
                ),
              );
            }
          case PodcastUpdatedEvent(podcast: final podcast):
            if (podcast.guid == state.valueOrNull?.podcast.guid) {
              state = AsyncData(state.requireValue.copyWith(podcast: podcast));
            }
          case PodcastStatsUpdatedEvent(stats: final stats):
            if (stats.guid == state.valueOrNull?.podcast.guid) {
              state = AsyncData(state.requireValue.copyWith(stats: stats));
            }
          case PodcastViewStatsUpdatedEvent():
        }
      });
    });
  }
}

@freezed
class PodcastInfoState with _$PodcastInfoState {
  const factory PodcastInfoState({
    required Podcast podcast,
    PodcastStats? stats,
  }) = _PodcastInfoState;
}
