import 'dart:async';

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/services/podcast/season/podcast_season_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_seasons.g.dart';

@riverpod
Future<List<Season>> podcastSeasons(
  PodcastSeasonsRef ref,
  Podcast podcast,
) async {
  return ref.read(podcastSeasonServiceProvider).extractSeasons(podcast, []);
}
