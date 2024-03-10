import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/providers/podcast/podcast_info_provider.dart';
import 'package:seasoning/services/podcast/podcast_season_service.dart';

part 'podcast_seasons_provider.g.dart';

@riverpod
Future<List<Season>> podcastSeasons(
  PodcastSeasonsRef ref,
  PodcastMetadata metadata,
) async {
  final podcast = await ref.watch(
    podcastInfoProvider(metadata).selectAsync((state) => state.podcast),
  );
  return PodcastSeasonService().extractSeasons(podcast) ?? [];
}
