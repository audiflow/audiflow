/// Provides a stable, anonymous identifier that lives for the life
/// of an install.
///
/// Used to correlate Sentry crash events with GA usage events.
abstract interface class InstallIdRepository {
  /// Returns the cached install id, generating and persisting one on
  /// first call.
  Future<String> getOrCreate();
}
