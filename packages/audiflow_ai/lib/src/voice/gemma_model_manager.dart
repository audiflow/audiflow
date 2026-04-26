import 'package:logger/logger.dart';

import 'gemma_model_install_exception.dart';
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
    Logger? logger,
  }) : _plugin = plugin,
       _urlResolver = urlResolver,
       _authTokenResolver = authTokenResolver,
       _logger = logger;

  final GemmaPlugin _plugin;
  final GemmaModelUrlResolver _urlResolver;
  final GemmaModelAuthTokenResolver? _authTokenResolver;
  final Logger? _logger;

  /// Whether [variant] is already installed on the device.
  Future<bool> isInstalled(GemmaModelVariant variant) =>
      _plugin.isModelInstalled(variant.fileName);

  /// Ensure [variant] is installed AND set as the active inference model.
  ///
  /// Returns when the model file is present locally and the underlying
  /// plugin has flipped its active-inference-model pointer to [variant].
  /// Idempotent: when the file is already cached the underlying plugin
  /// skips the download but still re-marks the model active (the active-
  /// model pointer in `flutter_gemma` is process-scoped and resets on
  /// every app launch). [onProgress] is therefore only invoked during a
  /// real download.
  ///
  /// Failures in the auth-token resolver or the plugin's download are
  /// rethrown as [GemmaModelInstallException] so callers can switch on
  /// the failure phase without inspecting raw plugin / IO exception
  /// types.
  Future<void> ensureInstalled(
    GemmaModelVariant variant, {
    void Function(int percent)? onProgress,
  }) async {
    final isAlready = await _plugin.isModelInstalled(variant.fileName);
    _logger?.i(
      'ensureInstalled: variant=${variant.name}, '
      'cacheHit=$isAlready (will still re-mark active)',
    );
    final String? token;
    try {
      token = await _authTokenResolver?.call(variant);
    } on Object catch (cause, stack) {
      _logger?.e(
        'ensureInstalled: auth-token resolver failed',
        error: cause,
        stackTrace: stack,
      );
      throw GemmaModelInstallException(
        variant: variant,
        phase: GemmaModelInstallPhase.authTokenResolution,
        cause: cause,
        stackTrace: stack,
      );
    }
    final url = _urlResolver(variant);
    _logger?.d(
      'ensureInstalled: token=${token == null ? 'null' : 'present'}, '
      'url=$url',
    );
    final start = DateTime.now();
    try {
      await _plugin.installFromNetwork(
        url: url,
        fileName: variant.fileName,
        authToken: token,
        onProgress: onProgress,
      );
    } on Object catch (cause, stack) {
      _logger?.e(
        'ensureInstalled: plugin.installFromNetwork failed',
        error: cause,
        stackTrace: stack,
      );
      throw GemmaModelInstallException(
        variant: variant,
        phase: GemmaModelInstallPhase.download,
        cause: cause,
        stackTrace: stack,
      );
    }
    final ms = DateTime.now().difference(start).inMilliseconds;
    _logger?.i(
      'ensureInstalled: complete in ${ms}ms '
      '(${isAlready ? 'no-op + setActive' : 'downloaded'})',
    );
  }

  /// Remove [variant] from local storage. No-op if not installed.
  Future<void> uninstall(GemmaModelVariant variant) =>
      _plugin.uninstall(variant.fileName);
}
