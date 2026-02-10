import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:logger/logger.dart';

/// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden at startup',
  );
});

/// Provider for PackageInfo
final packageInfoProvider = Provider<PackageInfo>((ref) {
  throw UnimplementedError('packageInfoProvider must be overridden at startup');
});

/// Provider for Logger
final loggerProvider = Provider<Logger>((ref) {
  throw UnimplementedError('loggerProvider must be overridden at startup');
});

/// Provider for application cache directory path.
///
/// Must be overridden at startup with the result of
/// `getApplicationCacheDirectory()` or equivalent.
final cacheDirProvider = Provider<String>((ref) {
  throw UnimplementedError('cacheDirProvider must be overridden at startup');
});

/// Provider for the SmartPlaylist config base URL.
///
/// Must be overridden at startup with the flavor-specific URL.
final smartPlaylistConfigBaseUrlProvider = Provider<String>((ref) {
  throw UnimplementedError(
    'smartPlaylistConfigBaseUrlProvider must be '
    'overridden at startup',
  );
});
