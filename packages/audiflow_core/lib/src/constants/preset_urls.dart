/// URL constants for the audiflow-preset GitHub repository.
class PresetUrls {
  PresetUrls._();

  /// Base repository URL.
  static const String repo = 'https://github.com/audiflow/audiflow-preset';

  /// Returns the URL to a specific preset's directory in the repo.
  ///
  /// Points to the `dev/v{schemaVersion}` branch where preset
  /// data lives.
  static String presetDir(String presetId, {required int schemaVersion}) =>
      '$repo/tree/dev/v$schemaVersion/presets/$presetId';

  /// Returns the repo URL for the `dev/v{schemaVersion}` branch root.
  static String repoBranch({required int schemaVersion}) =>
      '$repo/tree/dev/v$schemaVersion';
}
