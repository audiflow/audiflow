/// URL constants for the preset ecosystem: the audiflow-preset GitHub
/// repository and the contribute guide.
class PresetUrls {
  PresetUrls._();

  /// Base repository URL.
  static const String repo = 'https://github.com/audiflow/audiflow-preset';

  /// Contribute guide on the company site.
  ///
  /// The site owns where this lands (currently a redirect to [repo]), so
  /// the destination can change without an app release.
  static const String contribute =
      'https://company.reedom.com/audiflow/contribute';

  /// Returns the URL to a specific preset's directory in the repo.
  ///
  /// Preset sources live under `presets/` on `main`; the per-schema
  /// `dev/v{N}` branches no longer exist.
  static String presetDir(String presetId) =>
      '$repo/tree/main/presets/$presetId';
}
