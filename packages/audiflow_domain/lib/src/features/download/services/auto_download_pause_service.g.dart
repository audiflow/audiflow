// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_download_pause_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(autoDownloadPauseService)
final autoDownloadPauseServiceProvider = AutoDownloadPauseServiceProvider._();

final class AutoDownloadPauseServiceProvider
    extends
        $FunctionalProvider<
          AutoDownloadPauseService,
          AutoDownloadPauseService,
          AutoDownloadPauseService
        >
    with $Provider<AutoDownloadPauseService> {
  AutoDownloadPauseServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoDownloadPauseServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoDownloadPauseServiceHash();

  @$internal
  @override
  $ProviderElement<AutoDownloadPauseService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AutoDownloadPauseService create(Ref ref) {
    return autoDownloadPauseService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AutoDownloadPauseService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AutoDownloadPauseService>(value),
    );
  }
}

String _$autoDownloadPauseServiceHash() =>
    r'37c51aace723d76118d604c7e07dc54fe3dbd462';
