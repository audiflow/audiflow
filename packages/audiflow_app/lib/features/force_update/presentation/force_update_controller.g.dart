// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'force_update_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Running app's semver, derived from [PackageInfo.version].
///
/// `package_info_plus` returns the manifest version (e.g. `2.0.0`).
/// We trim any trailing `+build` qualifier some platforms include.

@ProviderFor(currentAppVersion)
final currentAppVersionProvider = CurrentAppVersionProvider._();

/// Running app's semver, derived from [PackageInfo.version].
///
/// `package_info_plus` returns the manifest version (e.g. `2.0.0`).
/// We trim any trailing `+build` qualifier some platforms include.

final class CurrentAppVersionProvider
    extends $FunctionalProvider<AsyncValue<Version>, Version, FutureOr<Version>>
    with $FutureModifier<Version>, $FutureProvider<Version> {
  /// Running app's semver, derived from [PackageInfo.version].
  ///
  /// `package_info_plus` returns the manifest version (e.g. `2.0.0`).
  /// We trim any trailing `+build` qualifier some platforms include.
  CurrentAppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentAppVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentAppVersionHash();

  @$internal
  @override
  $FutureProviderElement<Version> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Version> create(Ref ref) {
    return currentAppVersion(ref);
  }
}

String _$currentAppVersionHash() => r'4011c21b5d47a0c96c1ac97dc92405b588930a07';

/// AsyncNotifier exposing the current [UpdateDecision].
///
/// Cold-start strategy:
/// 1. Read the cached config synchronously; emit a decision derived
///    from it (or [NoUpdate] when no cache exists yet) so the gate
///    can render without a network round-trip.
/// 2. Kick off a background refresh; once it completes the notifier
///    re-emits with the fresh decision.
///
/// [refresh] re-runs the network fetch on demand (used by the gate's
/// lifecycle observer and the maintenance retry button). Failures keep
/// the existing decision via the repository's fail-open contract.

@ProviderFor(ForceUpdateController)
final forceUpdateControllerProvider = ForceUpdateControllerProvider._();

/// AsyncNotifier exposing the current [UpdateDecision].
///
/// Cold-start strategy:
/// 1. Read the cached config synchronously; emit a decision derived
///    from it (or [NoUpdate] when no cache exists yet) so the gate
///    can render without a network round-trip.
/// 2. Kick off a background refresh; once it completes the notifier
///    re-emits with the fresh decision.
///
/// [refresh] re-runs the network fetch on demand (used by the gate's
/// lifecycle observer and the maintenance retry button). Failures keep
/// the existing decision via the repository's fail-open contract.
final class ForceUpdateControllerProvider
    extends $AsyncNotifierProvider<ForceUpdateController, UpdateDecision> {
  /// AsyncNotifier exposing the current [UpdateDecision].
  ///
  /// Cold-start strategy:
  /// 1. Read the cached config synchronously; emit a decision derived
  ///    from it (or [NoUpdate] when no cache exists yet) so the gate
  ///    can render without a network round-trip.
  /// 2. Kick off a background refresh; once it completes the notifier
  ///    re-emits with the fresh decision.
  ///
  /// [refresh] re-runs the network fetch on demand (used by the gate's
  /// lifecycle observer and the maintenance retry button). Failures keep
  /// the existing decision via the repository's fail-open contract.
  ForceUpdateControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forceUpdateControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forceUpdateControllerHash();

  @$internal
  @override
  ForceUpdateController create() => ForceUpdateController();
}

String _$forceUpdateControllerHash() =>
    r'd00302ccb4373b02597e851f53c21956b19b921e';

/// AsyncNotifier exposing the current [UpdateDecision].
///
/// Cold-start strategy:
/// 1. Read the cached config synchronously; emit a decision derived
///    from it (or [NoUpdate] when no cache exists yet) so the gate
///    can render without a network round-trip.
/// 2. Kick off a background refresh; once it completes the notifier
///    re-emits with the fresh decision.
///
/// [refresh] re-runs the network fetch on demand (used by the gate's
/// lifecycle observer and the maintenance retry button). Failures keep
/// the existing decision via the repository's fail-open contract.

abstract class _$ForceUpdateController extends $AsyncNotifier<UpdateDecision> {
  FutureOr<UpdateDecision> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UpdateDecision>, UpdateDecision>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UpdateDecision>, UpdateDecision>,
              AsyncValue<UpdateDecision>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
