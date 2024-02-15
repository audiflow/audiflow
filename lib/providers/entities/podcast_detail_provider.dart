import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:podcast_search/podcast_search.dart' as search;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/entities.dart';

part 'podcast_channel_provider.freezed.dart';
part 'podcast_channel_provider.g.dart';

@riverpod
class PodcastDetail extends _$PodcastDetail {
  @override
  Future<AsyncValue<PodcastDetailState>> build({
    Podcast? podcast,
    search.Podcast? searchResult,
    String? url,
  }) async {
    if (podcast != null || searchResult != null) {
      return AsyncData(
        PodcastDetailState(
          podcast: podcast,
          searchResult: searchResult,
        ),
      );
    }
    return const AsyncLoading();
  }
}

@freezed
class PodcastDetailState with _$PodcastDetailState {
  const factory PodcastDetailState({
    Podcast? podcast,
    search.Podcast? searchResult,
  }) = _PodcastDetailState;
}
