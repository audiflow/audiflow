import 'gemma_model_variant.dart';
import 'gemma_plugin.dart';

/// Resolves a download URL for [variant]. Kept injectable so the host app
/// controls where models come from (Hugging Face directly, a CDN mirror,
/// or a flavored prod/staging bucket).
typedef GemmaModelUrlResolver = String Function(GemmaModelVariant variant);

/// Auth token resolver for gated download endpoints. Return null when no
/// token is needed.
typedef GemmaModelAuthTokenResolver =
    Future<String?> Function(GemmaModelVariant variant);

/// Lifecycle manager for downloaded Gemma 4 models.
///
/// Thin coordination layer over a [GemmaPlugin] that adds variant-aware
/// install / uninstall / progress reporting. Does no inference.
class GemmaModelManager {
  GemmaModelManager({
    required GemmaPlugin plugin,
    required GemmaModelUrlResolver urlResolver,
    GemmaModelAuthTokenResolver? authTokenResolver,
  }) : _plugin = plugin,
       _urlResolver = urlResolver,
       _authTokenResolver = authTokenResolver;

  final GemmaPlugin _plugin;
  final GemmaModelUrlResolver _urlResolver;
  final GemmaModelAuthTokenResolver? _authTokenResolver;

  /// Whether [variant] is already installed on the device.
  Future<bool> isInstalled(GemmaModelVariant variant) =>
      _plugin.isModelInstalled(variant.fileName);

  /// Ensure [variant] is installed, downloading if necessary.
  ///
  /// [onProgress] is invoked with percentages in [0, 100] during the
  /// download. When the model is already present, returns immediately
  /// without invoking [onProgress].
  Future<void> ensureInstalled(
    GemmaModelVariant variant, {
    void Function(int percent)? onProgress,
  }) async {
    if (await _plugin.isModelInstalled(variant.fileName)) {
      return;
    }
    final token = await _authTokenResolver?.call(variant);
    await _plugin.installFromNetwork(
      url: _urlResolver(variant),
      fileName: variant.fileName,
      authToken: token,
      onProgress: onProgress,
    );
  }

  /// Remove [variant] from local storage. No-op if not installed.
  Future<void> uninstall(GemmaModelVariant variant) =>
      _plugin.uninstall(variant.fileName);
}
