/// URL constants for the audiflow-smartplaylist GitHub repository.
class SmartPlaylistUrls {
  SmartPlaylistUrls._();

  /// Base repository URL.
  static const String repo =
      'https://github.com/audiflow/audiflow-smartplaylist';

  /// Returns the URL to a specific pattern's directory in the repo.
  ///
  /// Points to the `dev/v{schemaVersion}` branch where pattern
  /// data lives.
  static String patternDir(String patternId, {required int schemaVersion}) =>
      '$repo/tree/dev/v$schemaVersion/$patternId/';

  /// Returns the repo URL for the `dev/v{schemaVersion}` branch root.
  static String repoBranch({required int schemaVersion}) =>
      '$repo/tree/dev/v$schemaVersion';
}
