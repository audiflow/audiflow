import 'dart:convert';

/// What a device is playing, sent to the account's other online devices
/// and never stored (design doc, Realtime playback position). Sealed with
/// the data key, so the relay sees only a blob.
class SyncPresence {
  const SyncPresence({
    required this.episodeKey,
    required this.positionMs,
    required this.durationMs,
    required this.playing,
    required this.sentAt,
    this.speed = 1.0,
  });

  final String episodeKey;
  final int positionMs;
  final int durationMs;
  final bool playing;

  /// Playback rate, so the position can be told apart from a seek and
  /// advanced between refreshes.
  final double speed;

  /// Sender's wall clock (ms), so a receiver can advance the position
  /// while playing and drop a presence that stopped being refreshed.
  final int sentAt;

  List<int> encode() => utf8.encode(
    jsonEncode({
      'v': 1,
      'episodeKey': episodeKey,
      'positionMs': positionMs,
      'durationMs': durationMs,
      'playing': playing,
      'sentAt': sentAt,
      'speed': speed,
    }),
  );

  /// Throws [FormatException] for anything but a version 1 presence.
  static SyncPresence decode(List<int> bytes) {
    final Object? json;
    try {
      json = jsonDecode(utf8.decode(bytes));
    } on Object {
      throw const FormatException('presence is not JSON');
    }
    if (json case {
      'v': 1,
      'episodeKey': final String episodeKey,
      'positionMs': final int positionMs,
      'durationMs': final int durationMs,
      'playing': final bool playing,
      'sentAt': final int sentAt,
      'speed': final num speed,
    }) {
      return SyncPresence(
        episodeKey: episodeKey,
        positionMs: positionMs,
        durationMs: durationMs,
        playing: playing,
        sentAt: sentAt,
        speed: speed.toDouble(),
      );
    }
    throw const FormatException('presence malformed');
  }

  @override
  bool operator ==(Object other) =>
      other is SyncPresence &&
      other.episodeKey == episodeKey &&
      other.positionMs == positionMs &&
      other.durationMs == durationMs &&
      other.playing == playing &&
      other.sentAt == sentAt &&
      other.speed == speed;

  @override
  int get hashCode =>
      Object.hash(episodeKey, positionMs, durationMs, playing, sentAt, speed);
}

/// Another device's presence as this one received it.
class RemotePresence {
  const RemotePresence({
    required this.deviceId,
    required this.presence,
    required this.receivedAt,
  });

  final String deviceId;
  final SyncPresence presence;

  /// This device's wall clock (ms) on arrival.
  final int receivedAt;
}
