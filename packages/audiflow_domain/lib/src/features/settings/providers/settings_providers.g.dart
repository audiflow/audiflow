// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The database holding the synced settings. The app overrides it with
/// the opened database; left null (as in tests that only stub
/// SharedPreferences), every setting stays in SharedPreferences.

@ProviderFor(syncedSettingsIsar)
final syncedSettingsIsarProvider = SyncedSettingsIsarProvider._();

/// The database holding the synced settings. The app overrides it with
/// the opened database; left null (as in tests that only stub
/// SharedPreferences), every setting stays in SharedPreferences.

final class SyncedSettingsIsarProvider
    extends $FunctionalProvider<Isar?, Isar?, Isar?>
    with $Provider<Isar?> {
  /// The database holding the synced settings. The app overrides it with
  /// the opened database; left null (as in tests that only stub
  /// SharedPreferences), every setting stays in SharedPreferences.
  SyncedSettingsIsarProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncedSettingsIsarProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncedSettingsIsarHash();

  @$internal
  @override
  $ProviderElement<Isar?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Isar? create(Ref ref) {
    return syncedSettingsIsar(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Isar? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Isar?>(value),
    );
  }
}

String _$syncedSettingsIsarHash() =>
    r'e43b16f9766e6010c775a1b623e33a871266c7db';

/// Provides a singleton [AppSettingsRepository]: synced settings in Isar,
/// device-scoped ones in SharedPreferences.

@ProviderFor(appSettingsRepository)
final appSettingsRepositoryProvider = AppSettingsRepositoryProvider._();

/// Provides a singleton [AppSettingsRepository]: synced settings in Isar,
/// device-scoped ones in SharedPreferences.

final class AppSettingsRepositoryProvider
    extends
        $FunctionalProvider<
          AppSettingsRepository,
          AppSettingsRepository,
          AppSettingsRepository
        >
    with $Provider<AppSettingsRepository> {
  /// Provides a singleton [AppSettingsRepository]: synced settings in Isar,
  /// device-scoped ones in SharedPreferences.
  AppSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appSettingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appSettingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<AppSettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppSettingsRepository create(Ref ref) {
    return appSettingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppSettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppSettingsRepository>(value),
    );
  }
}

String _$appSettingsRepositoryHash() =>
    r'3e4d2cdef9646eb48edf212f1b63bc4cfd9c7751';
