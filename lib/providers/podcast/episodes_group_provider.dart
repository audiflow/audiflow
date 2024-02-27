import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/core/types.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/repository/repository_provider.dart';
import 'package:seasoning/services/podcast/podcast_service_provider.dart';

part 'episodes_group_provider.freezed.dart';
part 'episodes_group_provider.g.dart';

class EpisodesGroupScope extends HookConsumerWidget {
  const EpisodesGroupScope({
    required this.episodes,
    required this.child,
    super.key,
  });

  final Iterable<Episode> episodes;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
        overrides: [
          episodesGroupProvider.overrideWith(EpisodesGroup.new),
        ],
        child: HookConsumer(
          builder: (context, ref, child) {
            final state = ref.watch(episodesGroupProvider);
            useEffect(
              () {
                ref.read(episodesGroupProvider.notifier).setup(episodes);
                return null;
              },
              [],
            );
            return child ?? const SizedBox();
          },
          child: child,
        ));
  }
}

// ignore: provider_dependencies
@Riverpod(dependencies: [podcastService, repository])
class EpisodesGroup extends _$EpisodesGroup {
  final _completer = Completer<EpisodesGroupState>();

  PodcastService get _podcastService => ref.read(podcastServiceProvider);

  @override
  Future<EpisodesGroupState> build() async {
    return _completer.future;
  }

  Future<void> setup(Iterable<Episode> episodes) async {
    print('EpisodesGroup.setup');
    final stats = await ref
        .read(repositoryProvider)
        .findEpisodeStatsList(episodes.map((e) => e.guid));
    final initialState = EpisodesGroupState(
      episodes: episodes.toList(),
      statsMap: Map<String, EpisodeStats>.fromEntries(
        stats
            .where((s) => s != null)
            .cast<EpisodeStats>()
            .map((s) => MapEntry(s.guid, s)),
      ),
    );
    _completer.complete(initialState);
  }

  Future<void> togglePlayState({required Episode episode}) =>
      _podcastService.togglePlayState(
        episode,
        group: state.requireValue.episodes,
      );
}

@freezed
class EpisodesGroupState with _$EpisodesGroupState {
  const factory EpisodesGroupState({
    required List<Episode> episodes,
    required Map<String, EpisodeStats> statsMap,
  }) = _EpisodesGroupState;
}

enum ConditionalPlayButtonState {
  fromStart,
  latest,
  latestAgain,
  resume;
}

extension EpisodesInfoStateExt on EpisodesGroupState {
  Episode? _earliestEpisode() {
    return episodes.fold(null, (Episode? acc, e) {
      if (acc?.publicationDate == null) {
        return e;
      } else if (e.publicationDate == null) {
        return acc;
      }
      return acc!.publicationDate!.isBefore(e.publicationDate!) ? acc : e;
    });
  }

  Episode? _latestEpisode() {
    return episodes.fold(null, (Episode? acc, e) {
      if (acc?.publicationDate == null) {
        return e;
      } else if (e.publicationDate == null) {
        return acc;
      }
      return acc!.publicationDate!.isBefore(e.publicationDate!) ? e : acc;
    });
  }

  EpisodeStats? _lastPlayedStats() {
    return statsMap.values.fold(null, (EpisodeStats? acc, e) {
      if (acc?.lastPlayedAt == null) {
        return e;
      } else if (e.lastPlayedAt == null) {
        return acc;
      }
      return acc!.lastPlayedAt!.isBefore(e.lastPlayedAt!) ? e : acc;
    });
  }

  (Episode?, ConditionalPlayButtonState) nextEpisodeToPlay({
    required PlayOrder playOrder,
    bool isSeries = false,
  }) {
    if (episodes.isEmpty) {
      return (null, ConditionalPlayButtonState.fromStart);
    }

    final lastPlayedStats = _lastPlayedStats();
    final lastPlayedEpisode = lastPlayedStats == null
        ? null
        : episodes.firstWhereOrNull((e) => e.guid == lastPlayedStats.guid);
    if (lastPlayedStats == null ||
        lastPlayedEpisode == null ||
        lastPlayedEpisode.publicationDate == null) {
      return playOrder == PlayOrder.timeDescend || !isSeries
          ? (_latestEpisode(), ConditionalPlayButtonState.latest)
          : (_earliestEpisode(), ConditionalPlayButtonState.fromStart);
    }

    if (lastPlayedStats.percentagePlayed < 0.999 &&
        // means the user would have interest in the episode
        (isSeries || const Duration(minutes: 1) <= lastPlayedStats.position)) {
      return (lastPlayedEpisode, ConditionalPlayButtonState.resume);
    }

    final countToPlay = playOrder == PlayOrder.timeAscend
        ? episodes
            .where(
              (e) =>
                  e.publicationDate != null &&
                  e.publicationDate!
                      .isAfter(lastPlayedEpisode.publicationDate!),
            )
            .length
        : episodes
            .where(
              (e) =>
                  e.publicationDate != null &&
                  e.publicationDate!
                      .isBefore(lastPlayedEpisode.publicationDate!),
            )
            .length;

    switch (countToPlay) {
      case 0:
        return isSeries
            ? (_earliestEpisode(), ConditionalPlayButtonState.fromStart)
            : (_latestEpisode(), ConditionalPlayButtonState.latestAgain);
      case 1:
        return (_latestEpisode(), ConditionalPlayButtonState.latest);
      default:
        if (isSeries || playOrder == PlayOrder.timeAscend && countToPlay < 4) {
          final nextEpisode = episodes.lastWhere(
            (e) =>
                e.publicationDate != null &&
                e.publicationDate!.isAfter(lastPlayedEpisode.publicationDate!),
          );
          return (nextEpisode, ConditionalPlayButtonState.resume);
        } else {
          return (_latestEpisode(), ConditionalPlayButtonState.latest);
        }
    }
  }
}
