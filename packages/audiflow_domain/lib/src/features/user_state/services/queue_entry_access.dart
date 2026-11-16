import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../../common/providers/logger_provider.dart';
import '../../feed/models/episode.dart';
import '../../queue/models/queue_item.dart';
import '../models/queue_entry.dart';
import 'user_state_store.dart';

/// Keeps [QueueEntry] in step with the `QueueItem` rows the queue reads.
///
/// Every queue write goes through [save] or [remove] in the same
/// [UserStateStore.write]. An item whose episode has no stable key yet gets
/// no entry until the episode is keyed ([copyLegacy]).
class QueueEntryAccess {
  QueueEntryAccess(this._isar, {Logger? logger, Uuid? uuid})
    : _logger = logger ?? _compareLogger,
      _uuid = uuid ?? const Uuid();

  final Isar _isar;
  final Logger _logger;
  final Uuid _uuid;

  static final _compareLogger = NamedLogger('UserStateCompare');

  /// Gives [items] their entry ids, puts them, and records each on its
  /// entry. Must run inside [UserStateStore.write].
  Future<void> saveAll(List<QueueItem> items, UserStateTxn txn) async {
    if (items.isEmpty) return;
    final keys = await _episodeKeys(items);
    for (final item in items) {
      if (keys[item.episodeId] != null) item.entryId ??= _uuid.v7();
    }
    await _isar.queueItems.putAll(items);
    for (final item in items) {
      final key = keys[item.episodeId];
      if (key == null) continue;
      await _record(item, key, txn);
    }
  }

  /// Marks the entries of [items] removed; the caller deletes the rows.
  /// Must run inside [UserStateStore.write].
  Future<void> removeAll(List<QueueItem> items, UserStateTxn txn) async {
    final stamp = txn.stamp.packed;
    for (final item in items) {
      final entryId = item.entryId;
      if (entryId == null) continue;
      final entry = await _isar.queueEntrys.getByEntryId(entryId);
      if (entry == null || entry.deleted) continue;
      await _isar.queueEntrys.put(
        entry
          ..deleted = true
          ..deletedHlc = stamp,
      );
    }
  }

  /// Gives the queue items of [episode] their entries, now that it has a
  /// key. Idempotent; must run inside [UserStateStore.write].
  Future<void> copyLegacy(Episode episode, UserStateTxn txn) async {
    if (episode.episodeKey == null) return;
    final items = await _isar.queueItems
        .filter()
        .episodeIdEqualTo(episode.id)
        .findAll();
    final missing = <QueueItem>[];
    for (final item in items) {
      final entryId = item.entryId;
      if (entryId != null &&
          await _isar.queueEntrys.getByEntryId(entryId) != null) {
        continue;
      }
      missing.add(item);
    }
    await saveAll(missing, txn);
  }

  /// Logs, in debug builds, when the live entries differ from [items].
  Future<void> compare(List<QueueItem> items) async {
    if (!kDebugMode) return;
    final entries = await _isar.queueEntrys
        .filter()
        .deletedEqualTo(false)
        .findAll();
    final expected = {
      for (final item in items)
        if (item.entryId != null) item.entryId!: describeItem(item),
    };
    final actual = {for (final e in entries) e.entryId: describeEntry(e)};
    if (mapEquals(expected, actual)) return;
    _logger.w('QueueEntry differs from QueueItem: old $expected, new $actual');
  }

  Future<Map<int, String?>> _episodeKeys(List<QueueItem> items) async {
    final ids = {for (final item in items) item.episodeId}.toList();
    final episodes = await _isar.episodes.getAll(ids);
    return {
      for (var i = 0; i < ids.length; i++) ids[i]: episodes[i]?.episodeKey,
    };
  }

  Future<void> _record(QueueItem item, String key, UserStateTxn txn) async {
    final entryId = item.entryId!;
    final entry =
        await _isar.queueEntrys.getByEntryId(entryId) ??
        (QueueEntry()
          ..entryId = entryId
          ..episodeKey = key
          ..addedAt = item.addedAt);
    if (applyItem(entry, item, txn)) await _isar.queueEntrys.put(entry);
  }
}

/// Records [item] on [entry], stamping what changed. Returns whether
/// anything changed.
bool applyItem(QueueEntry entry, QueueItem item, UserStateTxn txn) {
  final stamp = txn.stamp.packed;
  var changed = entry.id == Isar.autoIncrement;
  final rank = rankForPosition(item.position);
  if (entry.rank != rank) {
    entry
      ..rank = rank
      ..rankHlc = stamp;
    changed = true;
  }
  if (entry.isAdhoc != item.isAdhoc || entry.isAdhocHlc == 0) {
    entry
      ..isAdhoc = item.isAdhoc
      ..isAdhocHlc = stamp;
    changed = true;
  }
  if (entry.sourceContext != item.sourceContext) {
    entry
      ..sourceContext = item.sourceContext
      ..sourceContextHlc = stamp;
    changed = true;
  }
  if (entry.deleted) {
    entry
      ..deleted = false
      ..deletedHlc = stamp;
    changed = true;
  }
  return changed;
}

// Positions are offset by 2^52 into a non-negative range, which 11 base-36
// digits hold, so equal-length strings compare like the numbers.
const _rankOffset = 4503599627370496;
const _rankWidth = 11;

/// A sort key for [position] whose string order is the numeric order.
String rankForPosition(int position) =>
    (position + _rankOffset).toRadixString(36).padLeft(_rankWidth, '0');

String describeItem(QueueItem item) =>
    '${rankForPosition(item.position)}|${item.isAdhoc}|${item.sourceContext}';

String describeEntry(QueueEntry entry) =>
    '${entry.rank}|${entry.isAdhoc}|${entry.sourceContext}';
