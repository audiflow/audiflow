// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'install_id_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(installIdRepository)
final installIdRepositoryProvider = InstallIdRepositoryProvider._();

final class InstallIdRepositoryProvider
    extends
        $FunctionalProvider<
          InstallIdRepository,
          InstallIdRepository,
          InstallIdRepository
        >
    with $Provider<InstallIdRepository> {
  InstallIdRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'installIdRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$installIdRepositoryHash();

  @$internal
  @override
  $ProviderElement<InstallIdRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InstallIdRepository create(Ref ref) {
    return installIdRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InstallIdRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InstallIdRepository>(value),
    );
  }
}

String _$installIdRepositoryHash() =>
    r'63bc706d1d892cd97081fdbc75c9833714fa1d7a';
