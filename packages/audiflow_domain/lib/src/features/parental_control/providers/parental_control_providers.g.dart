// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parental_control_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pinHasher)
final pinHasherProvider = PinHasherProvider._();

final class PinHasherProvider
    extends $FunctionalProvider<PinHasher, PinHasher, PinHasher>
    with $Provider<PinHasher> {
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

@ProviderFor(parentalControlLocalDataSource)
final parentalControlLocalDataSourceProvider =
    ParentalControlLocalDataSourceProvider._();

final class ParentalControlLocalDataSourceProvider
    extends
        $FunctionalProvider<
          ParentalControlLocalDataSource,
          ParentalControlLocalDataSource,
          ParentalControlLocalDataSource
        >
    with $Provider<ParentalControlLocalDataSource> {
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

@ProviderFor(parentalControlRepository)
final parentalControlRepositoryProvider = ParentalControlRepositoryProvider._();

final class ParentalControlRepositoryProvider
    extends
        $FunctionalProvider<
          ParentalControlRepository,
          ParentalControlRepository,
          ParentalControlRepository
        >
    with $Provider<ParentalControlRepository> {
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
    r'636413e790cc7a4b6bb7062e6b73097e240b0d17';

@ProviderFor(parentalControlSettingsStream)
final parentalControlSettingsStreamProvider =
    ParentalControlSettingsStreamProvider._();

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

@ProviderFor(isRestrictedModeOn)
final isRestrictedModeOnProvider = IsRestrictedModeOnProvider._();

final class IsRestrictedModeOnProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
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
    r'5bd985a20e1a88e3b6ef8a60a82d44acadf85024';

@ProviderFor(hideExplicitForPodcast)
final hideExplicitForPodcastProvider = HideExplicitForPodcastFamily._();

final class HideExplicitForPodcastProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
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

  HideExplicitForPodcastProvider call(int itunesId) =>
      HideExplicitForPodcastProvider._(argument: itunesId, from: this);

  @override
  String toString() => r'hideExplicitForPodcastProvider';
}
