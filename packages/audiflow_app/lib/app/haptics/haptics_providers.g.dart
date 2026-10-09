// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'haptics_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controls the user's haptic feedback level (on, reduced, off).

@ProviderFor(HapticFeedbackLevelController)
final hapticFeedbackLevelControllerProvider =
    HapticFeedbackLevelControllerProvider._();

/// Controls the user's haptic feedback level (on, reduced, off).
final class HapticFeedbackLevelControllerProvider
    extends
        $NotifierProvider<HapticFeedbackLevelController, HapticFeedbackLevel> {
  /// Controls the user's haptic feedback level (on, reduced, off).
  HapticFeedbackLevelControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hapticFeedbackLevelControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hapticFeedbackLevelControllerHash();

  @$internal
  @override
  HapticFeedbackLevelController create() => HapticFeedbackLevelController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HapticFeedbackLevel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HapticFeedbackLevel>(value),
    );
  }
}

String _$hapticFeedbackLevelControllerHash() =>
    r'c1157d9df899641d2a4d8766d2691bf2f3c952ba';

/// Controls the user's haptic feedback level (on, reduced, off).

abstract class _$HapticFeedbackLevelController
    extends $Notifier<HapticFeedbackLevel> {
  HapticFeedbackLevel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<HapticFeedbackLevel, HapticFeedbackLevel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HapticFeedbackLevel, HapticFeedbackLevel>,
              HapticFeedbackLevel,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// The native haptic player, before the user's level is applied.

@ProviderFor(platformHapticPlayer)
final platformHapticPlayerProvider = PlatformHapticPlayerProvider._();

/// The native haptic player, before the user's level is applied.

final class PlatformHapticPlayerProvider
    extends $FunctionalProvider<HapticPlayer, HapticPlayer, HapticPlayer>
    with $Provider<HapticPlayer> {
  /// The native haptic player, before the user's level is applied.
  PlatformHapticPlayerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'platformHapticPlayerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$platformHapticPlayerHash();

  @$internal
  @override
  $ProviderElement<HapticPlayer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HapticPlayer create(Ref ref) {
    return platformHapticPlayer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HapticPlayer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HapticPlayer>(value),
    );
  }
}

String _$platformHapticPlayerHash() =>
    r'236fc3666a3bc70aa2f62b6fc042e2af58bea908';

/// Whether the device has haptic hardware. Asked once per launch.

@ProviderFor(hapticsSupported)
final hapticsSupportedProvider = HapticsSupportedProvider._();

/// Whether the device has haptic hardware. Asked once per launch.

final class HapticsSupportedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the device has haptic hardware. Asked once per launch.
  HapticsSupportedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hapticsSupportedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hapticsSupportedHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return hapticsSupported(ref);
  }
}

String _$hapticsSupportedHash() => r'af25bb85024423e413bccbb38130eb1eb72dae5a';

/// The level in effect: the user's choice, or off on a device without
/// haptics. Assumes support until the device answers.

@ProviderFor(effectiveHapticFeedbackLevel)
final effectiveHapticFeedbackLevelProvider =
    EffectiveHapticFeedbackLevelProvider._();

/// The level in effect: the user's choice, or off on a device without
/// haptics. Assumes support until the device answers.

final class EffectiveHapticFeedbackLevelProvider
    extends
        $FunctionalProvider<
          HapticFeedbackLevel,
          HapticFeedbackLevel,
          HapticFeedbackLevel
        >
    with $Provider<HapticFeedbackLevel> {
  /// The level in effect: the user's choice, or off on a device without
  /// haptics. Assumes support until the device answers.
  EffectiveHapticFeedbackLevelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effectiveHapticFeedbackLevelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effectiveHapticFeedbackLevelHash();

  @$internal
  @override
  $ProviderElement<HapticFeedbackLevel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HapticFeedbackLevel create(Ref ref) {
    return effectiveHapticFeedbackLevel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HapticFeedbackLevel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HapticFeedbackLevel>(value),
    );
  }
}

String _$effectiveHapticFeedbackLevelHash() =>
    r'7ecd75f98d446b72d948fad9ddd6c23326bf6e3d';

/// The player the app injects into `HapticsScope`, gated by the effective
/// level. Rebuilds when the level changes.

@ProviderFor(hapticPlayer)
final hapticPlayerProvider = HapticPlayerProvider._();

/// The player the app injects into `HapticsScope`, gated by the effective
/// level. Rebuilds when the level changes.

final class HapticPlayerProvider
    extends $FunctionalProvider<HapticPlayer, HapticPlayer, HapticPlayer>
    with $Provider<HapticPlayer> {
  /// The player the app injects into `HapticsScope`, gated by the effective
  /// level. Rebuilds when the level changes.
  HapticPlayerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hapticPlayerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hapticPlayerHash();

  @$internal
  @override
  $ProviderElement<HapticPlayer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HapticPlayer create(Ref ref) {
    return hapticPlayer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HapticPlayer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HapticPlayer>(value),
    );
  }
}

String _$hapticPlayerHash() => r'a7b5413b512cff4f5f16f5ce08d03164b0b15df8';
