// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_queue_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Service for managing the download queue.
///
/// Handles sequential download processing, network state monitoring,
/// and smart retry with exponential backoff.

@ProviderFor(downloadQueueService)
final downloadQueueServiceProvider = DownloadQueueServiceProvider._();

/// Service for managing the download queue.
///
/// Handles sequential download processing, network state monitoring,
/// and smart retry with exponential backoff.

final class DownloadQueueServiceProvider
    extends
        $FunctionalProvider<
          DownloadQueueService,
          DownloadQueueService,
          DownloadQueueService
        >
    with $Provider<DownloadQueueService> {
  /// Service for managing the download queue.
  ///
  /// Handles sequential download processing, network state monitoring,
  /// and smart retry with exponential backoff.
  DownloadQueueServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'downloadQueueServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$downloadQueueServiceHash();

  @$internal
  @override
  $ProviderElement<DownloadQueueService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DownloadQueueService create(Ref ref) {
    return downloadQueueService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DownloadQueueService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DownloadQueueService>(value),
    );
  }
}

String _$downloadQueueServiceHash() =>
    r'09ee5935407f38131b9553b426f4eb74e285fab8';
