// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parental_control_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [ParentalControlErrorSink] used by the repository for
/// non-fatal storage failure reporting (e.g. Sentry in production).
///
/// Default is a no-op so tests and plain domain unit-tests need no override.

@ProviderFor(parentalControlErrorSink)
final parentalControlErrorSinkProvider = ParentalControlErrorSinkProvider._();

/// Provides the [ParentalControlErrorSink] used by the repository for
/// non-fatal storage failure reporting (e.g. Sentry in production).
///
/// Default is a no-op so tests and plain domain unit-tests need no override.

final class ParentalControlErrorSinkProvider
    extends
        $FunctionalProvider<
          ParentalControlErrorSink,
          ParentalControlErrorSink,
          ParentalControlErrorSink
        >
    with $Provider<ParentalControlErrorSink> {
  /// Provides the [ParentalControlErrorSink] used by the repository for
  /// non-fatal storage failure reporting (e.g. Sentry in production).
  ///
  /// Default is a no-op so tests and plain domain unit-tests need no override.
  ParentalControlErrorSinkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parentalControlErrorSinkProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parentalControlErrorSinkHash();

  @$internal
  @override
  $ProviderElement<ParentalControlErrorSink> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ParentalControlErrorSink create(Ref ref) {
    return parentalControlErrorSink(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ParentalControlErrorSink value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ParentalControlErrorSink>(value),
    );
  }
}

String _$parentalControlErrorSinkHash() =>
    r'7a001bb9700cf6704d291ff48cc484067ebf838d';

/// Provides the [PinHasher] singleton used for all PIN hash and verify calls.

@ProviderFor(pinHasher)
final pinHasherProvider = PinHasherProvider._();

/// Provides the [PinHasher] singleton used for all PIN hash and verify calls.

final class PinHasherProvider
    extends $FunctionalProvider<PinHasher, PinHasher, PinHasher>
    with $Provider<PinHasher> {
  /// Provides the [PinHasher] singleton used for all PIN hash and verify calls.
  PinHasherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pinHasherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pinHasherHash();

  @$internal
  @override
  $ProviderElement<PinHasher> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PinHasher create(Ref ref) {
    return pinHasher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PinHasher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PinHasher>(value),
    );
  }
}

String _$pinHasherHash() => r'9c7e1e693faf28e145da2e1c378651424c432b3c';

/// Provides the platform [BiometricAuthenticator] implementation.
///
/// Default throws so any caller in a pure-domain test must install an explicit
/// fake. The host app overrides this at the root `ProviderContainer` with a
/// `local_auth`-backed implementation; the same override is used in widget
/// tests via a fake.

@ProviderFor(biometricAuthenticator)
final biometricAuthenticatorProvider = BiometricAuthenticatorProvider._();

/// Provides the platform [BiometricAuthenticator] implementation.
///
/// Default throws so any caller in a pure-domain test must install an explicit
/// fake. The host app overrides this at the root `ProviderContainer` with a
/// `local_auth`-backed implementation; the same override is used in widget
/// tests via a fake.

final class BiometricAuthenticatorProvider
    extends
        $FunctionalProvider<
          BiometricAuthenticator,
          BiometricAuthenticator,
          BiometricAuthenticator
        >
    with $Provider<BiometricAuthenticator> {
  /// Provides the platform [BiometricAuthenticator] implementation.
  ///
  /// Default throws so any caller in a pure-domain test must install an explicit
  /// fake. The host app overrides this at the root `ProviderContainer` with a
  /// `local_auth`-backed implementation; the same override is used in widget
  /// tests via a fake.
  BiometricAuthenticatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biometricAuthenticatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biometricAuthenticatorHash();

  @$internal
  @override
  $ProviderElement<BiometricAuthenticator> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BiometricAuthenticator create(Ref ref) {
    return biometricAuthenticator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BiometricAuthenticator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BiometricAuthenticator>(value),
    );
  }
}

String _$biometricAuthenticatorHash() =>
    r'3c3219ee06cc82ea3d435d86dfdd6f54aa6808fd';

/// Provides the local data source backed by Isar for parental-control storage.

@ProviderFor(parentalControlLocalDataSource)
final parentalControlLocalDataSourceProvider =
    ParentalControlLocalDataSourceProvider._();

/// Provides the local data source backed by Isar for parental-control storage.

final class ParentalControlLocalDataSourceProvider
    extends
        $FunctionalProvider<
          ParentalControlLocalDataSource,
          ParentalControlLocalDataSource,
          ParentalControlLocalDataSource
        >
    with $Provider<ParentalControlLocalDataSource> {
  /// Provides the local data source backed by Isar for parental-control storage.
  ParentalControlLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parentalControlLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parentalControlLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<ParentalControlLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ParentalControlLocalDataSource create(Ref ref) {
    return parentalControlLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ParentalControlLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ParentalControlLocalDataSource>(
        value,
      ),
    );
  }
}

String _$parentalControlLocalDataSourceHash() =>
    r'31242eb044f6d0c455bef9a9da92a78c773dd162';

/// Provides the [ParentalControlRepository] implementation.

@ProviderFor(parentalControlRepository)
final parentalControlRepositoryProvider = ParentalControlRepositoryProvider._();

/// Provides the [ParentalControlRepository] implementation.

final class ParentalControlRepositoryProvider
    extends
        $FunctionalProvider<
          ParentalControlRepository,
          ParentalControlRepository,
          ParentalControlRepository
        >
    with $Provider<ParentalControlRepository> {
  /// Provides the [ParentalControlRepository] implementation.
  ParentalControlRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parentalControlRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parentalControlRepositoryHash();

  @$internal
  @override
  $ProviderElement<ParentalControlRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ParentalControlRepository create(Ref ref) {
    return parentalControlRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ParentalControlRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ParentalControlRepository>(value),
    );
  }
}

String _$parentalControlRepositoryHash() =>
    r'1ce02a3e6c544a558c8d93bce3b08b377658643c';

/// Streams the full [ParentalControlSettings] singleton from Isar.

@ProviderFor(parentalControlSettingsStream)
final parentalControlSettingsStreamProvider =
    ParentalControlSettingsStreamProvider._();

/// Streams the full [ParentalControlSettings] singleton from Isar.

final class ParentalControlSettingsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<ParentalControlSettings>,
          ParentalControlSettings,
          Stream<ParentalControlSettings>
        >
    with
        $FutureModifier<ParentalControlSettings>,
        $StreamProvider<ParentalControlSettings> {
  /// Streams the full [ParentalControlSettings] singleton from Isar.
  ParentalControlSettingsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parentalControlSettingsStreamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parentalControlSettingsStreamHash();

  @$internal
  @override
  $StreamProviderElement<ParentalControlSettings> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ParentalControlSettings> create(Ref ref) {
    return parentalControlSettingsStream(ref);
  }
}

String _$parentalControlSettingsStreamHash() =>
    r'83d816a98c8bf40d0305a746153372806e4679e0';

/// Returns whether Restricted Mode is currently active.
///
/// Fails closed (returns `true`) during initial stream loading and on storage
/// errors so that content is never accidentally exposed while state is unknown.

@ProviderFor(isRestrictedModeOn)
final isRestrictedModeOnProvider = IsRestrictedModeOnProvider._();

/// Returns whether Restricted Mode is currently active.
///
/// Fails closed (returns `true`) during initial stream loading and on storage
/// errors so that content is never accidentally exposed while state is unknown.

final class IsRestrictedModeOnProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Returns whether Restricted Mode is currently active.
  ///
  /// Fails closed (returns `true`) during initial stream loading and on storage
  /// errors so that content is never accidentally exposed while state is unknown.
  IsRestrictedModeOnProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isRestrictedModeOnProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isRestrictedModeOnHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isRestrictedModeOn(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isRestrictedModeOnHash() =>
    r'2cd69fc7ec1f4a8069aae6dd8a79beaf0412aec9';

/// Streams whether explicit episodes should be hidden for the given podcast.

@ProviderFor(hideExplicitForPodcast)
final hideExplicitForPodcastProvider = HideExplicitForPodcastFamily._();

/// Streams whether explicit episodes should be hidden for the given podcast.

final class HideExplicitForPodcastProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Streams whether explicit episodes should be hidden for the given podcast.
  HideExplicitForPodcastProvider._({
    required HideExplicitForPodcastFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'hideExplicitForPodcastProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hideExplicitForPodcastHash();

  @override
  String toString() {
    return r'hideExplicitForPodcastProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    final argument = this.argument as int;
    return hideExplicitForPodcast(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HideExplicitForPodcastProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hideExplicitForPodcastHash() =>
    r'eda86420bf5a51fb28d5815cceb857cd72398fae';

/// Streams whether explicit episodes should be hidden for the given podcast.

final class HideExplicitForPodcastFamily extends $Family
    with $FunctionalFamilyOverride<Stream<bool>, int> {
  HideExplicitForPodcastFamily._()
    : super(
        retry: null,
        name: r'hideExplicitForPodcastProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Streams whether explicit episodes should be hidden for the given podcast.

  HideExplicitForPodcastProvider call(int itunesId) =>
      HideExplicitForPodcastProvider._(argument: itunesId, from: this);

  @override
  String toString() => r'hideExplicitForPodcastProvider';
}

/// Returns `true` when the parental-control gate is in the [Unlocked] state.
///
/// Useful for conditionally enabling gated actions without pattern-matching on
/// the full [UnlockState] sealed type.

@ProviderFor(isUnlocked)
final isUnlockedProvider = IsUnlockedProvider._();

/// Returns `true` when the parental-control gate is in the [Unlocked] state.
///
/// Useful for conditionally enabling gated actions without pattern-matching on
/// the full [UnlockState] sealed type.

final class IsUnlockedProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Returns `true` when the parental-control gate is in the [Unlocked] state.
  ///
  /// Useful for conditionally enabling gated actions without pattern-matching on
  /// the full [UnlockState] sealed type.
  IsUnlockedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isUnlockedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isUnlockedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isUnlocked(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isUnlockedHash() => r'dc2d5f22374612d9f2d080e8dd1338cb6eb1eac2';
