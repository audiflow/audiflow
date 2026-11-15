import '../../device_identity/services/device_scoped_id_store.dart';
import 'install_id_repository.dart';

/// Keeps the install id in device-only storage, so a backup restored on a
/// new device does not carry it over (docs/architecture/user-data-sync.md).
class InstallIdRepositoryImpl implements InstallIdRepository {
  InstallIdRepositoryImpl(this._ids);

  final DeviceScopedIdStore _ids;

  @override
  Future<String> getOrCreate() =>
      _ids.getOrCreate(DeviceScopedIdStore.installIdKey);
}
