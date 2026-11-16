import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:isar_community/isar.dart';

/// Opens an Isar instance in a system temp directory to avoid
/// leftover `.isar-lck` files in the project root.
///
/// [SyncMetaSchema] is always included: every user state write goes
/// through `UserStateStore`, which keeps its clock there.
Future<Isar> openTestIsar(List<CollectionSchema<dynamic>> schemas) async {
  final dir = await Directory.systemTemp.createTemp('audiflow_isar_test_');
  return Isar.open(
    {...schemas, SyncMetaSchema}.toList(),
    directory: dir.path,
    name: 'test_${DateTime.now().microsecondsSinceEpoch}',
  );
}
