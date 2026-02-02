import 'package:audiflow_domain/patterns.dart';
import 'package:audiflow_podcast/parser.dart';
import 'package:http/http.dart' as http;

import '../adapters/episode_adapter.dart';
import '../diagnostics/episode_extractor_diagnostics.dart';
import '../diagnostics/smart_playlist_episode_extractor_diagnostics.dart';
import '../diagnostics/title_extractor_diagnostics.dart';
import '../models/extraction_result.dart';
import '../patterns/pattern_registry.dart';
import '../reporters/json_reporter.dart';
import '../reporters/table_reporter.dart';

/// Command to debug smart playlist extraction against
/// a live RSS feed.
class SmartPlaylistDebugCommand {
  SmartPlaylistDebugCommand({StringSink? sink, PatternRegistry? registry})
    : _sink = sink ?? StringBuffer(),
      _registry = registry ?? PatternRegistry();

  final StringSink _sink;
  final PatternRegistry _registry;

  /// Runs the command by fetching and parsing the feed.
  Future<int> run({
    required String feedUrl,
    String? patternId,
    bool json = false,
  }) async {
    // Fetch feed
    final response = await http.get(Uri.parse(feedUrl));
    if (response.statusCode != 200) {
      _sink.writeln('Error: HTTP ${response.statusCode}');
      return 2;
    }

    // Parse feed
    final parser = PureRssParser();
    final items = <PodcastItem>[];

    try {
      await for (final entity in parser.parseFromString(response.body)) {
        if (entity is PodcastItem) {
          items.add(entity);
        }
      }
    } catch (e) {
      _sink.writeln('Error parsing feed: $e');
      return 2;
    }

    return runWithItems(
      feedUrl: feedUrl,
      items: items,
      patternId: patternId,
      json: json,
    );
  }

  /// Runs with pre-fetched items (for testing).
  Future<int> runWithItems({
    required String feedUrl,
    required List<PodcastItem> items,
    String? patternId,
    bool json = false,
  }) async {
    // Find pattern config
    final config = patternId != null
        ? _registry.findById(patternId)
        : _registry.detectFromUrl(feedUrl);

    if (config == null) {
      _sink.writeln('Error: No pattern found for feed');
      return 2;
    }

    // Use the first playlist definition for extraction.
    final definition = config.playlists.firstOrNull;
    if (definition == null) {
      _sink.writeln('Error: Pattern has no playlist definitions');
      return 2;
    }

    // Process items
    final results = <ExtractionResult>[];
    var passed = 0;
    var failed = 0;

    for (final item in items) {
      final episode = toEpisode(item);
      final result = _extractWithDiagnostics(episode, definition);
      results.add(result);

      if (result.success) {
        passed++;
      } else {
        failed++;
      }
    }

    // Report
    if (json) {
      final reporter = JsonReporter(_sink);
      reporter.start(feedUrl: feedUrl, patternId: config.id);
      for (final result in results) {
        reporter.addResult(result);
      }
      reporter.finish(total: items.length, passed: passed, failed: failed);
    } else {
      final reporter = TableReporter(_sink);
      reporter.writeHeader(
        feedUrl: feedUrl,
        patternId: config.id,
        episodeCount: items.length,
      );
      for (final result in results) {
        reporter.writeResult(result);
      }
      reporter.writeSummary(
        total: items.length,
        passed: passed,
        failed: failed,
      );
    }

    return 0 < failed ? 1 : 0;
  }

  ExtractionResult _extractWithDiagnostics(
    EpisodeData episode,
    SmartPlaylistDefinition definition,
  ) {
    String? extractedTitle;
    int? extractedEpisodeNumber;
    int? extractedSeasonNumber;
    String? titleError;
    String? episodeError;
    String? playlistEpisodeError;

    // Extract title
    if (definition.titleExtractor != null) {
      final diagnostics = TitleExtractorDiagnostics(definition.titleExtractor!);
      final result = diagnostics.run(episode);
      extractedTitle = result.extractedValue;
      titleError = result.error;
    }

    // Extract episode number (legacy extractor)
    if (definition.episodeNumberExtractor != null) {
      final diagnostics = EpisodeExtractorDiagnostics(
        definition.episodeNumberExtractor!,
      );
      final result = diagnostics.run(episode);
      extractedEpisodeNumber = result.extractedValue;
      episodeError = result.error;
    }

    // Extract season+episode from title prefix
    if (definition.smartPlaylistEpisodeExtractor != null) {
      final diagnostics = SmartPlaylistEpisodeExtractorDiagnostics(
        definition.smartPlaylistEpisodeExtractor!,
      );
      final result = diagnostics.run(episode);
      if (result.hasValues) {
        extractedSeasonNumber = result.extractedSeasonNumber;
        if (result.extractedEpisodeNumber != null) {
          extractedEpisodeNumber = result.extractedEpisodeNumber;
        }
      }
      playlistEpisodeError = result.error;
    }

    // Build result
    final hasError = extractedTitle == null;
    final error = titleError ?? episodeError ?? playlistEpisodeError;

    return ExtractionResult(
      title: episode.title,
      rssSeasonNumber: episode.seasonNumber,
      rssEpisodeNumber: episode.episodeNumber,
      extractedTitle: extractedTitle,
      extractedEpisodeNumber: extractedEpisodeNumber,
      extractedSeasonNumber: extractedSeasonNumber,
      diagnostics: hasError
          ? ExtractionDiagnostics(
              titlePattern: definition.titleExtractor?.pattern,
              fallbackValue: definition.titleExtractor?.fallbackValue,
              error: error ?? 'extraction failed',
            )
          : null,
    );
  }
}
