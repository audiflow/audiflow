import 'package:isar_community/isar.dart';

part 'podcast_audio_preference.g.dart';

/// Per-podcast override of the global audio settings.
///
/// A row exists only while the override is switched on; deleting it
/// returns the podcast to the global settings. [skipSilence] and
/// [voiceBoost] are null on rows written before those options existed;
/// such a row takes the global value for them when it is loaded.
@collection
@Name('PodcastAudioPreference')
class PodcastAudioPreference {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int podcastId;

  late double speed;

  bool? skipSilence;

  bool? voiceBoost;
}
