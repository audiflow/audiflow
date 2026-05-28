// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gate_guard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [GateGuard] singleton used throughout the app to protect
/// restricted actions behind the parental-control PIN entry sheet.

@ProviderFor(gateGuard)
final gateGuardProvider = GateGuardProvider._();

/// Provides the [GateGuard] singleton used throughout the app to protect
/// restricted actions behind the parental-control PIN entry sheet.

final class GateGuardProvider
    extends $FunctionalProvider<GateGuard, GateGuard, GateGuard>
    with $Provider<GateGuard> {
  /// Provides the [GateGuard] singleton used throughout the app to protect
  /// restricted actions behind the parental-control PIN entry sheet.
  GateGuardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gateGuardProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gateGuardHash();

  @$internal
  @override
  $ProviderElement<GateGuard> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GateGuard create(Ref ref) {
    return gateGuard(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GateGuard value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GateGuard>(value),
    );
  }
}

String _$gateGuardHash() => r'511dcbd15eb30a7fa8a90f407f4d6a1eaaab4600';
