import 'package:audiflow/features/browser/podcast/model/podcast_details_page_model.dart';
import 'package:audiflow/features/browser/season/model/season.dart';
import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/features/player/model/playing_episode.dart';
import 'package:audiflow/features/preference/model/preference.dart';
import 'package:audiflow/features/queue/model/auto_queue_builder_info.dart';
import 'package:audiflow/features/queue/model/queue.dart';
import 'package:isar/isar.dart';

class IsarFactory {
  IsarFactory._();

  static Future<Isar> create(String storageDir) async {
    return Isar.getInstance() ??
        await Isar.open(
          [
            PreferenceSchema,
            AutoQueueBuilderInfoSchema,
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
            PodcastDetailsPageModelSchema,
            QueueSchema,
            SeasonSchema,
            SeasonStatsSchema,
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
