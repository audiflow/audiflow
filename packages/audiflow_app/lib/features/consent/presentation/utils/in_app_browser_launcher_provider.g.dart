// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_app_browser_launcher_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Launches URLs in an in-app browser surface
/// ([url_launcher.LaunchMode.inAppBrowserView] → SFSafariViewController on
/// iOS / Chrome Custom Tabs on Android), keeping the consent flow on top of
/// the calling activity.

@ProviderFor(inAppBrowserLauncher)
final inAppBrowserLauncherProvider = InAppBrowserLauncherProvider._();

/// Launches URLs in an in-app browser surface
/// ([url_launcher.LaunchMode.inAppBrowserView] → SFSafariViewController on
/// iOS / Chrome Custom Tabs on Android), keeping the consent flow on top of
/// the calling activity.

final class InAppBrowserLauncherProvider
    extends
        $FunctionalProvider<
          InAppBrowserLauncher,
          InAppBrowserLauncher,
          InAppBrowserLauncher
        >
    with $Provider<InAppBrowserLauncher> {
  /// Launches URLs in an in-app browser surface
  /// ([url_launcher.LaunchMode.inAppBrowserView] → SFSafariViewController on
  /// iOS / Chrome Custom Tabs on Android), keeping the consent flow on top of
  /// the calling activity.
  InAppBrowserLauncherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inAppBrowserLauncherProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inAppBrowserLauncherHash();

  @$internal
  @override
  $ProviderElement<InAppBrowserLauncher> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InAppBrowserLauncher create(Ref ref) {
    return inAppBrowserLauncher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InAppBrowserLauncher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InAppBrowserLauncher>(value),
    );
  }
}

String _$inAppBrowserLauncherHash() =>
    r'e1873d4eaad90f09b1fb7cfd1213d52dbe000b74';
