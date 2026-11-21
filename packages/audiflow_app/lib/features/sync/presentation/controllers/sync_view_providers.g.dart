// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_view_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// [SyncController.status], starting with the current value so a screen
/// opened mid-session does not wait for the next change.

@ProviderFor(syncStatus)
final syncStatusProvider = SyncStatusProvider._();

/// [SyncController.status], starting with the current value so a screen
/// opened mid-session does not wait for the next change.

final class SyncStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<SyncStatus>,
          SyncStatus,
          Stream<SyncStatus>
        >
    with $FutureModifier<SyncStatus>, $StreamProvider<SyncStatus> {
  /// [SyncController.status], starting with the current value so a screen
  /// opened mid-session does not wait for the next change.
  SyncStatusProvider._()
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
  String debugGetCreateSourceHash() => _$syncStatusHash();

  @$internal
  @override
  $StreamProviderElement<SyncStatus> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<SyncStatus> create(Ref ref) {
    return syncStatus(ref);
  }
}

String _$syncStatusHash() => r'45f5df086e8b98b2f678d6d0cbdb8d2751d89b8d';

/// The account's devices as the relay last listed them.

@ProviderFor(syncDevices)
final syncDevicesProvider = SyncDevicesProvider._();

/// The account's devices as the relay last listed them.

final class SyncDevicesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SyncDevice>>,
          List<SyncDevice>,
          Stream<List<SyncDevice>>
        >
    with $FutureModifier<List<SyncDevice>>, $StreamProvider<List<SyncDevice>> {
  /// The account's devices as the relay last listed them.
  SyncDevicesProvider._()
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
  String debugGetCreateSourceHash() => _$syncDevicesHash();

  @$internal
  @override
  $StreamProviderElement<List<SyncDevice>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SyncDevice>> create(Ref ref) {
    return syncDevices(ref);
  }
}

String _$syncDevicesHash() => r'81daf6e560dd066e25ff3b157f6931c6320ee815';
