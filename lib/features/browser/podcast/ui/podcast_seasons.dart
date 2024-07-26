import 'dart:async';

import 'package:audiflow/features/browser/podcast/model/season.dart';
import 'package:audiflow/features/browser/season/service/podcast_season_service.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_seasons.g.dart';

@riverpod
Future<List<Season>> podcastSeasons(
  PodcastSeasonsRef ref,
  Podcast podcast,
) async {
  return ref.read(podcastSeasonServiceProvider).extractSeasons(podcast, []);
}
