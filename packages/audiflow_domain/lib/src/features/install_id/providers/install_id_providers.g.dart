// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'install_id_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deviceOnlyStore)
final deviceOnlyStoreProvider = DeviceOnlyStoreProvider._();

final class DeviceOnlyStoreProvider
    extends
        $FunctionalProvider<DeviceOnlyStore, DeviceOnlyStore, DeviceOnlyStore>
    with $Provider<DeviceOnlyStore> {
  DeviceOnlyStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceOnlyStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceOnlyStoreHash();

  @$internal
  @override
  $ProviderElement<DeviceOnlyStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeviceOnlyStore create(Ref ref) {
    return deviceOnlyStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceOnlyStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceOnlyStore>(value),
    );
  }
}

String _$deviceOnlyStoreHash() => r'28b4d84890a59cac185b0b3dc4671f3cb24aa03c';

@ProviderFor(deviceScopedIdStore)
final deviceScopedIdStoreProvider = DeviceScopedIdStoreProvider._();

final class DeviceScopedIdStoreProvider
    extends
        $FunctionalProvider<
          DeviceScopedIdStore,
          DeviceScopedIdStore,
          DeviceScopedIdStore
        >
    with $Provider<DeviceScopedIdStore> {
  DeviceScopedIdStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceScopedIdStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceScopedIdStoreHash();

  @$internal
  @override
  $ProviderElement<DeviceScopedIdStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeviceScopedIdStore create(Ref ref) {
    return deviceScopedIdStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceScopedIdStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceScopedIdStore>(value),
    );
  }
}

String _$deviceScopedIdStoreHash() =>
    r'be688d710917268c4078ceb53faeadd144b1b400';

@ProviderFor(installIdRepository)
final installIdRepositoryProvider = InstallIdRepositoryProvider._();

final class InstallIdRepositoryProvider
    extends
        $FunctionalProvider<
          InstallIdRepository,
          InstallIdRepository,
          InstallIdRepository
        >
    with $Provider<InstallIdRepository> {
  InstallIdRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'installIdRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$installIdRepositoryHash();

  @$internal
  @override
  $ProviderElement<InstallIdRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InstallIdRepository create(Ref ref) {
    return installIdRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InstallIdRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InstallIdRepository>(value),
    );
  }
}

String _$installIdRepositoryHash() =>
    r'19b013e3f1e0f62bd2bd317e84818c56ea7eee45';

@ProviderFor(deviceIdRepository)
final deviceIdRepositoryProvider = DeviceIdRepositoryProvider._();

final class DeviceIdRepositoryProvider
    extends
        $FunctionalProvider<
          DeviceIdRepository,
          DeviceIdRepository,
          DeviceIdRepository
        >
    with $Provider<DeviceIdRepository> {
  DeviceIdRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceIdRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceIdRepositoryHash();

  @$internal
  @override
  $ProviderElement<DeviceIdRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeviceIdRepository create(Ref ref) {
    return deviceIdRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceIdRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceIdRepository>(value),
    );
  }
}

String _$deviceIdRepositoryHash() =>
    r'552cd494d39b53a3803d79c690cd0af04aeaf5c5';
