// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parental_control_gate.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the parental-control session state machine.
///
/// States: [Locked] → [Unlocked] (on correct PIN) → [Locked] (on idle timeout
/// or explicit lock). Too many wrong PINs in a window → [LockedOut].

@ProviderFor(ParentalControlGate)
final parentalControlGateProvider = ParentalControlGateProvider._();

/// Manages the parental-control session state machine.
///
/// States: [Locked] → [Unlocked] (on correct PIN) → [Locked] (on idle timeout
/// or explicit lock). Too many wrong PINs in a window → [LockedOut].
final class ParentalControlGateProvider
    extends $NotifierProvider<ParentalControlGate, UnlockState> {
  /// Manages the parental-control session state machine.
  ///
  /// States: [Locked] → [Unlocked] (on correct PIN) → [Locked] (on idle timeout
  /// or explicit lock). Too many wrong PINs in a window → [LockedOut].
  ParentalControlGateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parentalControlGateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parentalControlGateHash();

  @$internal
  @override
  ParentalControlGate create() => ParentalControlGate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UnlockState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UnlockState>(value),
    );
  }
}

String _$parentalControlGateHash() =>
    r'f0f9a8e45dca4b3ec9f9d5e5db09ed071291dbb0';

/// Manages the parental-control session state machine.
///
/// States: [Locked] → [Unlocked] (on correct PIN) → [Locked] (on idle timeout
/// or explicit lock). Too many wrong PINs in a window → [LockedOut].

abstract class _$ParentalControlGate extends $Notifier<UnlockState> {
  UnlockState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<UnlockState, UnlockState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UnlockState, UnlockState>,
              UnlockState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
