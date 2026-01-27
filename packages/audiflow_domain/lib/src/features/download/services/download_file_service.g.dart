// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_file_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Service for file download operations.
///
/// Handles actual HTTP downloads using Dio with progress callbacks,
/// file path management, and storage operations.

@ProviderFor(downloadFileService)
final downloadFileServiceProvider = DownloadFileServiceProvider._();

/// Service for file download operations.
///
/// Handles actual HTTP downloads using Dio with progress callbacks,
/// file path management, and storage operations.

final class DownloadFileServiceProvider
    extends
        $FunctionalProvider<
          DownloadFileService,
          DownloadFileService,
          DownloadFileService
        >
    with $Provider<DownloadFileService> {
  /// Service for file download operations.
  ///
  /// Handles actual HTTP downloads using Dio with progress callbacks,
  /// file path management, and storage operations.
  DownloadFileServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'downloadFileServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$downloadFileServiceHash();

  @$internal
  @override
  $ProviderElement<DownloadFileService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DownloadFileService create(Ref ref) {
    return downloadFileService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DownloadFileService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DownloadFileService>(value),
    );
  }
}

String _$downloadFileServiceHash() =>
    r'115ace92de7169e25d311a1244b5f1e210cd20f0';
