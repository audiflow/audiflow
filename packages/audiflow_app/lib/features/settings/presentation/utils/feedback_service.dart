import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'feedback_service.g.dart';

/// Service that opens the community feedback page in an external browser.
///
/// Wrapped behind a provider so widget tests can substitute a recording fake
/// without touching the platform channel.
abstract class FeedbackService {
  Future<bool> openFeedback();
}

const _feedbackUrl = 'https://github.com/audiflow/community/discussions';

class _UrlLauncherFeedbackService implements FeedbackService {
  const _UrlLauncherFeedbackService();

  @override
  Future<bool> openFeedback() =>
      launchUrl(Uri.parse(_feedbackUrl), mode: LaunchMode.externalApplication);
}

@Riverpod(keepAlive: true)
FeedbackService feedbackService(Ref ref) => const _UrlLauncherFeedbackService();
