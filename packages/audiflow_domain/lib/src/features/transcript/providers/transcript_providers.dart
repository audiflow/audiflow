import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/database/app_database.dart';
import '../repositories/chapter_repository_impl.dart';
import '../repositories/transcript_repository_impl.dart';

part 'transcript_providers.g.dart';

// Manual providers for Drift-generated types.
// riverpod_generator cannot resolve types defined in .g.dart part files
// (InvalidTypeException), so these use manual AutoDisposeFutureProvider.family.

/// Transcript metadata for a specific episode.
final episodeTranscriptMetasProvider =
    AutoDisposeFutureProvider.family<List<EpisodeTranscript>, int>((
      ref,
      episodeId,
    ) {
      return ref
          .watch(transcriptRepositoryProvider)
          .getMetasByEpisodeId(episodeId);
    });

/// All segments for a specific transcript.
final transcriptSegmentsProvider =
    AutoDisposeFutureProvider.family<List<TranscriptSegment>, int>((
      ref,
      transcriptId,
    ) {
      return ref
          .watch(transcriptRepositoryProvider)
          .getAllSegments(transcriptId);
    });

/// Chapters for a specific episode.
final episodeChaptersProvider =
    AutoDisposeFutureProvider.family<List<EpisodeChapter>, int>((
      ref,
      episodeId,
    ) {
      return ref.watch(chapterRepositoryProvider).getByEpisodeId(episodeId);
    });

/// Whether an episode has a supported transcript format.
@riverpod
Future<bool> episodeHasTranscript(Ref ref, int episodeId) async {
  final metas = await ref.watch(
    episodeTranscriptMetasProvider(episodeId).future,
  );
  return metas.any((m) => TranscriptFileParser.isSupported(m.type));
}
