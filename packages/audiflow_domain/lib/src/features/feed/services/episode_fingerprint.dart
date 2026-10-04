import '../models/episode.dart';

// FNV-1a 64-bit. Runs on every cached read over all episodes,
// descriptions included, so it hashes code units in place instead of
// encoding and buffering the whole feed. Stable across app runs,
// unlike String.hashCode. Mobile-only, so 64-bit int wraparound holds.
const _fnvOffsetBasis = 0xcbf29ce484222325;
const _fnvPrime = 0x100000001b3;
const _nullMarker = -1;

/// Returns a stable fingerprint of the episode fields that smart
/// playlist resolution and enrichment read.
///
/// A cached grouping is valid only while the podcast's episodes still
/// produce the fingerprint it was resolved from. Any added, removed, or
/// edited episode changes the value. Order-independent: episodes are
/// sorted by id before hashing.
String computeEpisodeFingerprint(List<Episode> episodes) {
  final sorted = List.of(episodes)..sort((a, b) => a.id.compareTo(b.id));
  var hash = _mixInt(_fnvOffsetBasis, sorted.length);
  for (final episode in sorted) {
    hash = _mixEpisode(hash, episode);
  }
  return hash.toUnsigned(64).toRadixString(16).padLeft(16, '0');
}

int _mixEpisode(int hash, Episode episode) {
  var h = _mixInt(hash, episode.id);
  h = _mixString(h, episode.title);
  h = _mixString(h, episode.description);
  h = _mixInt(h, episode.seasonNumber);
  h = _mixInt(h, episode.episodeNumber);
  h = _mixInt(h, episode.publishedAt?.toUtc().millisecondsSinceEpoch);
  h = _mixString(h, episode.imageUrl);
  return _mixInt(h, episode.durationMs);
}

int _mixInt(int hash, int? value) {
  if (value == null) return _mixUnit(hash, _nullMarker);
  var h = hash;
  for (var shift = 0; shift < 64; shift += 16) {
    h = _mixUnit(h, (value >> shift) & 0xffff);
  }
  return h;
}

// Length prefix keeps adjacent fields unambiguous ("ab"+"c" vs "a"+"bc").
int _mixString(int hash, String? value) {
  if (value == null) return _mixUnit(hash, _nullMarker);
  var h = _mixInt(hash, value.length);
  for (var i = 0; i < value.length; i++) {
    h = _mixUnit(h, value.codeUnitAt(i));
  }
  return h;
}

int _mixUnit(int hash, int unit) => (hash ^ unit) * _fnvPrime;
