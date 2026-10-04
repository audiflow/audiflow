import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../models/episode.dart';

/// Returns a stable fingerprint of the episode fields that smart
/// playlist resolution and enrichment read.
///
/// A cached grouping is valid only while the podcast's episodes still
/// produce the fingerprint it was resolved from. Any added, removed, or
/// edited episode changes the value. Order-independent: episodes are
/// sorted by id before hashing.
String computeEpisodeFingerprint(List<Episode> episodes) {
  final sorted = List.of(episodes)..sort((a, b) => a.id.compareTo(b.id));
  final rows = sorted.map(_fingerprintRow).toList();
  return sha256.convert(utf8.encode(jsonEncode(rows))).toString();
}

List<Object?> _fingerprintRow(Episode episode) => [
  episode.id,
  episode.title,
  episode.description,
  episode.seasonNumber,
  episode.episodeNumber,
  episode.publishedAt?.toUtc().millisecondsSinceEpoch,
  episode.imageUrl,
  episode.durationMs,
];
