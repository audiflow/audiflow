import 'dart:typed_data';

import 'package:isar_community/isar.dart';

import '../subscription/models/subscriptions.dart';
import '../user_state/models/episode_user_state.dart';
import '../user_state/models/outbox_op.dart';
import '../user_state/models/podcast_user_state.dart';
import '../user_state/models/queue_entry.dart';
import '../user_state/models/station_state.dart';
import '../user_state/models/sync_meta.dart';
import '../user_state/models/synced_setting.dart';
import '../user_state/sync/proto_wire.dart';
import '../user_state/sync/user_state_codec.dart';
import '../user_state/sync/user_state_fields.dart';
import 'snapshot_body.dart';
import 'snapshot_file.dart';

/// A snapshot of this device's user state, ready to write to a file.
class ExportedSnapshot {
  ExportedSnapshot(
    this.body,
    this.counts,
    this.historyId, {
    this.tombstoneHorizon = 0,
  });

  final SnapshotBody body;
  final SnapshotCounts counts;
  final String historyId;

  /// Goes into the header, so a copy keeps blocking purged deletions.
  final int tombstoneHorizon;
}

/// Builds the snapshot every copy of user data uses: the manual backup, the
/// automatic continuity snapshot, and the first sync upload.
///
/// Every user state row goes in with each field's HLC, tombstones included
/// so a restore cannot bring back what was deleted since, and with the
/// fields this version keeps as opaque. The catalog does not: a restore
/// fetches feeds again, and `podcastInfo` shows podcasts until then.
class SnapshotExporter {
  SnapshotExporter(this._isar);

  final Isar _isar;

  Future<ExportedSnapshot> export() {
    // One read transaction, so the snapshot is one consistent moment.
    return _isar.txn(() async {
      final opaque = _OpaqueIndex(await _isar.opaqueFields.where().findAll());
      final podcasts = await _isar.podcastUserStates.where().findAll();
      final episodes = await _isar.episodeUserStates.where().findAll();
      final queue = await _isar.queueEntrys.where().findAll();
      final stations = await _isar.stationStates.where().findAll();
      final members = await _isar.stationMembers.where().findAll();
      final settings = await _isar.syncedSettings.where().findAll();
      final keys = {for (final p in podcasts) p.podcastKey};
      final infos =
          (await _isar.subscriptions.filter().podcastKeyIsNotNull().findAll())
              .where((s) => keys.contains(s.podcastKey));

      final sections = <String, List<SnapshotRow>>{};
      void add<T>(EntitySpec<T> spec, Iterable<T> rows) {
        sections[spec.name] = [for (final r in rows) _row(spec, r, opaque)];
      }

      add(UserStateEntities.podcast, podcasts);
      add(UserStateEntities.playOrder, [
        for (final p in podcasts)
          for (final e in p.playOrders) (podcastKey: p.podcastKey, entry: e),
      ]);
      add(UserStateEntities.podcastInfo, _oneEach(infos));
      add(UserStateEntities.episode, episodes);
      add(UserStateEntities.episodeCounter, [
        for (final e in episodes)
          for (final c in e.counters) (episodeKey: e.episodeKey, counters: c),
      ]);
      add(UserStateEntities.queueEntry, queue);
      add(UserStateEntities.station, stations);
      add(UserStateEntities.stationMember, members);
      add(UserStateEntities.setting, settings);
      // Opaque fields of rows this version has no row for, including whole
      // entities it does not know, go in as rows of their own.
      for (final MapEntry(key: (entity, key), value: fields)
          in opaque.leftover.entries) {
        (sections[entity] ??= []).add(SnapshotRow(key, _concat(fields)));
      }

      final meta = await _isar.syncMetas.get(SyncMeta.singletonId);
      return ExportedSnapshot(
        SnapshotBody(sections),
        SnapshotCounts(
          podcasts: podcasts.where((p) => p.subscribed).length,
          episodes: episodes.length,
          queue: queue.where((q) => !q.deleted).length,
          stations: stations.where((s) => !s.deleted).length,
        ),
        meta?.historyId ?? '',
        tombstoneHorizon: meta?.tombstoneHorizon ?? 0,
      );
    });
  }

  static SnapshotRow _row<T>(EntitySpec<T> spec, T row, _OpaqueIndex opaque) {
    final key = spec.key(row);
    final w = ProtoWriter();
    for (final field in spec.fields) {
      w.writeBytes(
        field.id,
        encodeValue(field.value(row), hlc: field.hlc?.call(row)),
      );
    }
    for (final field in opaque.take(spec.name, key)) {
      w.writeRaw(_withHlc(field));
    }
    return SnapshotRow(key, w.takeBytes());
  }

  // Two cached rows can share a key; one describes the podcast well enough.
  static Iterable<Subscription> _oneEach(Iterable<Subscription> subs) {
    final seen = <String>{};
    return subs.where((s) => seen.add(s.podcastKey!));
  }

  static Uint8List _concat(List<OpaqueField> fields) {
    final w = ProtoWriter();
    for (final f in fields) {
      w.writeRaw(_withHlc(f));
    }
    return w.takeBytes();
  }

  /// [field]'s payload with its clock appended to the Value message, so a
  /// restore keeps the newer of two copies. Appending merges into the
  /// message as protobuf defines; a payload that is not a Value goes as is.
  static List<int> _withHlc(OpaqueField field) {
    final parsed = readMessage(Uint8List.fromList(field.payload));
    if (parsed.length != 1 ||
        parsed.single.wireType != WireType.lengthDelimited) {
      return field.payload;
    }
    final value = ProtoWriter()
      ..writeRaw(withoutHlc(parsed.single.raw))
      ..writeRaw(encodeValue(null, hlc: field.hlc));
    return (ProtoWriter()..writeBytes(field.fieldId, value.takeBytes()))
        .takeBytes();
  }
}

/// Opaque fields by (entity, key), handed out once each.
class _OpaqueIndex {
  _OpaqueIndex(List<OpaqueField> fields) {
    for (final f in fields) {
      (leftover[(f.entity, f.key)] ??= []).add(f);
    }
  }

  final Map<(String, String), List<OpaqueField>> leftover = {};

  List<OpaqueField> take(String entity, String key) =>
      leftover.remove((entity, key)) ?? const [];
}
