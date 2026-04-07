// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for WiFi-only download setting.
///
/// Reads from user settings via [AppSettingsRepository].

@ProviderFor(downloadWifiOnly)
final downloadWifiOnlyProvider = DownloadWifiOnlyProvider._();

/// Provider for WiFi-only download setting.
///
/// Reads from user settings via [AppSettingsRepository].

final class DownloadWifiOnlyProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider for WiFi-only download setting.
  ///
  /// Reads from user settings via [AppSettingsRepository].
  DownloadWifiOnlyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'downloadWifiOnlyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$downloadWifiOnlyHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return downloadWifiOnly(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$downloadWifiOnlyHash() => r'32bc279478c4907cffa33c78e54ed66848760526';

/// Provider for auto-delete played setting.
///
/// Reads from user settings via [AppSettingsRepository].

@ProviderFor(downloadAutoDeletePlayed)
final downloadAutoDeletePlayedProvider = DownloadAutoDeletePlayedProvider._();

/// Provider for auto-delete played setting.
///
/// Reads from user settings via [AppSettingsRepository].

final class DownloadAutoDeletePlayedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider for auto-delete played setting.
  ///
  /// Reads from user settings via [AppSettingsRepository].
  DownloadAutoDeletePlayedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'downloadAutoDeletePlayedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$downloadAutoDeletePlayedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return downloadAutoDeletePlayed(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$downloadAutoDeletePlayedHash() =>
    r'cbccc113b6e9ea5b66235d7a78f9b715167d3446';

/// Provider for batch download limit setting.

@ProviderFor(batchDownloadLimit)
final batchDownloadLimitProvider = BatchDownloadLimitProvider._();

/// Provider for batch download limit setting.

final class BatchDownloadLimitProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Provider for batch download limit setting.
  BatchDownloadLimitProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'batchDownloadLimitProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$batchDownloadLimitHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return batchDownloadLimit(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$batchDownloadLimitHash() =>
    r'5f51dc449b828c535ddc79fe53a2b4590b5bf4b7';

/// Main service for managing episode downloads.
///
/// Provides high-level API for downloading episodes, managing the queue,
/// and integrating with playback history for auto-delete.

@ProviderFor(downloadService)
final downloadServiceProvider = DownloadServiceProvider._();

/// Main service for managing episode downloads.
///
/// Provides high-level API for downloading episodes, managing the queue,
/// and integrating with playback history for auto-delete.

final class DownloadServiceProvider
    extends
        $FunctionalProvider<DownloadService, DownloadService, DownloadService>
    with $Provider<DownloadService> {
  /// Main service for managing episode downloads.
  ///
  /// Provides high-level API for downloading episodes, managing the queue,
  /// and integrating with playback history for auto-delete.
  DownloadServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'downloadServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$downloadServiceHash();

  @$internal
  @override
  $ProviderElement<DownloadService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DownloadService create(Ref ref) {
    return downloadService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DownloadService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DownloadService>(value),
    );
  }
}

String _$downloadServiceHash() => r'750351a865e479c29f1e5ca2c9e9949595b188a8';
