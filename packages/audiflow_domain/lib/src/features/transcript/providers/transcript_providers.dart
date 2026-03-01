import 'package:audiflow_podcast/audiflow_podcast.dart'
    show TranscriptFileParser;
import 'package:riverpod/riverpod.dart';

import '../../../common/database/app_database.dart';
import '../repositories/chapter_repository_impl.dart';
import '../repositories/transcript_repository_impl.dart';

/// Transcript metadata for a specific episode.
final episodeTranscriptMetasProvider = FutureProvider.autoDispose
    .family<List<EpisodeTranscript>, int>((ref, episodeId) {
      return ref
          .watch(transcriptRepositoryProvider)
          .getMetasByEpisodeId(episodeId);
    });

/// All segments for a specific transcript.
final transcriptSegmentsProvider = FutureProvider.autoDispose
    .family<List<TranscriptSegment>, int>((ref, transcriptId) {
      return ref
          .watch(transcriptRepositoryProvider)
          .getAllSegments(transcriptId);
    });

/// Chapters for a specific episode.
final episodeChaptersProvider = FutureProvider.autoDispose
    .family<List<EpisodeChapter>, int>((ref, episodeId) {
      return ref.watch(chapterRepositoryProvider).getByEpisodeId(episodeId);
    });

/// Whether an episode has a supported transcript format.
final episodeHasTranscriptProvider = FutureProvider.autoDispose
    .family<bool, int>((ref, episodeId) async {
      final metas = await ref.watch(
        episodeTranscriptMetasProvider(episodeId).future,
      );
      return metas.any((m) => TranscriptFileParser.isSupported(m.type));
    });
