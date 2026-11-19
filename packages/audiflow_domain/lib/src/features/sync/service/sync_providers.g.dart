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

@ProviderFor(syncSecretStore)
final syncSecretStoreProvider = SyncSecretStoreProvider._();

final class SyncSecretStoreProvider
    extends
        $FunctionalProvider<SyncSecretStore, SyncSecretStore, SyncSecretStore>
    with $Provider<SyncSecretStore> {
  SyncSecretStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncSecretStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncSecretStoreHash();

  @$internal
  @override
  $ProviderElement<SyncSecretStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncSecretStore create(Ref ref) {
    return syncSecretStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncSecretStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncSecretStore>(value),
    );
  }
}

String _$syncSecretStoreHash() => r'bace6ad6e935a2c401c9eefcd24b984cb9765d4d';

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

String _$syncControllerHash() => r'36dcc3ffda889c97a5caa1000385d693f43521c1';
