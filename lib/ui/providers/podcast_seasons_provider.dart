import 'dart:async';

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/services/podcast/podcast_season_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_seasons_provider.g.dart';

@riverpod
Future<List<Season>> podcastSeasons(
  PodcastSeasonsRef ref,
  Podcast podcast,
) async {
  return PodcastSeasonService().extractSeasons(podcast);
}
