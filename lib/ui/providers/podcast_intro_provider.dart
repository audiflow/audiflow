import 'package:audiflow/core/exception/app_exception.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/repository/repository_provider.dart';
import 'package:audiflow/services/podcast/podcast_service_provider.dart';
import 'package:audiflow/stopwatch.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:podcast_feed/parsers/channel_item_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_intro_provider.freezed.dart';
part 'podcast_intro_provider.g.dart';

@riverpod
class PodcastIntro extends _$PodcastIntro {
  Repository get _repository => ref.read(repositoryProvider);

  PodcastService get _podcastService => ref.read(podcastServiceProvider);

  @override
  Future<PodcastIntroState> build({
    required int collectionId,
  }) async {
    // _log.fine('build: collectionId=$collectionId');
    elapsedTime('build: collectionId=$collectionId');
    final feedUrl = await _podcastService.findOrFetchFeedUrlBy(
      collectionId: collectionId,
    );
    elapsedTime('after findOrFetchFeedUrlBy($collectionId)');
    if (feedUrl == null) {
      throw NotFoundException();
    }

    final (podcast, itemsParser) = await _podcastService.fetchPodcastBy(
      feedUrl: feedUrl,
      collectionId: collectionId,
    );
    elapsedTime('after fetchPodcastBy($feedUrl, $collectionId)');
    if (podcast == null || itemsParser == null) {
      throw NotFoundException();
    }

    final podcastStats = await _repository.findPodcastStats(podcast.id);
    elapsedTime('after findPodcastStats(${podcast.id})');
    final episodes = await compute(parseEpisodes, {
      'parser': itemsParser,
      'pid': podcast.id,
      'take': 11,
    });

    // _listen();
    return PodcastIntroState(
      podcast: podcast,
      stats: podcastStats,
      episodes: episodes,
    );
  }

// void _listen() {
//   ref.listen(podcastEventStreamProvider, (_, next) {
//     next.whenData((event) {
//       switch (event) {
//         case PodcastSubscribedEvent(
//                 podcast: final podcast,
//                 stats: final stats
//               ) ||
//               PodcastUnsubscribedEvent(
//                 podcast: final podcast,
//                 stats: final stats
//               ):
//           if (podcast.id == state.valueOrNull?.podcast.id) {
//             state = AsyncData(
//               PodcastIntroState(
//                 podcast: podcast,
//                 stats: stats,
//                 episodes: state.requireValue.episodes,
//               ),
//             );
//           }
//         case PodcastUpdatedEvent(podcast: final podcast):
//           if (podcast.guid == state.valueOrNull?.podcast.guid) {
//             state = AsyncData(state.requireValue.copyWith(podcast: podcast));
//           }
//         case PodcastStatsUpdatedEvent(stats: final stats):
//           if (stats.id == state.valueOrNull?.podcast.id) {
//             state = AsyncData(state.requireValue.copyWith(stats: stats));
//           }
//         case PodcastViewStatsUpdatedEvent():
//       }
//     });
//   });
// }
}

Future<List<Episode>> parseEpisodes(Map<String, dynamic> message) {
  final itemParser = message['parser'] as ItemParser;
  final pid = message['pid'] as int;
  final take = message['take'] as int;

  return itemParser
      .parseWith((values) => Episode.fromChannelItem(pid, values))
      .take(take)
      .toList();
}

@freezed
class PodcastIntroState with _$PodcastIntroState {
  const factory PodcastIntroState({
    required Podcast podcast,
    PodcastStats? stats,
    required List<Episode> episodes,
  }) = _PodcastIntroState;
}
