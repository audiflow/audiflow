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

String _$downloadServiceHash() => r'8a9f61af3dfa4b90eb487528f893e7d7eb3a856f';
