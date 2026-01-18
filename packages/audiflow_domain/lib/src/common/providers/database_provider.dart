import 'package:riverpod/riverpod.dart';

import '../database/app_database.dart';

/// Provider for Drift database instance
///
/// Must be overridden at app startup with a real AppDatabase instance.
/// See main.dart for initialization example.
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('databaseProvider must be overridden at startup');
});
