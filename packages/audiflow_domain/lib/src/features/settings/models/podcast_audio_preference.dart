import 'package:isar_community/isar.dart';

part 'podcast_audio_preference.g.dart';

/// Per-podcast override of the global audio settings.
///
/// A row exists only while the override is switched on; deleting it
/// returns the podcast to the global settings. [skipSilence] and
/// [voiceBoost] are reserved for upcoming audio options and stay null
/// (meaning "inherit global") until those options exist.
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
