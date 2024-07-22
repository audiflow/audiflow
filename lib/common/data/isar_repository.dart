import 'package:audiflow/common/data/app_path_repository.dart';
import 'package:audiflow/entities/playing_episode.dart';
import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/features/queue/model/queue.dart';
import 'package:audiflow/utils/run_once.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'isar_repository.g.dart';

@Riverpod(keepAlive: true)
IsarBundle repository(RepositoryRef ref) =>
    IsarBundle(storageDir: ref.read(appDocDirProvider));

class IsarBundle {
  IsarBundle({
    required this.storageDir,
  });

  final String storageDir;
  late Isar isar;

  Future<void> ensureInitialized() async {
    await runOnce(() async {
      isar = Isar.getInstance() ??
          await Isar.open(
            [
              BlockSchema,
              DownloadableSchema,
              EpisodeSchema,
              EpisodeStatsSchema,
              FeedUrlSchema,
              FundingSchema,
              LockedSchema,
              PersonSchema,
              PlayingEpisodeSchema,
              PodcastSchema,
              PodcastStatsSchema,
              PodcastViewStatsSchema,
              QueueSchema,
              TranscriptUrlSchema,
              TranscriptSchema,
              SubtitleSchema,
              ValueSchema,
              ValueRecipientSchema,
            ],
            directory: storageDir,
          );
    });
  }

  Future<void> close() async {
    await isar.close();
  }
}
