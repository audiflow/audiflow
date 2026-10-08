import 'package:riverpod/riverpod.dart';

import '../models/episode_chapter.dart';
import '../models/episode_transcript.dart';
import '../models/transcript_segment_table.dart';
import '../repositories/chapter_repository_impl.dart';
import '../repositories/transcript_repository_impl.dart';
import 'transcript_availability_providers.dart';

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

/// Whether to mark an episode as having a transcript, without fetching.
///
/// A fetch made this session is the answer when there was one. Otherwise
/// the feed's declaration stands in, minus files already found unusable:
/// fetching per row just to draw a badge would cost a download per
/// episode, so an unfetched declared file counts until a fetch says no.
final episodeHasTranscriptProvider = FutureProvider.autoDispose
    .family<bool, int>((ref, episodeId) async {
      final fetched = ref.watch(
        transcriptFetchOutcomesProvider.select(
          (outcomes) => outcomes[episodeId],
        ),
      );
      if (fetched != null) return fetched;

      final metas = await ref.watch(
        episodeTranscriptMetasProvider(episodeId).future,
      );
      return metas.any((m) => m.isCandidate);
    });
