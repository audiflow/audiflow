import 'dart:typed_data';

import 'package:isar_community/isar.dart';

import '../user_state/models/episode_user_state.dart';
import '../user_state/models/hlc.dart';
import '../user_state/models/outbox_op.dart';
import '../user_state/models/podcast_user_state.dart';
import '../user_state/models/queue_entry.dart';
import '../user_state/models/station_state.dart';
import '../user_state/models/sync_meta.dart';
import '../user_state/models/synced_setting.dart';
import '../user_state/services/user_state_store.dart';
import '../user_state/sync/proto_wire.dart';
import '../user_state/sync/user_state_codec.dart';
import '../user_state/sync/user_state_fields.dart';
import 'snapshot_body.dart';
import 'snapshot_file.dart';

/// How a podcast looked when the snapshot was taken, shown until its feed
/// is fetched again.
class SnapshotPodcastInfo {
  const SnapshotPodcastInfo({this.title, this.artistName, this.artworkUrl});

  final String? title;
  final String? artistName;
  final String? artworkUrl;
}

/// What a merge did.
class SnapshotMergeResult {
  const SnapshotMergeResult({
    required this.changedRows,
    required this.sameHistory,
    required this.podcastInfo,
  });

  /// Rows the merge created or changed.
  final int changedRows;

  /// Whether the snapshot came from this data's history, including one this
  /// database adopted because it was empty.
  final bool sameHistory;

  /// Display data by podcastKey.
  final Map<String, SnapshotPodcastInfo> podcastInfo;
}

/// Merges a snapshot into this device's user state with the sync merge
/// rules, in one write transaction: newer field wins, counters take the
/// maximum, tombstones stay. Data here that is newer than the snapshot is
/// kept, and merging the same snapshot twice changes nothing the second
/// time.
///
/// Fields the merge changes land in the outbox with the clocks they came
/// with. A value that does not fit its field throws [DamagedSnapshot] and
/// rolls the whole merge back.
class SnapshotMerger {
  SnapshotMerger(this._isar, {int Function()? nowMillis})
    : _nowMillis = nowMillis ?? _wallClock;

  final Isar _isar;
  final int Function() _nowMillis;

  static int _wallClock() => DateTime.now().millisecondsSinceEpoch;

  Future<SnapshotMergeResult> merge(SnapshotFile file) {
    final store = UserStateStore(_isar, nowMillis: _nowMillis);
    return store.write((txn) async {
      final meta = (await _isar.syncMetas.get(SyncMeta.singletonId))!;
      final incomingHistory = file.header.historyId;
      // A manual restore into an empty database inherits the backup's
      // history. Settings do not count: launch copies them in on its own.
      if (incomingHistory.isNotEmpty && await _hasNoUserData()) {
        meta.historyId = incomingHistory;
      }
      final run = _MergeRun(
        _isar,
        txn,
        now: _nowMillis(),
        sameHistory: meta.historyId == incomingHistory,
        horizon: meta.tombstoneHorizon,
      );
      await run.mergeAll(file.body.sections);

      // Later local changes must sort after everything merged in.
      if (0 < run.maxHlc) {
        meta.hlc = Hlc.unpack(
          meta.hlc,
        ).receive(Hlc.unpack(run.maxHlc), _nowMillis()).packed;
      }
      // Raised after the merge, not before: the snapshot's own rows are live
      // in its source, however old their clocks.
      final horizon = file.header.tombstoneHorizon;
      if (run.sameHistory && meta.tombstoneHorizon < horizon) {
        meta.tombstoneHorizon = horizon;
      }
      await _isar.syncMetas.put(meta);
      return SnapshotMergeResult(
        changedRows: run.changedRows,
        sameHistory: run.sameHistory,
        podcastInfo: run.podcastInfo,
      );
    });
  }

  Future<bool> _hasNoUserData() async =>
      await _isar.podcastUserStates.count() == 0 &&
      await _isar.episodeUserStates.count() == 0 &&
      await _isar.queueEntrys.count() == 0 &&
      await _isar.stationStates.count() == 0;
}

class _MergeRun {
  _MergeRun(
    this._isar,
    this._txn, {
    required this.now,
    required this.sameHistory,
    required this.horizon,
  });

  final Isar _isar;
  final UserStateTxn _txn;
  final int now;
  final bool sameHistory;
  final int horizon;

  int changedRows = 0;
  int maxHlc = 0;
  final podcastInfo = <String, SnapshotPodcastInfo>{};

  Future<void> mergeAll(Map<String, List<SnapshotRow>> sections) async {
    // Parents before the rows embedded in them.
    final order = [
      UserStateEntities.podcast.name,
      UserStateEntities.playOrder.name,
      UserStateEntities.episode.name,
      UserStateEntities.episodeCounter.name,
    ];
    final names = [
      ...order.where(sections.containsKey),
      ...sections.keys.where((n) => !order.contains(n)),
    ];
    for (final name in names) {
      for (final row in sections[name]!) {
        await _mergeRow(name, row.key, row.fields);
      }
    }
  }

  Future<void> _mergeRow(String entity, String key, Uint8List bytes) async {
    final DecodedEntity decoded;
    try {
      decoded = decodeEntity(entity, bytes);
    } on FormatException {
      throw DamagedSnapshot('$entity row');
    }
    await _keepUnknown(entity, key, decoded.unknown);
    switch (entity) {
      case 'podcast':
        await _merge(
          UserStateEntities.podcast,
          key,
          decoded,
          find: _isar.podcastUserStates.getByPodcastKey,
          create: () => PodcastUserState()..podcastKey = key,
          put: _isar.podcastUserStates.put,
          isSet: true,
        );
      case 'playOrder':
        await _mergePlayOrder(key, decoded);
      case 'episode':
        await _merge(
          UserStateEntities.episode,
          key,
          decoded,
          find: _isar.episodeUserStates.getByEpisodeKey,
          create: () => EpisodeUserState()..episodeKey = key,
          put: _isar.episodeUserStates.put,
        );
      case 'episodeCounter':
        await _mergeCounter(key, decoded);
      case 'queueEntry':
        await _merge(
          UserStateEntities.queueEntry,
          key,
          decoded,
          find: _isar.queueEntrys.getByEntryId,
          create: () => QueueEntry()..entryId = key,
          put: _isar.queueEntrys.put,
          isSet: true,
        );
      case 'station':
        await _merge(
          UserStateEntities.station,
          key,
          decoded,
          find: _isar.stationStates.getByStationId,
          create: () => StationState()..stationId = key,
          put: _isar.stationStates.put,
          isSet: true,
        );
      case 'stationMember':
        final [stationId!, podcastKey!] = _split(entity, key, 2, required: 2);
        await _merge(
          UserStateEntities.stationMember,
          key,
          decoded,
          find: (_) => _isar.stationMembers.getByStationIdPodcastKey(
            stationId,
            podcastKey,
          ),
          create: () => StationMember()
            ..stationId = stationId
            ..podcastKey = podcastKey,
          put: _isar.stationMembers.put,
          isSet: true,
        );
      case 'setting':
        await _merge(
          UserStateEntities.setting,
          key,
          decoded,
          find: _isar.syncedSettings.getByKey,
          create: () => SyncedSetting()..key = key,
          put: _isar.syncedSettings.put,
        );
      case 'podcastInfo':
        final k = decoded.known;
        podcastInfo[key] = SnapshotPodcastInfo(
          title: _string(k[1], entity),
          artistName: _string(k[2], entity),
          artworkUrl: _string(k[3], entity),
        );
    }
  }

  Future<void> _merge<T>(
    EntitySpec<T> spec,
    String key,
    DecodedEntity decoded, {
    required Future<T?> Function(String key) find,
    required T Function() create,
    required Future<void> Function(T row) put,
    bool isSet = false,
  }) async {
    final existing = await find(key);
    if (existing == null && isSet && _gonePastHorizon(decoded)) return;
    final row = existing ?? create();
    final changed = _apply(
      spec,
      row,
      decoded,
      isNew: existing == null,
      scratch: create(),
    );
    if (changed.isEmpty) return;
    _requireComplete(spec, row);
    await put(row);
    _txn.touchMerged(spec, row, changed);
    changedRows++;
  }

  Future<void> _mergePlayOrder(String key, DecodedEntity decoded) async {
    // groupId is null for a playlist's own order.
    final [podcastKey!, playlistId!, groupId] = _split(
      'playOrder',
      key,
      3,
      required: 2,
    );
    final parent =
        await _isar.podcastUserStates.getByPodcastKey(podcastKey) ??
        (PodcastUserState()..podcastKey = podcastKey);
    final entry = parent.playOrders.firstWhere(
      (e) => e.playlistId == playlistId && e.groupId == groupId,
      orElse: () => PlayOrderEntry()
        ..playlistId = playlistId
        ..groupId = groupId,
    );
    final isNew = !parent.playOrders.contains(entry);
    final row = (podcastKey: podcastKey, entry: entry);
    final changed = _apply(
      UserStateEntities.playOrder,
      row,
      decoded,
      isNew: isNew,
      scratch: (podcastKey: podcastKey, entry: PlayOrderEntry()),
    );
    if (changed.isEmpty) return;
    if (isNew) parent.playOrders = [...parent.playOrders, entry];
    await _isar.podcastUserStates.put(parent);
    _txn.touchMerged(UserStateEntities.playOrder, row, changed);
    changedRows++;
  }

  Future<void> _mergeCounter(String key, DecodedEntity decoded) async {
    final [episodeKey!, deviceId!] = _split(
      'episodeCounter',
      key,
      2,
      required: 2,
    );
    final parent = await _isar.episodeUserStates.getByEpisodeKey(episodeKey);
    // A counter always travels with its episode; without one there is no
    // podcast to attach it to.
    if (parent == null) throw const DamagedSnapshot('episodeCounter parent');
    final counters = parent.counters.firstWhere(
      (c) => c.deviceId == deviceId,
      orElse: () => EpisodePlayCounters()..deviceId = deviceId,
    );
    final isNew = !parent.counters.contains(counters);
    final row = (episodeKey: episodeKey, counters: counters);
    final changed = _apply(
      UserStateEntities.episodeCounter,
      row,
      decoded,
      isNew: isNew,
      scratch: (episodeKey: episodeKey, counters: EpisodePlayCounters()),
    );
    if (changed.isEmpty) return;
    if (isNew) parent.counters = [...parent.counters, counters];
    await _isar.episodeUserStates.put(parent);
    _txn.touchMerged(UserStateEntities.episodeCounter, row, changed);
    changedRows++;
  }

  /// Applies the fields of [incoming] that win over [row]'s; returns their
  /// ids.
  ///
  /// [scratch] is a throwaway row every incoming value is first checked
  /// against.
  Set<int> _apply<T>(
    EntitySpec<T> spec,
    T row,
    DecodedEntity incoming, {
    required bool isNew,
    required T scratch,
  }) {
    // Several fields can share one clock; each decides against the clock
    // as it was before this merge touched it.
    final before = <int, int>{
      for (final f in spec.fields)
        if (f.hlc != null) f.id: f.hlc!(row),
    };
    // Every value must fit its field, whether or not it wins here, so a
    // damaged snapshot fails the same way on every device.
    for (final MapEntry(key: id, value: value) in incoming.known.entries) {
      _set(spec, spec.field(id)!, scratch, value);
    }
    final changed = <int>{};
    for (final MapEntry(key: id, value: value) in incoming.known.entries) {
      final field = spec.field(id)!;
      if (field.growOnly) {
        final current = field.value(row);
        if (value is! int || current is! int) {
          throw DamagedSnapshot('${spec.name}.${field.name}');
        }
        if (current < value) {
          _set(spec, field, row, value);
          changed.add(id);
        }
        continue;
      }
      if (field.hlc == null) {
        // Set once, when the row is created.
        if (isNew) {
          _set(spec, field, row, value);
          changed.add(id);
        }
        continue;
      }
      final arrived = incoming.hlcs[id];
      if (arrived == null) continue;
      final hlc = Hlc.unpack(arrived).clampedTo(now).packed;
      if (maxHlc < hlc) maxHlc = hlc;
      if (!_wins(hlc, value, before[id]!, field.value(row))) continue;
      _set(spec, field, row, value);
      field.setHlc!(row, hlc);
      changed.add(id);
    }
    return changed;
  }

  /// Newer clock wins. Equal clocks (two devices in one millisecond) pick
  /// the larger encoded value, so every device settles on the same one.
  static bool _wins(int hlc, Object? value, int localHlc, Object? local) =>
      _newer(hlc, encodeValue(value), localHlc, encodeValue(local));

  static bool _newer(int hlc, List<int> a, int localHlc, List<int> b) {
    if (hlc != localHlc) return localHlc < hlc;
    return sortsAbove(a, b);
  }

  static void _set<T>(
    EntitySpec<T> spec,
    FieldSpec<T> field,
    T row,
    Object? v,
  ) {
    try {
      field.set(row, v);
      // A value of the wrong type is a damaged input, not a bug here.
      // ignore: avoid_catching_errors
    } on TypeError {
      throw DamagedSnapshot('${spec.name}.${field.name}');
    }
  }

  /// A new row must have every field without a default: an episode's
  /// podcastKey, a queue entry's episodeKey.
  static void _requireComplete<T>(EntitySpec<T> spec, T row) {
    for (final field in spec.fields) {
      try {
        field.value(row);
        // An unset late field: the row arrived without it.
        // ignore: avoid_catching_errors
      } on Error {
        throw DamagedSnapshot('${spec.name}.${field.name}');
      }
    }
  }

  /// Within one history, an element unknown here and last changed before
  /// the tombstone horizon was deleted, and its tombstone purged.
  bool _gonePastHorizon(DecodedEntity decoded) {
    if (!sameHistory || horizon == 0) return false;
    final hlcs = decoded.hlcs.values;
    final latest = hlcs.isEmpty ? 0 : hlcs.reduce((a, b) => a < b ? b : a);
    return latest < horizon;
  }

  Future<void> _keepUnknown(
    String entity,
    String key,
    List<ProtoField> unknown,
  ) async {
    for (final field in unknown) {
      final hlc = Hlc.unpack(_opaqueHlc(field)).clampedTo(now).packed;
      if (maxHlc < hlc) maxHlc = hlc;
      // The clock lives in OpaqueField.hlc (clamped); the value bytes stay
      // as received, minus a clock copy that would make equal fields differ.
      final payload = _normalized(field);
      final existing = await _isar.opaqueFields.getByEntityKeyFieldId(
        entity,
        key,
        field.fieldNumber,
      );
      if (existing != null &&
          !_newer(
            hlc,
            fieldValueBytes(payload),
            existing.hlc,
            fieldValueBytes(existing.payload),
          )) {
        continue;
      }
      await _isar.opaqueFields.put(
        (existing ?? OpaqueField())
          ..entity = entity
          ..key = key
          ..fieldId = field.fieldNumber
          ..hlc = hlc
          ..payload = payload,
      );
      _txn.addOpaqueOp(entity, key, field.fieldNumber, hlc, payload);
      changedRows++;
    }
  }

  static List<int> _normalized(ProtoField field) {
    if (field.wireType != WireType.lengthDelimited) return field.encode();
    try {
      final value = withoutHlc(field.raw);
      return (ProtoWriter()..writeBytes(field.fieldNumber, value)).takeBytes();
    } on FormatException {
      return field.encode();
    }
  }

  // The clock a snapshot stored inside an unknown field's Value, if any.
  static int _opaqueHlc(ProtoField field) {
    if (field.wireType != WireType.lengthDelimited) return 0;
    try {
      return decodeHlc(field.raw) ?? 0;
    } on FormatException {
      return 0;
    }
  }

  /// The parts of [key]; the first [required] of them must not be null.
  static List<String?> _split(
    String entity,
    String key,
    int count, {
    required int required,
  }) {
    final List<String?> parts;
    try {
      parts = splitCompositeKey(key, count);
    } on FormatException {
      throw DamagedSnapshot('$entity key');
    }
    if (parts.take(required).contains(null)) {
      throw DamagedSnapshot('$entity key');
    }
    return parts;
  }

  static String? _string(Object? value, String entity) {
    if (value == null || value is String) return value as String?;
    throw DamagedSnapshot(entity);
  }
}
