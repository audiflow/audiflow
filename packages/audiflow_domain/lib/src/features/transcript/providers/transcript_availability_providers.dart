import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/transcript_service.dart';

part 'transcript_availability_providers.g.dart';

/// What transcript fetches this session found out, by episode id: true when
/// a transcript loaded, false when none of the declared files yielded one.
///
/// Lets every surface that offers a transcript (the episode row's badge,
/// the player's page) agree once a fetch has settled the question, without
/// each one fetching. Unusable files are also recorded on disk; this map
/// additionally covers failures that are kept retryable (offline, HTTP
/// errors) for the rest of the session.
@Riverpod(keepAlive: true)
class TranscriptFetchOutcomes extends _$TranscriptFetchOutcomes {
  @override
  Map<int, bool> build() => const {};

  void record(int episodeId, {required bool usable}) {
    if (state[episodeId] == usable) return;
    state = {...state, episodeId: usable};
  }
}

/// The id of the episode's transcript once its content is stored, fetching
/// it if needed; null when the episode has no transcript that loads.
///
/// Watching this costs a download the first time, so it is meant for the
/// now-playing episode, not for every row of a list.
@riverpod
Future<int?> usableTranscriptId(Ref ref, int episodeId) async {
  final transcriptId = await ref
      .watch(transcriptServiceProvider)
      .ensureContent(episodeId);
  if (ref.mounted) {
    ref
        .read(transcriptFetchOutcomesProvider.notifier)
        .record(episodeId, usable: transcriptId != null);
  }
  return transcriptId;
}
