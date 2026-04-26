import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

/// [GemmaPlugin] backed by `flutter_gemma`.
///
/// Composition root in audiflow_app wires this against the
/// [GemmaModelManager] in audiflow_ai, keeping the plugin dependency out of
/// the lower layers.
///
/// **Filename contract.** [GemmaPlugin.installFromNetwork] expects the URL
/// the URL resolver hands back to end in the same `fileName` declared on
/// [GemmaModelVariant], because `flutter_gemma` derives the installed
/// model id from the URL's basename.
class FlutterGemmaPluginAdapter implements GemmaPlugin {
  const FlutterGemmaPluginAdapter();

  @override
  Future<bool> isModelInstalled(String fileName) =>
      FlutterGemma.isModelInstalled(fileName);

  @override
  Future<void> installFromNetwork({
    required String url,
    required String fileName,
    String? authToken,
    void Function(int percent)? onProgress,
  }) async {
    final segments = Uri.parse(url).pathSegments;
    final basename = segments.isEmpty ? '' : segments.last;
    if (basename != fileName) {
      // flutter_gemma derives the installed model id from the URL basename;
      // a divergence here would silently break isModelInstalled() forever.
      throw ArgumentError.value(
        url,
        'url',
        'URL basename "$basename" must match fileName "$fileName"',
      );
    }
    debugPrint(
      '[FlutterGemmaPluginAdapter] installModel($fileName).fromNetwork(...)',
    );
    final builder = FlutterGemma.installModel(
      modelType: ModelType.gemmaIt,
      fileType: ModelFileType.task,
    ).fromNetwork(url, token: authToken);
    if (onProgress != null) {
      builder.withProgress(onProgress);
    }
    await builder.install();
    debugPrint('[FlutterGemmaPluginAdapter] install() returned');
  }

  @override
  Future<void> uninstall(String fileName) =>
      FlutterGemma.uninstallModel(fileName);
}
