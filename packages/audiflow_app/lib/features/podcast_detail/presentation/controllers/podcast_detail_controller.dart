import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_detail_controller.g.dart';

/// Fetches and provides parsed podcast feed data for a given feed URL.
///
/// Returns [ParsedFeed] containing podcast metadata and episodes.
/// Throws [PodcastException] if the feed cannot be fetched or parsed.
@riverpod
Future<ParsedFeed> podcastDetail(Ref ref, String feedUrl) async {
  final feedParser = ref.watch(feedParserServiceProvider);
  return feedParser.parseFromUrl(feedUrl);
}
