import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MemoryDeviceOnlyStore implements DeviceOnlyStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('InstallIdRepositoryImpl', () {
    test('stores the install id in device-only storage, not prefs', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = _MemoryDeviceOnlyStore();
      final repo = InstallIdRepositoryImpl(
        DeviceScopedIdStore(store, SharedPreferencesDataSource(prefs)),
      );

      final id = await repo.getOrCreate();

      check(id).length.equals(36);
      check(store.values[DeviceScopedIdStore.installIdKey]).equals(id);
      check(prefs.getString('analytics.install_id')).isNull();
    });

    test('differs from the device id', () async {
      final prefs = await SharedPreferences.getInstance();
      final ids = DeviceScopedIdStore(
        _MemoryDeviceOnlyStore(),
        SharedPreferencesDataSource(prefs),
      );

      final installId = await InstallIdRepositoryImpl(ids).getOrCreate();
      final deviceId = await DeviceIdRepositoryImpl(ids).getOrCreate();

      check(installId).not((it) => it.equals(deviceId));
    });
  });
}
