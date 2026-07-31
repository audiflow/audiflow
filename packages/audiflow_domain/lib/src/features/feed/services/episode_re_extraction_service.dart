import 'package:audiflow_core/audiflow_core.dart';

import '../models/episode.dart';
import '../models/preset_config.dart';
import 'episode_extractor_resolver.dart';

/// Re-applies numbering extraction to already-ingested episodes.
///
/// Numbering is normally extracted once at ingest, so episodes stored
/// under an older preset config keep stale season/episode numbers when
/// the config changes. This service refreshes them in place.
class EpisodeReExtractionService {
  EpisodeReExtractionService({EpisodeExtractorResolver? resolver})
    : _resolver = resolver ?? EpisodeExtractorResolver();

  final EpisodeExtractorResolver _resolver;

  /// Re-extracts numbering for [episodes] using [config].
  ///
  /// Mutates matching episodes in place and returns only those whose
  /// seasonNumber or episodeNumber actually changed.
  List<Episode> reExtract(List<Episode> episodes, PresetConfig config) {
    final changed = <Episode>[];
    for (final episode in episodes) {
      final extractor = _resolver.resolve(
        episode.title,
        episode.description,
        config,
      );
      if (extractor == null) continue;

      final extracted = extractor.extract(
        SimpleEpisodeData(
          title: episode.title,
          description: episode.description,
          seasonNumber: episode.seasonNumber,
          episodeNumber: episode.episodeNumber,
        ),
      );
      if (!extracted.hasValues) continue;

      final seasonNumber = extracted.seasonNumber ?? episode.seasonNumber;
      final episodeNumber = extracted.episodeNumber ?? episode.episodeNumber;
      if (seasonNumber == episode.seasonNumber &&
          episodeNumber == episode.episodeNumber) {
        continue;
      }

      episode
        ..seasonNumber = seasonNumber
        ..episodeNumber = episodeNumber;
      changed.add(episode);
    }
    return changed;
  }
}
