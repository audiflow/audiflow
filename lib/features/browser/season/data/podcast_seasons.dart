import 'dart:async';

import 'package:audiflow/events/season_event.dart';
import 'package:audiflow/features/browser/season/data/season_repository.dart';
import 'package:audiflow/features/browser/season/model/season.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_seasons.g.dart';

@riverpod
Future<List<Season>> podcastSeasons(
  PodcastSeasonsRef ref,
  Podcast podcast,
) async {
  ref.listen(seasonEventStreamProvider, (_, event) {
    final relatesToPodcast = event.maybeMap(
      data: (event) {
        switch (event.value) {
          case SeasonUpdatedEvent(season: final season):
            return season.pid == podcast.id;
          case SeasonsUpdatedEvent(seasons: final seasons):
            return seasons.any((season) => season.pid == podcast.id);
        }
      },
      orElse: () => false,
    );
    if (relatesToPodcast) {
      ref
          .read(seasonRepositoryProvider)
          .findPodcastSeasons(podcast.id)
          .then((seasons) {
        return ref.state = AsyncValue.data(seasons);
      });
    }
  });

  return ref.read(seasonRepositoryProvider).findPodcastSeasons(podcast.id);
}
