import 'dart:async';

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/providers/podcast/podcast_info_provider.dart';
import 'package:audiflow/services/podcast/podcast_season_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_seasons_provider.g.dart';

@riverpod
Future<List<Season>> podcastSeasons(
  PodcastSeasonsRef ref,
  PodcastMetadata metadata,
) async {
  final podcast = await ref.watch(
    podcastInfoProvider(metadata).selectAsync((state) => state.podcast),
  );
  return PodcastSeasonService().extractSeasons(podcast);
}
