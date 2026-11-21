import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;

void main() {
  test('a stored device round-trips', () async {
    final pair = await DeviceKeyPair.generate();
    final device = StoredSyncDevice(
      accountId: 'acct',
      deviceId: 'd1',
      name: 'Phone',
      platform: 'ios',
      privateKey: pair.privateKey,
      token: 'tok',
      dataKey: DataKey(SyncCipher.generateKey(), version: 3),
    );

    final back = StoredSyncDevice.decode(device.encode());

    check(back.deviceId).equals('d1');
    check(back.accountId).equals('acct');
    check(back.privateKey).deepEquals(pair.privateKey);
    check(back.token).equals('tok');
    check(back.dataKey!.version).equals(3);
    check(back.dataKey!.key).deepEquals(device.dataKey!.key);
    check((await back.toSyncDevice()).publicKey).deepEquals(pair.publicKey);
  });

  test('a device before enrollment has no token or data key', () async {
    final device = StoredSyncDevice(
      accountId: 'acct',
      deviceId: 'd1',
      name: 'Phone',
      platform: 'android',
      privateKey: (await DeviceKeyPair.generate()).privateKey,
    );

    final back = StoredSyncDevice.decode(device.encode());

    check(back.token).isNull();
    check(back.dataKey).isNull();
  });

  test('a pending opening survives the round trip', () async {
    final device = StoredSyncDevice(
      accountId: 'acct',
      deviceId: 'd1',
      name: 'Phone',
      platform: 'ios',
      privateKey: (await DeviceKeyPair.generate()).privateKey,
      pendingOpening: SyncOpening.create,
    );

    final back = StoredSyncDevice.decode(device.encode());

    check(back.pendingOpening).equals(SyncOpening.create);
    check(back.enrolled(token: 't').pendingOpening).isNull();
  });

  test('a private key of the wrong length is a format error', () {
    check(
      () => StoredSyncDevice(
        accountId: 'acct',
        deviceId: 'd1',
        name: 'Phone',
        platform: 'ios',
        privateKey: const [],
      ),
    ).throws<FormatException>();
  });

  test('anything else is a format error', () {
    check(() => StoredSyncDevice.decode('[]')).throws<FormatException>();
    check(
      () => StoredSyncDevice.decode('{"deviceId":1}'),
    ).throws<FormatException>();
  });

  test('toString keeps the secrets out', () async {
    final device = StoredSyncDevice(
      accountId: 'acct',
      deviceId: 'd1',
      name: 'Phone',
      platform: 'ios',
      privateKey: (await DeviceKeyPair.generate()).privateKey,
      token: 'secret-token',
    );
    check('$device').not((it) => it.contains('secret-token'));
  });
}
