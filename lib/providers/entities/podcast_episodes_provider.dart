import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/providers/entities/podcast_channel_provider.dart';

part 'podcast_episodes_provider.g.dart';

@riverpod
List<Episode> podcastEpisodes(PodcastEpisodesRef ref) =>
    ref.watch(podcastChannelProvider)?.episodes ?? [];
