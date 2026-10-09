// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_retention_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(downloadRetentionService)
final downloadRetentionServiceProvider = DownloadRetentionServiceProvider._();

final class DownloadRetentionServiceProvider
    extends
        $FunctionalProvider<
          DownloadRetentionService,
          DownloadRetentionService,
          DownloadRetentionService
        >
    with $Provider<DownloadRetentionService> {
  DownloadRetentionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'downloadRetentionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$downloadRetentionServiceHash();

  @$internal
  @override
  $ProviderElement<DownloadRetentionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DownloadRetentionService create(Ref ref) {
    return downloadRetentionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DownloadRetentionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DownloadRetentionService>(value),
    );
  }
}

String _$downloadRetentionServiceHash() =>
    r'58de4d5f32e0597cab4f47186785ac35238e4d89';
