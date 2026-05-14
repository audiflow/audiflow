import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shouldShowReviewPrompt', () {
    test('false when total below initial threshold', () {
      const stats = ReviewPromptStats(totalListenedMs: 1000);
      check(shouldShowReviewPrompt(stats)).isFalse();
    });

    test('true when total reaches threshold exactly', () {
      const stats = ReviewPromptStats(
        totalListenedMs: ReviewPromptStats.initialThresholdMs,
      );
      check(shouldShowReviewPrompt(stats)).isTrue();
    });

    test('true when total well past threshold', () {
      const stats = ReviewPromptStats(
        totalListenedMs: ReviewPromptStats.initialThresholdMs * 2,
      );
      check(shouldShowReviewPrompt(stats)).isTrue();
    });

    test('false when user opted out, regardless of total', () {
      const stats = ReviewPromptStats(
        totalListenedMs: ReviewPromptStats.initialThresholdMs * 10,
        userOptedOut: true,
      );
      check(shouldShowReviewPrompt(stats)).isFalse();
    });

    test('false when user tapped rate-now, regardless of total', () {
      const stats = ReviewPromptStats(
        totalListenedMs: ReviewPromptStats.initialThresholdMs * 10,
        userTappedRateNow: true,
      );
      check(shouldShowReviewPrompt(stats)).isFalse();
    });

    test('false when threshold advanced and total has not caught up', () {
      const stats = ReviewPromptStats(
        totalListenedMs: ReviewPromptStats.initialThresholdMs + 1,
        nextPromptThresholdMs:
            ReviewPromptStats.initialThresholdMs +
            ReviewPromptStats.promptIntervalMs,
      );
      check(shouldShowReviewPrompt(stats)).isFalse();
    });
  });
}
