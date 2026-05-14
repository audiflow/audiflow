// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_launcher_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Default URL launcher delegating to `package:url_launcher`.
///
/// Uses [url_launcher.LaunchMode.externalApplication] so the store link
/// opens the App Store / Play Store app directly.

@ProviderFor(urlLauncher)
final urlLauncherProvider = UrlLauncherProvider._();

/// Default URL launcher delegating to `package:url_launcher`.
///
/// Uses [url_launcher.LaunchMode.externalApplication] so the store link
/// opens the App Store / Play Store app directly.

final class UrlLauncherProvider
    extends $FunctionalProvider<UrlLauncher, UrlLauncher, UrlLauncher>
    with $Provider<UrlLauncher> {
  /// Default URL launcher delegating to `package:url_launcher`.
  ///
  /// Uses [url_launcher.LaunchMode.externalApplication] so the store link
  /// opens the App Store / Play Store app directly.
  UrlLauncherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'urlLauncherProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$urlLauncherHash();

  @$internal
  @override
  $ProviderElement<UrlLauncher> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UrlLauncher create(Ref ref) {
    return urlLauncher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UrlLauncher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UrlLauncher>(value),
    );
  }
}

String _$urlLauncherHash() => r'16a9dc593c416431c35afb1fdc2d4012088c4c9c';
