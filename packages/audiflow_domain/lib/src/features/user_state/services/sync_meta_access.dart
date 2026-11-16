import 'dart:convert';
import 'dart:math';

import 'package:isar_community/isar.dart';

import '../models/sync_meta.dart';

/// Creates a random `historyId`: 128 bits, base64url without padding.
String newHistoryId([Random? random]) {
  final source = random ?? Random.secure();
  final bytes = List<int>.generate(16, (_) => source.nextInt(256));
  return base64Url.encode(bytes).replaceAll('=', '');
}

/// Returns the [SyncMeta] row, creating it with a new history when missing.
///
/// Must run inside a write transaction. A missing row means this database
/// holds no lineage yet: a first launch, or the first write after "Reset
/// All Data" cleared every collection, so a new history starts here.
Future<SyncMeta> loadOrCreateSyncMeta(
  Isar isar, {
  String Function()? createHistoryId,
}) async {
  final existing = await isar.syncMetas.get(SyncMeta.singletonId);
  if (existing != null) return existing;
  final created = SyncMeta()..historyId = (createHistoryId ?? newHistoryId)();
  await isar.syncMetas.put(created);
  return created;
}
