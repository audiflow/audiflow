// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/repository/episode_event.dart';
import 'package:audiflow/repository/repository_provider.dart';
import 'package:audiflow/services/podcast/podcast_service_provider.dart';
import 'package:audiflow/ui/providers/podcast_subscriptions_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'latest_episodes_provider.freezed.dart';
part 'latest_episodes_provider.g.dart';

@Riverpod(keepAlive: true)
class LatestEpisodes extends _$LatestEpisodes {
  final _log = Logger('LatestEpisodes');
  final _subscriptions = <String, ProviderSubscription<dynamic>>{};

  Repository get _repository => ref.read(repositoryProvider);

  PodcastService get _podcastService => ref.read(podcastServiceProvider);

  DateTime get _scope => DateTime.now().subtract(const Duration(days: 7));

  @override
  LatestEpisodesState build() {
    _log.fine('build');
    unawaited(_listen());
    return const LatestEpisodesState();
  }

  Future<void> _listen() async {
    ref
      ..listen(
        podcastSubscriptionsProvider,
        (_, next) {
          next.whenData((subscriptions) {
            subscriptions
                .map((s) => s.$1)
                .where((metadata) => !_subscriptions.containsKey(metadata.guid))
                .forEach(_populateWith);
          });
        },
        fireImmediately: true,
      )
      ..listen(episodeEventStreamProvider, (_, next) {
        final event = next.requireValue;
        if (event is EpisodeUpdatedEvent) {
          final episode = event.episode;
          if (state.episodes.any((e) => e.guid == episode.guid)) {
            state = state.copyWith(
              episodes: state.episodes
                  .map((e) => e.guid == episode.guid ? episode : e)
                  .toList(),
            );
          } else if (state.podcasts.contains(episode.pguid) &&
              episode.publicationDate != null &&
              episode.publicationDate!.isAfter(_scope)) {
            state = state.copyWith(episodes: [episode, ...state.episodes]);
          }
        } else if (event is EpisodeStatsUpdatedEvent) {
          final stats = event.stats;
          if (state.episodes.any((e) => e.guid == stats.guid)) {
            state = state.copyWith(
              played: stats.played
                  ? {...state.played, stats.guid}
                  : {...state.played}
                ..remove(stats.guid),
            );
          }
        }
      });
  }

  Future<void> _populateWith(PodcastMetadata metadata) async {
    final podcast = await _podcastService.loadPodcast(metadata);
    final episodes = podcast?.episodes.where(
          (e) =>
              e.publicationDate != null && e.publicationDate!.isAfter(_scope),
        ) ??
        [];
    final stats =
        await _repository.findEpisodeStatsList(episodes.map((e) => e.guid));
    final played =
        stats.whereNotNull().where((s) => s.played).map((s) => s.guid);
    state = state.copyWith(
      podcasts: {...state.podcasts, metadata.guid},
      episodes: episodes.isEmpty
          ? state.episodes
          : [...state.episodes, ...episodes].sorted(
              (a, b) => b.publicationDate!.compareTo(a.publicationDate!),
            ),
      played: {...state.played, ...played},
    );
  }
}

@freezed
class LatestEpisodesState with _$LatestEpisodesState {
  const factory LatestEpisodesState({
    @Default(<String>{}) Set<String> podcasts,
    @Default(<Episode>[]) List<Episode> episodes,
    @Default(<String>{}) Set<String> played,
  }) = _LatestEpisodesState;
}

extension LatestEpisodesStateExt on LatestEpisodesState {
  List<Episode> get unplayedEpisodes {
    return episodes.where((e) => !played.contains(e.guid)).toList();
  }
}
