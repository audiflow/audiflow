import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;

class _MemoryBackup implements SyncKeyBackup {
  final values = <String, String>{};
  Object? failWith;

  @override
  Future<void> write(String key, String value) async {
    if (failWith case final error?) throw error;
    values[key] = value;
  }

  @override
  Future<Map<String, String>> readAll() async {
    if (failWith case final error?) throw error;
    return Map.of(values);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MemoryBackup backup;
  final errors = <Object>[];

  SecureSyncKeyStore store() => SecureSyncKeyStore(
    backup: backup,
    onBackupError: (e, _) => errors.add(e),
  );

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    backup = _MemoryBackup();
    errors.clear();
  });

  test('credentials are mirrored to the backup', () async {
    final credentials = SyncCredentials.generate();

    await store().writeCredentials(credentials);

    check(backup.values.keys).deepEquals([
      '${SecureSyncKeyStore.credentialsKeyPrefix}${credentials.accountIdText}',
    ]);
  });

  test('a new install reads credentials back from the backup', () async {
    final credentials = SyncCredentials.generate();
    await store().writeCredentials(credentials);
    // As after a reinstall or a move to a new phone: local storage empty.
    FlutterSecureStorage.setMockInitialValues({});

    final fresh = store();

    check(
      await fresh.readCredentials(credentials.accountIdText),
    ).equals(credentials);
    check(await fresh.readLatestCredentials()).equals(credentials);
  });

  test('the latest of local and backed-up credentials wins', () async {
    final a = SyncCredentials.generate();
    final b = SyncCredentials.generate();
    Future<void> tick() =>
        Future<void>.delayed(const Duration(milliseconds: 2));
    await store().writeCredentials(a);
    await tick();
    await store().writeCredentials(b);
    FlutterSecureStorage.setMockInitialValues({});
    await tick();
    // Stored again locally only, after both backed-up writes.
    await SecureSyncKeyStore().writeCredentials(a);

    check(await store().readLatestCredentials()).equals(a);
    check(await store().readCredentials(b.accountIdText)).equals(b);
  });

  test('a failing backup does not fail the write or the read', () async {
    final credentials = SyncCredentials.generate();
    backup.failWith = StateError('no Play services');
    final s = store();

    await s.writeCredentials(credentials);

    check(
      await s.readCredentials(credentials.accountIdText),
    ).equals(credentials);
    check(await s.readLatestCredentials()).equals(credentials);
    // Each failed backup call is reported; none fails the store.
    check(errors).isNotEmpty();
  });

  test('without a backup only local storage is used', () async {
    final credentials = SyncCredentials.generate();
    await SecureSyncKeyStore().writeCredentials(credentials);

    check(
      await SecureSyncKeyStore().readCredentials(credentials.accountIdText),
    ).equals(credentials);
  });

  test('restored credentials are kept locally', () async {
    final credentials = SyncCredentials.generate();
    await store().writeCredentials(credentials);
    FlutterSecureStorage.setMockInitialValues({});

    await store().readCredentials(credentials.accountIdText);
    backup.failWith = StateError('Block Store down');

    check(
      await store().readCredentials(credentials.accountIdText),
    ).equals(credentials);
  });

  test('credentials stored before the backup are mirrored on read', () async {
    final credentials = SyncCredentials.generate();
    await SecureSyncKeyStore().writeCredentials(credentials);
    check(backup.values).isEmpty();

    await store().readCredentials(credentials.accountIdText);

    check(backup.values.keys).deepEquals([
      '${SecureSyncKeyStore.credentialsKeyPrefix}${credentials.accountIdText}',
    ]);
  });
}
