// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'force_update_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Endpoint that serves the force-update JSON.
///
/// Override at the composition root with
/// `String.fromEnvironment('FORCE_UPDATE_CONFIG_URL')`. Throwing by
/// default surfaces missing overrides during boot instead of failing
/// silently later.

@ProviderFor(forceUpdateConfigUrl)
final forceUpdateConfigUrlProvider = ForceUpdateConfigUrlProvider._();

/// Endpoint that serves the force-update JSON.
///
/// Override at the composition root with
/// `String.fromEnvironment('FORCE_UPDATE_CONFIG_URL')`. Throwing by
/// default surfaces missing overrides during boot instead of failing
/// silently later.

final class ForceUpdateConfigUrlProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Endpoint that serves the force-update JSON.
  ///
  /// Override at the composition root with
  /// `String.fromEnvironment('FORCE_UPDATE_CONFIG_URL')`. Throwing by
  /// default surfaces missing overrides during boot instead of failing
  /// silently later.
  ForceUpdateConfigUrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forceUpdateConfigUrlProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forceUpdateConfigUrlHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return forceUpdateConfigUrl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$forceUpdateConfigUrlHash() =>
    r'ec3b98d6a7eb009078e793f286854640c8b5ef19';

/// Singleton [ForceUpdateRepository] wired to the shared Dio + prefs.

@ProviderFor(forceUpdateRepository)
final forceUpdateRepositoryProvider = ForceUpdateRepositoryProvider._();

/// Singleton [ForceUpdateRepository] wired to the shared Dio + prefs.

final class ForceUpdateRepositoryProvider
    extends
        $FunctionalProvider<
          ForceUpdateRepository,
          ForceUpdateRepository,
          ForceUpdateRepository
        >
    with $Provider<ForceUpdateRepository> {
  /// Singleton [ForceUpdateRepository] wired to the shared Dio + prefs.
  ForceUpdateRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forceUpdateRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forceUpdateRepositoryHash();

  @$internal
  @override
  $ProviderElement<ForceUpdateRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ForceUpdateRepository create(Ref ref) {
    return forceUpdateRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ForceUpdateRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ForceUpdateRepository>(value),
    );
  }
}

String _$forceUpdateRepositoryHash() =>
    r'70c9b1cfedc1d966025a1efb533a80f032a7c8e0';
