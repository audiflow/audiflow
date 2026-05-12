import 'package:flutter/foundation.dart';

/// Target platform for store-fallback URL selection.
///
/// Modelled separately from [TargetPlatform] so the resolver stays a
/// pure function (no `defaultTargetPlatform` dependency in tests).
enum TargetUpdatePlatform { ios, android, other }

// TODO(audiflow): switch to the live App Store URL once the app is
// listed; bundle id is `com.reedom.audiflow` (release flavor). Until then
// we point at the App Store home so the device at least opens the Store
// app rather than landing on an empty search results page.
const _appStoreFallbackUrl = 'https://apps.apple.com/';
const _androidPackage = 'com.reedom.audiflow_app';

/// Resolves the URL to open when the user taps "Update now".
///
/// Prefers the server-supplied [configUrl] when present and non-empty.
/// Falls back to the platform store deep link otherwise.
Uri resolveUpdateUrl({
  required String? configUrl,
  required TargetUpdatePlatform platform,
}) {
  if (configUrl != null && configUrl.isNotEmpty) {
    return Uri.parse(configUrl);
  }
  switch (platform) {
    case TargetUpdatePlatform.ios:
      return Uri.parse(_appStoreFallbackUrl);
    case TargetUpdatePlatform.android:
      return Uri.parse('market://details?id=$_androidPackage');
    case TargetUpdatePlatform.other:
      return Uri.parse(_appStoreFallbackUrl);
  }
}

/// Convenience wrapper that derives the platform from
/// [defaultTargetPlatform]. UI layer should prefer this.
Uri resolveUpdateUrlForCurrentPlatform({required String? configUrl}) {
  return resolveUpdateUrl(configUrl: configUrl, platform: _currentPlatform());
}

TargetUpdatePlatform _currentPlatform() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return TargetUpdatePlatform.ios;
    case TargetPlatform.android:
      return TargetUpdatePlatform.android;
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
      return TargetUpdatePlatform.other;
  }
}
