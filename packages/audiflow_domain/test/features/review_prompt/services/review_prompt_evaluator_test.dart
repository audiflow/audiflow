import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shouldShowReviewPrompt', () {
    test('false when total below initial threshold', () {
      const stats = ReviewPromptStats(
        totalListened: Duration(milliseconds: 1000),
      );
      check(shouldShowReviewPrompt(stats)).isFalse();
    });

    test('true when total reaches threshold exactly', () {
      const stats = ReviewPromptStats(
        totalListened: reviewPromptInitialThreshold,
      );
      check(shouldShowReviewPrompt(stats)).isTrue();
    });

    test('true when total well past threshold', () {
      final stats = ReviewPromptStats(
        totalListened: reviewPromptInitialThreshold * 2,
      );
      check(shouldShowReviewPrompt(stats)).isTrue();
    });

    test('false when opted out, regardless of total', () {
      final stats = ReviewPromptStats(
        totalListened: reviewPromptInitialThreshold * 10,
        status: ReviewPromptStatus.optedOut,
      );
      check(shouldShowReviewPrompt(stats)).isFalse();
    });

    test('false when rated, regardless of total', () {
      final stats = ReviewPromptStats(
        totalListened: reviewPromptInitialThreshold * 10,
        status: ReviewPromptStatus.rated,
      );
      check(shouldShowReviewPrompt(stats)).isFalse();
    });

    test('false when threshold advanced past total', () {
      final stats = ReviewPromptStats(
        totalListened:
            reviewPromptInitialThreshold + const Duration(milliseconds: 1),
        nextPromptThreshold:
            reviewPromptInitialThreshold + reviewPromptInterval,
      );
      check(shouldShowReviewPrompt(stats)).isFalse();
    });
  });
}
