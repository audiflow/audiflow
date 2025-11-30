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
