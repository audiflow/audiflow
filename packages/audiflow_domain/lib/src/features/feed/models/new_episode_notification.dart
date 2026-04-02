import 'dart:convert';

/// Lightweight DTO carrying per-episode data for local notifications.
///
/// Created in the background isolate after feed sync detects new episodes.
/// The [toPayload] method produces a JSON string stored as the notification
/// payload so the foreground app can look up the full episode on tap.
class NewEpisodeNotification {
  const NewEpisodeNotification({
    required this.episodeId,
    required this.podcastId,
    required this.podcastTitle,
    required this.episodeTitle,
  });

  final int episodeId;
  final int podcastId;
  final String podcastTitle;
  final String episodeTitle;

  /// Returns a JSON payload string for the notification.
  String toPayload() => jsonEncode(<String, dynamic>{
    'type': 'new_episode',
    'episodeId': episodeId,
    'podcastId': podcastId,
  });
}
