import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a preset repository [url] in the external browser.
///
/// These are developer-only links, so a failure is logged rather than
/// surfaced to the user.
Future<void> openPresetUrl(WidgetRef ref, String url) async {
  // Read before awaiting: the calling widget may unmount meanwhile.
  final logger = ref.read(namedLoggerProvider('PresetLinks'));
  try {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok) logger.w('Could not open preset URL: $url');
  } on Exception catch (e, stack) {
    logger.e('Failed to open preset URL: $url', error: e, stackTrace: stack);
  }
}
