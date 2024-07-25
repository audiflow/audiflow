import 'package:audiflow/entities/playing_episode.dart';
import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/features/preference/model/app_preference.dart';
import 'package:audiflow/features/queue/model/queue.dart';
import 'package:isar/isar.dart';

class IsarFactory {
  IsarFactory._();

  static Future<Isar> create(String storageDir) async {
    return Isar.getInstance() ??
        await Isar.open(
          [
            AppPreferenceSchema,
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
  }
}
