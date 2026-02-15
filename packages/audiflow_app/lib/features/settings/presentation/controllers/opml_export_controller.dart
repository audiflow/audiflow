import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'opml_export_controller.g.dart';

/// Sealed result type for export operations.
sealed class OpmlExportState {}

class OpmlExportIdle extends OpmlExportState {}

class OpmlExportLoading extends OpmlExportState {}

class OpmlExportSuccess extends OpmlExportState {}

class OpmlExportEmpty extends OpmlExportState {}

class OpmlExportError extends OpmlExportState {
  OpmlExportError(this.message);
  final String message;
}

/// Controls OPML export: fetch subscriptions, generate XML,
/// share via system share sheet.
@riverpod
class OpmlExportController extends _$OpmlExportController {
  @override
  OpmlExportState build() => OpmlExportIdle();

  /// Exports all subscriptions as an OPML file and opens
  /// the system share sheet.
  Future<void> export() async {
    state = OpmlExportLoading();

    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      final subscriptions = await repo.getSubscriptions();

      if (subscriptions.isEmpty) {
        state = OpmlExportEmpty();
        return;
      }

      final entries = subscriptions
          .map((s) => OpmlEntry(title: s.title, feedUrl: s.feedUrl))
          .toList();

      final parser = OpmlParserService();
      final xml = parser.generate(entries);

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/audiflow_subscriptions.opml');
      await file.writeAsString(xml);

      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));

      // Clean up temp file
      if (file.existsSync()) {
        await file.delete();
      }

      state = OpmlExportSuccess();
    } on Exception catch (e) {
      state = OpmlExportError(e.toString());
    }
  }
}
