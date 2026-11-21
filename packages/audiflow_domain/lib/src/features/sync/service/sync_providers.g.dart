// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The relay this build syncs with, or null.

@ProviderFor(syncRelayUrl)
final syncRelayUrlProvider = SyncRelayUrlProvider._();

/// The relay this build syncs with, or null.

final class SyncRelayUrlProvider extends $FunctionalProvider<Uri?, Uri?, Uri?>
    with $Provider<Uri?> {
  /// The relay this build syncs with, or null.
  SyncRelayUrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncRelayUrlProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncRelayUrlHash();

  @$internal
  @override
  $ProviderElement<Uri?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Uri? create(Ref ref) {
    return syncRelayUrl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Uri? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Uri?>(value),
    );
  }
}

String _$syncRelayUrlHash() => r'b8a2ea5d44cd960a50162543a27226e71842f0c7';

@ProviderFor(syncKeyStore)
final syncKeyStoreProvider = SyncKeyStoreProvider._();

final class SyncKeyStoreProvider
    extends $FunctionalProvider<SyncKeyStore, SyncKeyStore, SyncKeyStore>
    with $Provider<SyncKeyStore> {
  SyncKeyStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncKeyStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncKeyStoreHash();

  @$internal
  @override
  $ProviderElement<SyncKeyStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncKeyStore create(Ref ref) {
    return syncKeyStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncKeyStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncKeyStore>(value),
    );
  }
}

String _$syncKeyStoreHash() => r'560b646a637d93f7de5155a309a0f53c5af50065';

/// The app's [SyncController]. The app calls `load` at startup and
/// `setActive` as it moves between foreground, playing, and background.

@ProviderFor(syncController)
final syncControllerProvider = SyncControllerProvider._();

/// The app's [SyncController]. The app calls `load` at startup and
/// `setActive` as it moves between foreground, playing, and background.

final class SyncControllerProvider
    extends $FunctionalProvider<SyncController, SyncController, SyncController>
    with $Provider<SyncController> {
  /// The app's [SyncController]. The app calls `load` at startup and
  /// `setActive` as it moves between foreground, playing, and background.
  SyncControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncControllerHash();

  @$internal
  @override
  $ProviderElement<SyncController> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncController create(Ref ref) {
    return syncController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncController>(value),
    );
  }
}

String _$syncControllerHash() => r'f113108b20bb2d0c21dab63c6b73d9cc9cafdb2e';
