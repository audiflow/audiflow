import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/datasources/shared_preferences_datasource.dart';
import '../../../common/providers/logger_provider.dart';
import '../../../common/providers/platform_providers.dart';
import '../../device_identity/device_id_repository.dart';
import '../../device_identity/services/device_only_store.dart';
import '../../device_identity/services/device_scoped_id_store.dart';
import '../repositories/install_id_repository.dart';
import '../repositories/install_id_repository_impl.dart';

part 'install_id_providers.g.dart';

@Riverpod(keepAlive: true)
DeviceOnlyStore deviceOnlyStore(Ref ref) =>
    const MethodChannelDeviceOnlyStore();

@Riverpod(keepAlive: true)
DeviceScopedIdStore deviceScopedIdStore(Ref ref) => DeviceScopedIdStore(
  ref.watch(deviceOnlyStoreProvider),
  SharedPreferencesDataSource(ref.watch(sharedPreferencesProvider)),
  logger: ref.watch(namedLoggerProvider('DeviceIdentity')),
);

@Riverpod(keepAlive: true)
InstallIdRepository installIdRepository(Ref ref) =>
    InstallIdRepositoryImpl(ref.watch(deviceScopedIdStoreProvider));

@Riverpod(keepAlive: true)
DeviceIdRepository deviceIdRepository(Ref ref) =>
    DeviceIdRepositoryImpl(ref.watch(deviceScopedIdStoreProvider));
