// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_view_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// [SyncController.status] as it changes.

@ProviderFor(SyncStatusNotifier)
final syncStatusProvider = SyncStatusNotifierProvider._();

/// [SyncController.status] as it changes.
final class SyncStatusNotifierProvider
    extends $NotifierProvider<SyncStatusNotifier, SyncStatus> {
  /// [SyncController.status] as it changes.
  SyncStatusNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncStatusNotifierHash();

  @$internal
  @override
  SyncStatusNotifier create() => SyncStatusNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncStatus>(value),
    );
  }
}

String _$syncStatusNotifierHash() =>
    r'ab35807322ffbb5c5e5286d80659a9325367fe10';

/// [SyncController.status] as it changes.

abstract class _$SyncStatusNotifier extends $Notifier<SyncStatus> {
  SyncStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SyncStatus, SyncStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SyncStatus, SyncStatus>,
              SyncStatus,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// The account's devices as the relay last listed them.

@ProviderFor(SyncDevicesNotifier)
final syncDevicesProvider = SyncDevicesNotifierProvider._();

/// The account's devices as the relay last listed them.
final class SyncDevicesNotifierProvider
    extends $NotifierProvider<SyncDevicesNotifier, List<SyncDevice>> {
  /// The account's devices as the relay last listed them.
  SyncDevicesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncDevicesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncDevicesNotifierHash();

  @$internal
  @override
  SyncDevicesNotifier create() => SyncDevicesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SyncDevice> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SyncDevice>>(value),
    );
  }
}

String _$syncDevicesNotifierHash() =>
    r'9779648bb5ee9f3c401b3a58452447118148b663';

/// The account's devices as the relay last listed them.

abstract class _$SyncDevicesNotifier extends $Notifier<List<SyncDevice>> {
  List<SyncDevice> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<SyncDevice>, List<SyncDevice>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<SyncDevice>, List<SyncDevice>>,
              List<SyncDevice>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
