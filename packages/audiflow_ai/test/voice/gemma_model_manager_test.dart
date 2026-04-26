import 'package:audiflow_ai/src/voice/gemma_model_install_exception.dart';
import 'package:audiflow_ai/src/voice/gemma_model_manager.dart';
import 'package:audiflow_ai/src/voice/gemma_model_variant.dart';
import 'package:audiflow_ai/src/voice/gemma_plugin.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GemmaModelManager', () {
    late _FakeGemmaPlugin plugin;
    late GemmaModelManager manager;

    setUp(() {
      plugin = _FakeGemmaPlugin();
      manager = GemmaModelManager(
        plugin: plugin,
        urlResolver: (variant) => 'https://example.test/${variant.fileName}',
        authTokenResolver: (_) async => 'test-token',
      );
    });

    test('isInstalled delegates to plugin', () async {
      plugin.installed.add(GemmaModelVariant.e2b.fileName);
      check(await manager.isInstalled(GemmaModelVariant.e2b)).isTrue();
      check(await manager.isInstalled(GemmaModelVariant.e4b)).isFalse();
    });

    test(
      'ensureInstalled re-runs install on cache hit so the active-model '
      'pointer gets re-flipped, but emits no progress',
      () async {
        plugin.installed.add(GemmaModelVariant.e2b.fileName);
        var progressCalls = 0;
        await manager.ensureInstalled(
          GemmaModelVariant.e2b,
          onProgress: (_) => progressCalls++,
        );
        // The plugin is invoked even when cached — its install() is
        // idempotent and is also where flutter_gemma sets active.
        check(plugin.installCalls).length.equals(1);
        // No progress because the fake's progressToEmit is empty by default;
        // a real download path would emit, a cache-hit path would not.
        check(progressCalls).equals(0);
      },
    );

    test('ensureInstalled downloads with resolved URL and token', () async {
      final progress = <int>[];
      plugin.progressToEmit = const [10, 50, 100];
      await manager.ensureInstalled(
        GemmaModelVariant.e4b,
        onProgress: progress.add,
      );
      check(plugin.installCalls).length.equals(1);
      final call = plugin.installCalls.single;
      check(
        call.url,
      ).equals('https://example.test/${GemmaModelVariant.e4b.fileName}');
      check(call.fileName).equals(GemmaModelVariant.e4b.fileName);
      check(call.authToken).equals('test-token');
      check(progress).deepEquals([10, 50, 100]);
    });

    test('ensureInstalled tolerates a null token resolver', () async {
      manager = GemmaModelManager(
        plugin: plugin,
        urlResolver: (variant) => 'https://example.test/${variant.fileName}',
      );
      await manager.ensureInstalled(GemmaModelVariant.e2b);
      check(plugin.installCalls.single.authToken).isNull();
    });

    test('uninstall delegates to plugin', () async {
      plugin.installed.add(GemmaModelVariant.e2b.fileName);
      await manager.uninstall(GemmaModelVariant.e2b);
      check(plugin.installed).isEmpty();
    });

    test('download failures rethrow as GemmaModelInstallException', () async {
      plugin.shouldThrowOnInstall = true;
      try {
        await manager.ensureInstalled(GemmaModelVariant.e2b);
        fail('expected GemmaModelInstallException');
      } on GemmaModelInstallException catch (e) {
        check(e.variant).equals(GemmaModelVariant.e2b);
        check(e.phase).equals(GemmaModelInstallPhase.download);
      }
    });

    test('auth-token resolver failures rethrow with phase=auth', () async {
      manager = GemmaModelManager(
        plugin: plugin,
        urlResolver: (variant) => 'https://example.test/${variant.fileName}',
        authTokenResolver: (_) async => throw StateError('keychain locked'),
      );
      try {
        await manager.ensureInstalled(GemmaModelVariant.e2b);
        fail('expected GemmaModelInstallException');
      } on GemmaModelInstallException catch (e) {
        check(e.phase).equals(GemmaModelInstallPhase.authTokenResolution);
        check(e.cause).isA<StateError>();
      }
      // The plugin was never asked to download.
      check(plugin.installCalls).isEmpty();
    });
  });
}

class _InstallCall {
  _InstallCall({
    required this.url,
    required this.fileName,
    required this.authToken,
  });
  final String url;
  final String fileName;
  final String? authToken;
}

class _FakeGemmaPlugin implements GemmaPlugin {
  final Set<String> installed = {};
  final List<_InstallCall> installCalls = [];
  List<int> progressToEmit = const [];
  bool shouldThrowOnInstall = false;

  @override
  Future<bool> isModelInstalled(String fileName) async =>
      installed.contains(fileName);

  @override
  Future<void> installFromNetwork({
    required String url,
    required String fileName,
    String? authToken,
    void Function(int percent)? onProgress,
  }) async {
    if (shouldThrowOnInstall) {
      throw Exception('network down');
    }
    installCalls.add(
      _InstallCall(url: url, fileName: fileName, authToken: authToken),
    );
    if (onProgress != null) {
      progressToEmit.forEach(onProgress);
    }
    installed.add(fileName);
  }

  @override
  Future<void> uninstall(String fileName) async {
    installed.remove(fileName);
  }
}
