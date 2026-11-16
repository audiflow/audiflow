import 'services/device_scoped_id_store.dart';

/// Identity of this device among the user's devices, used by sync and by
/// restore detection (docs/architecture/user-data-sync.md).
///
/// Never backed up and never migrated: a restored or migrated device gets
/// a new one, which is how it tells itself apart from the device the data
/// came from.
abstract interface class DeviceIdRepository {
  /// Returns this device's id, generating and storing one on first call.
  Future<String> getOrCreate();
}

class DeviceIdRepositoryImpl implements DeviceIdRepository {
  DeviceIdRepositoryImpl(this._ids);

  final DeviceScopedIdStore _ids;

  @override
  Future<String> getOrCreate() =>
      _ids.getOrCreate(DeviceScopedIdStore.deviceIdKey);
}
