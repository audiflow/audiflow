/// URL constants for the audiflow-preset GitHub repository.
class PresetUrls {
  PresetUrls._();

  /// Base repository URL.
  static const String repo = 'https://github.com/audiflow/audiflow-preset';

  /// Returns the URL to a specific preset's directory in the repo.
  ///
  /// Preset sources live under `presets/` on `main`; the per-schema
  /// `dev/v{N}` branches no longer exist.
  static String presetDir(String presetId) =>
      '$repo/tree/main/presets/$presetId';
}
