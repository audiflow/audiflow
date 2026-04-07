/// URL constants for the audiflow-smartplaylist GitHub repository.
class SmartPlaylistUrls {
  SmartPlaylistUrls._();

  /// Base repository URL.
  static const String repo =
      'https://github.com/audiflow/audiflow-smartplaylist';

  /// Returns the URL to a specific pattern's directory in the repo.
  static String patternDir(String patternId) => '$repo/tree/main/$patternId/';
}
