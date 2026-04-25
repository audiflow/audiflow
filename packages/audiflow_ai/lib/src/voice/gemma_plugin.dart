/// Port over the bits of `flutter_gemma` that the model manager uses.
///
/// Defined as an interface so unit tests can substitute a fake without
/// pulling the native plugin into the test runner. The concrete
/// `flutter_gemma` adapter is wired in audiflow_app at composition root
/// (Phase 3 of the Gemma migration).
abstract interface class GemmaPlugin {
  /// Whether the model file [fileName] is already installed locally.
  Future<bool> isModelInstalled(String fileName);

  /// Download and install [fileName] from [url].
  ///
  /// Reports progress in [0, 100] via [onProgress] when supplied.
  /// [authToken] is used for gated Hugging Face downloads.
  Future<void> installFromNetwork({
    required String url,
    required String fileName,
    String? authToken,
    void Function(int percent)? onProgress,
  });

  /// Remove a previously installed model from local storage.
  Future<void> uninstall(String fileName);
}
