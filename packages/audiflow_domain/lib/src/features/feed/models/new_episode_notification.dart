import 'dart:convert';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:characters/characters.dart';

import '../../subscription/models/subscriptions.dart';
import 'episode.dart';

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
    this.artworkUrl,
    this.publishedAt,
    this.duration,
    this.description,
  });

  /// Notification for [episode] of [subscription], with [artworkUrl] as
  /// its thumbnail.
  factory NewEpisodeNotification.fromEpisode({
    required Subscription subscription,
    required Episode episode,
    required String? artworkUrl,
  }) {
    final durationMs = episode.durationMs;
    return NewEpisodeNotification(
      episodeId: episode.id,
      podcastId: subscription.id,
      podcastTitle: subscription.title,
      episodeTitle: episode.title,
      artworkUrl: artworkUrl,
      publishedAt: episode.publishedAt,
      duration: durationMs == null ? null : Duration(milliseconds: durationMs),
      description: plainTextDescription(
        description: episode.description,
        summary: episode.summary,
      ),
    );
  }

  /// Longest description carried into a notification, ellipsis included.
  ///
  /// Notification payloads should stay small, and neither platform shows
  /// more than a few lines of body text anyway.
  static const descriptionMaxLength = 300;

  final int episodeId;
  final int podcastId;
  final String podcastTitle;
  final String episodeTitle;

  /// Podcast artwork shown as the notification thumbnail, when available.
  final String? artworkUrl;

  final DateTime? publishedAt;
  final Duration? duration;

  /// Plain-text, length-capped show notes; see [plainTextDescription].
  final String? description;

  /// Returns a JSON payload string for the notification.
  String toPayload() => jsonEncode(<String, dynamic>{
    'type': 'new_episode',
    'episodeId': episodeId,
    'podcastId': podcastId,
  });

  /// Plain text of [description], or of [summary] when the description has
  /// no text, capped at [descriptionMaxLength]. Null when neither has text.
  static String? plainTextDescription({
    required String? description,
    required String? summary,
  }) {
    final text = [description, summary]
        .map((candidate) => candidate?.htmlToMultilinePlainText ?? '')
        .firstWhere((plain) => plain.isNotEmpty, orElse: () => '');
    if (text.isEmpty) return null;
    // Count and cut by grapheme cluster so a joined emoji or a letter with
    // its combining mark is never split.
    final characters = text.characters;
    if (characters.length <= descriptionMaxLength) return text;
    final kept = characters.take(descriptionMaxLength - 1).string;
    return '${kept.trimRight()}\u2026';
  }
}
