import 'package:audiflow/constants/country.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/features/browser/common/model/itunes_chart_item.dart';
import 'package:audiflow/features/browser/common/model/itunes_search_item.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:podcast_search/podcast_search.dart' as podcast_search;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_api_repository.g.dart';

abstract class PodcastApiRepository {
  /// Allow adding of custom certificates. Required as default context
  /// does not apply when running in separate Isolate.
  void setClientAuthorityBytes(List<int> certificateAuthorityBytes);

  Future<ITunesSearchItem?> lookup({
    required int collectionId,
  });

  /// Search for podcasts matching the search criteria.
  Future<List<ITunesSearchItem>> search(
    String term, {
    int limit = 20,
    Country? country,
    Attribute? attribute,
    String? language,
    int? version,
    bool explicit = false,
  });

  /// Request the top podcast charts from iTunes, and at most [size] records.
  Future<List<ITunesChartItem>> charts({
    int size = 20,
    String genre = '',
    Country country = Country.none,
  });

  List<String> genres(String searchProvider);

  /// Load episode chapters via JSON file.
  Future<podcast_search.Chapters> loadChapters(String url);

  /// Load episode transcript via SRT or JSON file.
  Future<podcast_search.Transcript> loadTranscript(
    TranscriptUrl transcriptUrl,
  );
}

@Riverpod(keepAlive: true)
PodcastApiRepository podcastApiRepository(PodcastApiRepositoryRef ref) {
  // * Override this in the main method
  throw UnimplementedError();
}
