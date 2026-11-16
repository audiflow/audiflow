import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'snapshot_body.dart';

/// Why a snapshot file could not be read. Reading never writes, so any of
/// these leaves the database untouched.
sealed class SnapshotReadFailure implements Exception {
  const SnapshotReadFailure();
}

/// Not an Audiflow backup at all: not a header line, not JSON, or another
/// format.
final class NotASnapshot extends SnapshotReadFailure {
  const NotASnapshot();

  @override
  String toString() => 'NotASnapshot';
}

/// A backup, but damaged: truncated, a checksum mismatch, or missing or
/// malformed data. [location] names where, never a value.
final class DamagedSnapshot extends SnapshotReadFailure {
  const DamagedSnapshot(this.location);

  final String location;

  @override
  String toString() => 'DamagedSnapshot($location)';
}

/// Written by a newer app version whose format this one cannot read.
final class SnapshotTooNew extends SnapshotReadFailure {
  const SnapshotTooNew(this.formatVersion);

  final int formatVersion;

  @override
  String toString() => 'SnapshotTooNew($formatVersion)';
}

/// Row counts shown before restoring.
class SnapshotCounts {
  const SnapshotCounts({
    required this.podcasts,
    required this.episodes,
    required this.queue,
    required this.stations,
  });

  final int podcasts;
  final int episodes;
  final int queue;
  final int stations;

  Map<String, int> toJson() => {
    'podcasts': podcasts,
    'episodes': episodes,
    'queue': queue,
    'stations': stations,
  };

  static SnapshotCounts fromJson(Map<String, Object?> json) => SnapshotCounts(
    podcasts: _int(json, 'podcasts', 'counts'),
    episodes: _int(json, 'episodes', 'counts'),
    queue: _int(json, 'queue', 'counts'),
    stations: _int(json, 'stations', 'counts'),
  );
}

/// The JSON header line: everything the confirmation screen shows, readable
/// without decompressing the body.
class SnapshotHeader {
  const SnapshotHeader({
    required this.formatVersion,
    required this.createdAt,
    required this.historyId,
    required this.appVersion,
    required this.platform,
    required this.counts,
    required this.payloadSha256,
  });

  final int formatVersion;
  final DateTime createdAt;
  final String historyId;
  final String appVersion;
  final String platform;
  final SnapshotCounts counts;

  /// Hex sha256 of the gzip-compressed body.
  final String payloadSha256;

  Map<String, Object?> toJson() => {
    'format': snapshotFormat,
    'formatVersion': formatVersion,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'historyId': historyId,
    'app': {'version': appVersion, 'platform': platform},
    'counts': counts.toJson(),
    'payloadSha256': payloadSha256,
  };
}

/// The `format` every Audiflow backup header names.
const snapshotFormat = 'audiflow-backup';

/// The newest format this version writes and reads.
const currentSnapshotFormatVersion = 1;

// A header is small; a first line longer than this is not one.
const _maxHeaderBytes = 64 * 1024;

/// A read snapshot file.
class SnapshotFile {
  SnapshotFile(this.header, this.body);

  final SnapshotHeader header;
  final SnapshotBody body;
}

/// Writes [body] as a snapshot file: the header line, then the body,
/// gzip-compressed.
Uint8List encodeSnapshotFile({
  required SnapshotBody body,
  required DateTime createdAt,
  required String historyId,
  required String appVersion,
  required String platform,
  required SnapshotCounts counts,
}) {
  final payload = Uint8List.fromList(gzip.encode(body.encode()));
  final header = SnapshotHeader(
    formatVersion: currentSnapshotFormatVersion,
    createdAt: createdAt,
    historyId: historyId,
    appVersion: appVersion,
    platform: platform,
    counts: counts,
    payloadSha256: sha256.convert(payload).toString(),
  );
  final out = BytesBuilder(copy: false)
    ..add(utf8.encode(jsonEncode(header.toJson())))
    ..addByte(0x0a)
    ..add(payload);
  return out.takeBytes();
}

/// Reads only the header of [bytes], for the confirmation screen. Throws
/// [SnapshotReadFailure].
SnapshotHeader readSnapshotHeader(Uint8List bytes) => _split(bytes).header;

/// Reads and checks all of [bytes]. Throws [SnapshotReadFailure].
SnapshotFile readSnapshotFile(Uint8List bytes) {
  final (:header, :payload) = _split(bytes);
  if (sha256.convert(payload).toString() != header.payloadSha256) {
    throw const DamagedSnapshot('payload checksum');
  }
  final List<int> raw;
  try {
    raw = gzip.decode(payload);
  } on FormatException {
    throw const DamagedSnapshot('payload compression');
  } on FileSystemException {
    // dart:io reports a corrupt gzip stream this way on some platforms.
    throw const DamagedSnapshot('payload compression');
  }
  try {
    return SnapshotFile(header, SnapshotBody.decode(Uint8List.fromList(raw)));
  } on FormatException {
    throw const DamagedSnapshot('payload contents');
  }
}

({SnapshotHeader header, Uint8List payload}) _split(Uint8List bytes) {
  final limit = bytes.length < _maxHeaderBytes ? bytes.length : _maxHeaderBytes;
  final newline = bytes.sublist(0, limit).indexOf(0x0a);
  if (newline < 0) throw const NotASnapshot();
  final Object? json;
  try {
    json = jsonDecode(utf8.decode(bytes.sublist(0, newline)));
  } on FormatException {
    throw const NotASnapshot();
  }
  if (json is! Map<String, Object?> || json['format'] != snapshotFormat) {
    throw const NotASnapshot();
  }
  final version = json['formatVersion'];
  if (version is! int) throw const DamagedSnapshot('header.formatVersion');
  if (currentSnapshotFormatVersion < version) throw SnapshotTooNew(version);
  return (
    header: _header(json, version),
    payload: Uint8List.sublistView(bytes, newline + 1),
  );
}

SnapshotHeader _header(Map<String, Object?> json, int version) {
  final createdAt = DateTime.tryParse(_string(json, 'createdAt', 'header'));
  if (createdAt == null) throw const DamagedSnapshot('header.createdAt');
  final app = json['app'];
  final counts = json['counts'];
  if (app is! Map<String, Object?>) throw const DamagedSnapshot('header.app');
  if (counts is! Map<String, Object?>) {
    throw const DamagedSnapshot('header.counts');
  }
  return SnapshotHeader(
    formatVersion: version,
    createdAt: createdAt,
    historyId: _string(json, 'historyId', 'header'),
    appVersion: _string(app, 'version', 'header.app'),
    platform: _string(app, 'platform', 'header.app'),
    counts: SnapshotCounts.fromJson(counts),
    payloadSha256: _string(json, 'payloadSha256', 'header'),
  );
}

String _string(Map<String, Object?> json, String key, String at) {
  final v = json[key];
  if (v is String) return v;
  throw DamagedSnapshot('$at.$key');
}

int _int(Map<String, Object?> json, String key, String at) {
  final v = json[key];
  if (v is int) return v;
  throw DamagedSnapshot('$at.$key');
}
