import 'dart:async';

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:audiflow_app/features/settings/presentation/widgets/dev_gemma_model_install_panel.dart';
import 'package:audiflow_app/features/voice/gemma/gemma_voice_providers.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DevGemmaModelInstallPanel', () {
    testWidgets('shows Installed when the model is already present', (
      tester,
    ) async {
      final plugin = _FakeGemmaPlugin(
        installed: {GemmaModelVariant.e2b.fileName},
      );
      await _pump(tester, plugin: plugin);

      // First frame is "Checking…", then the async isInstalled resolves.
      await tester.pumpAndSettle();

      check(find.text('Installed').evaluate().length).equals(1);
      check(find.text('Remove').evaluate().length).equals(1);
    });

    testWidgets('Download button drives the install flow to completion', (
      tester,
    ) async {
      final plugin = _FakeGemmaPlugin();
      await _pump(tester, plugin: plugin);
      await tester.pumpAndSettle();

      // Initial state: not installed → Download button visible.
      check(find.text('Download model').evaluate().length).equals(1);

      await tester.tap(find.text('Download model'));
      // Pump the click; install future hasn't resolved yet because we
      // haven't completed the plugin's stub.
      await tester.pump();

      // Push a couple of progress samples; widget should update %.
      plugin.emitProgress(40);
      await tester.pump();
      check(find.text('40%').evaluate().length).equals(1);

      plugin.emitProgress(100);
      await tester.pump();
      check(find.text('100%').evaluate().length).equals(1);

      // Resolve the install future and let the success state propagate.
      plugin.completeInstall();
      await tester.pumpAndSettle();
      check(find.text('Installed').evaluate().length).equals(1);
    });

    testWidgets('install failure surfaces the failure phase + retry', (
      tester,
    ) async {
      final plugin = _FakeGemmaPlugin();
      await _pump(tester, plugin: plugin);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Download model'));
      await tester.pump();

      plugin.failInstallWith(Exception('network down'));
      await tester.pumpAndSettle();

      // GemmaModelInstallException wraps with phase=download.
      check(find.textContaining('download').evaluate().length).isGreaterThan(0);
      check(find.text('Retry').evaluate().length).equals(1);

      // Retry flips back to the Download button after a fresh status check.
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      check(find.text('Download model').evaluate().length).equals(1);
    });

    testWidgets('Remove uninstalls and returns to Download', (tester) async {
      final plugin = _FakeGemmaPlugin(
        installed: {GemmaModelVariant.e2b.fileName},
      );
      await _pump(tester, plugin: plugin);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      check(
        plugin.uninstalledFiles,
      ).deepEquals([GemmaModelVariant.e2b.fileName]);
      check(find.text('Download model').evaluate().length).equals(1);
    });

    testWidgets('variant change re-checks installed state', (tester) async {
      final plugin = _FakeGemmaPlugin(
        installed: {GemmaModelVariant.e4b.fileName},
      );
      await _pump(tester, plugin: plugin, variant: GemmaModelVariant.e2b);
      await tester.pumpAndSettle();

      // E2B is not installed.
      check(find.text('Download model').evaluate().length).equals(1);

      // Swap to E4B (which IS installed in the fake).
      await _pump(tester, plugin: plugin, variant: GemmaModelVariant.e4b);
      await tester.pumpAndSettle();

      check(find.text('Installed').evaluate().length).equals(1);
    });
  });
}

Future<void> _pump(
  WidgetTester tester, {
  required _FakeGemmaPlugin plugin,
  GemmaModelVariant variant = GemmaModelVariant.e2b,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        gemmaModelManagerProvider.overrideWith(
          (ref) => GemmaModelManager(
            plugin: plugin,
            urlResolver: (_) => 'https://example.test/model',
          ),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(body: DevGemmaModelInstallPanel(variant: variant)),
      ),
    ),
  );
}

class _FakeGemmaPlugin implements GemmaPlugin {
  _FakeGemmaPlugin({Set<String>? installed}) : _installed = installed ?? {};

  final Set<String> _installed;
  final List<String> uninstalledFiles = [];

  Completer<void>? _installCompleter;
  void Function(int)? _onProgress;
  String? _installingFile;

  @override
  Future<bool> isModelInstalled(String fileName) async =>
      _installed.contains(fileName);

  @override
  Future<void> installFromNetwork({
    required String url,
    required String fileName,
    String? authToken,
    void Function(int percent)? onProgress,
  }) {
    _installingFile = fileName;
    _onProgress = onProgress;
    _installCompleter = Completer<void>();
    return _installCompleter!.future;
  }

  @override
  Future<void> uninstall(String fileName) async {
    uninstalledFiles.add(fileName);
    _installed.remove(fileName);
  }

  // Test helpers.
  void emitProgress(int percent) => _onProgress?.call(percent);

  void completeInstall() {
    final file = _installingFile;
    if (file != null) _installed.add(file);
    _installCompleter?.complete();
    _installCompleter = null;
    _installingFile = null;
    _onProgress = null;
  }

  void failInstallWith(Object error) {
    _installCompleter?.completeError(error);
    _installCompleter = null;
    _installingFile = null;
    _onProgress = null;
  }
}
