import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeDeviceOnlyStore implements DeviceOnlyStore {
  final values = <String, String>{};
  bool fail = false;

  @override
  Future<String?> read(String key) async {
    if (fail) throw PlatformException(code: 'KEYCHAIN');
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    if (fail) throw PlatformException(code: 'KEYCHAIN');
    values[key] = value;
  }
}

void main() {
  late _FakeDeviceOnlyStore store;

  setUp(() {
    store = _FakeDeviceOnlyStore();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<DeviceScopedIdStore> build() async => DeviceScopedIdStore(
    store,
    SharedPreferencesDataSource(await SharedPreferences.getInstance()),
  );

  group('DeviceScopedIdStore', () {
    test('generates an id into device-only storage', () async {
      final ids = await build();

      final id = await ids.getOrCreate(DeviceScopedIdStore.deviceIdKey);

      check(id).length.equals(36);
      check(store.values[DeviceScopedIdStore.deviceIdKey]).equals(id);
    });

    test('returns the stored id on later calls and launches', () async {
      final first = await (await build()).getOrCreate(
        DeviceScopedIdStore.deviceIdKey,
      );

      final second = await (await build()).getOrCreate(
        DeviceScopedIdStore.deviceIdKey,
      );

      check(second).equals(first);
    });

    test('keeps install id and device id distinct', () async {
      final ids = await build();

      final installId = await ids.getOrCreate(DeviceScopedIdStore.installIdKey);
      final deviceId = await ids.getOrCreate(DeviceScopedIdStore.deviceIdKey);

      check(installId).not((it) => it.equals(deviceId));
    });

    test(
      'a restored copy of preferences on a new device gets new ids',
      () async {
        // Old device: ids generated, marker written to preferences.
        final old = await (await build()).getOrCreate(
          DeviceScopedIdStore.deviceIdKey,
        );
        // New device: preferences come back from the backup, device-only
        // storage does not.
        store.values.clear();

        final restored = await (await build()).getOrCreate(
          DeviceScopedIdStore.deviceIdKey,
        );

        check(restored).not((it) => it.equals(old));
      },
    );

    test('a value left by a previous install is not reused', () async {
      // iOS keeps Keychain items after the app is deleted, while
      // preferences go with the app.
      store.values[DeviceScopedIdStore.deviceIdKey] = 'previous-install';

      final id = await (await build()).getOrCreate(
        DeviceScopedIdStore.deviceIdKey,
      );

      check(id).not((it) => it.equals('previous-install'));
      check(store.values[DeviceScopedIdStore.deviceIdKey]).equals(id);
    });

    test('a data reset, which clears preferences, rotates ids', () async {
      final before = await (await build()).getOrCreate(
        DeviceScopedIdStore.installIdKey,
      );
      await (await SharedPreferences.getInstance()).clear();

      final after = await (await build()).getOrCreate(
        DeviceScopedIdStore.installIdKey,
      );

      check(after).not((it) => it.equals(before));
    });

    test('adopts and removes the legacy install id from preferences', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'analytics.install_id': 'legacy-id',
      });

      final id = await (await build()).getOrCreate(
        DeviceScopedIdStore.installIdKey,
      );

      check(id).equals('legacy-id');
      check(store.values[DeviceScopedIdStore.installIdKey]).equals('legacy-id');
      final prefs = await SharedPreferences.getInstance();
      check(prefs.getString('analytics.install_id')).isNull();
    });

    test('concurrent first calls agree on one id', () async {
      final ids = await build();

      final results = await Future.wait([
        ids.getOrCreate(DeviceScopedIdStore.deviceIdKey),
        ids.getOrCreate(DeviceScopedIdStore.deviceIdKey),
      ]);

      check(results[1]).equals(results[0]);
    });

    test('falls back to a session-only id when storage fails', () async {
      store.fail = true;
      final ids = await build();

      final first = await ids.getOrCreate(DeviceScopedIdStore.deviceIdKey);
      final second = await ids.getOrCreate(DeviceScopedIdStore.deviceIdKey);

      check(first).length.equals(36);
      check(second).equals(first);
    });

    test('falls back to the legacy install id when storage fails', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'analytics.install_id': 'legacy-id',
      });
      store.fail = true;

      final id = await (await build()).getOrCreate(
        DeviceScopedIdStore.installIdKey,
      );

      check(id).equals('legacy-id');
      final prefs = await SharedPreferences.getInstance();
      check(prefs.getString('analytics.install_id')).equals('legacy-id');
    });
  });
}
