import 'dart:io';

import 'package:isar_community/isar.dart';

/// Opens an Isar instance in a system temp directory to avoid
/// leftover `.isar-lck` files in the project root.
Future<Isar> openTestIsar(List<CollectionSchema<dynamic>> schemas) async {
  final dir = await Directory.systemTemp.createTemp('audiflow_isar_test_');
  return Isar.open(
    schemas,
    directory: dir.path,
    name: 'test_${DateTime.now().microsecondsSinceEpoch}',
  );
}
