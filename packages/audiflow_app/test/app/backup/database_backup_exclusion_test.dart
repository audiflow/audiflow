import 'dart:io';

import 'package:audiflow_app/app/backup/database_backup_exclusion.dart';
import 'package:checks/checks.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(DatabaseBackupExclusion.channelName);
  late List<MethodCall> calls;
  late Directory dir;

  void handleChannel(Future<Object?>? Function(MethodCall call)? handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handler);
  }

  setUp(() async {
    calls = [];
    dir = await Directory.systemTemp.createTemp('audiflow_exclude_');
    handleChannel((call) async {
      calls.add(call);
      return null;
    });
  });

  tearDown(() async {
    handleChannel(null);
    await dir.delete(recursive: true);
  });

  DatabaseBackupExclusion exclusion() =>
      DatabaseBackupExclusion(logger: Logger(level: Level.off));

  test('sends the database and its lock file, not the snapshot', () async {
    for (final name in [
      'audiflow.isar',
      'audiflow.isar-lck',
      'continuity.audiflow-backup',
    ]) {
      File('${dir.path}/$name').writeAsStringSync('');
    }

    await exclusion().excludeDatabase(dir.path);

    final call = calls.single;
    check(call.method).equals('exclude');
    final paths = (call.arguments as List<Object?>).cast<String>().toList()
      ..sort();
    check(paths).deepEquals([
      '${dir.path}/audiflow.isar',
      '${dir.path}/audiflow.isar-lck',
    ]);
  });

  test('sends nothing when the database is not there', () async {
    await exclusion().excludeDatabase(dir.path);

    check(calls).isEmpty();
  });

  test('never throws when the native side fails', () async {
    File('${dir.path}/audiflow.isar').writeAsStringSync('');
    handleChannel((_) async => throw PlatformException(code: 'IO'));

    await exclusion().excludeDatabase(dir.path);
  });

  test('never throws when the channel is missing', () async {
    File('${dir.path}/audiflow.isar').writeAsStringSync('');
    handleChannel(null);

    await exclusion().excludeDatabase(dir.path);
  });
}
