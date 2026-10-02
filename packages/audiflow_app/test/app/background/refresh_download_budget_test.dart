import 'package:audiflow_app/app/background/refresh_download_budget.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('refreshDownloadBudget', () {
    test('returns the time left before the refresh deadline', () {
      final budget = refreshDownloadBudget(const Duration(seconds: 5));

      check(budget).equals(refreshWindowDeadline - const Duration(seconds: 5));
    });

    test('returns the minimum budget when exactly that much is left', () {
      final budget = refreshDownloadBudget(
        refreshWindowDeadline - minRefreshDownloadBudget,
      );

      check(budget).equals(minRefreshDownloadBudget);
    });

    test('returns null when less than the minimum budget is left', () {
      final budget = refreshDownloadBudget(
        refreshWindowDeadline -
            minRefreshDownloadBudget +
            const Duration(milliseconds: 1),
      );

      check(budget).isNull();
    });

    test('returns null once the deadline has passed', () {
      final budget = refreshDownloadBudget(
        refreshWindowDeadline + const Duration(seconds: 10),
      );

      check(budget).isNull();
    });
  });
}
