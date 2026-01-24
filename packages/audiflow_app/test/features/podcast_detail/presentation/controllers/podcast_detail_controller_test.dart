import 'package:audiflow_app/features/podcast_detail/presentation/controllers/podcast_detail_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shouldFetchRemote', () {
    test('returns false when offline', () {
      expect(
        shouldFetchRemote(lastFetchedAt: DateTime.now(), isOnline: false),
        isFalse,
      );
    });

    test('returns true when never fetched', () {
      expect(shouldFetchRemote(lastFetchedAt: null, isOnline: true), isTrue);
    });

    test('returns false within refresh window', () {
      final recentFetch = DateTime.now().subtract(const Duration(minutes: 5));
      expect(
        shouldFetchRemote(lastFetchedAt: recentFetch, isOnline: true),
        isFalse,
      );
    });

    test('returns true after refresh window', () {
      final oldFetch = DateTime.now().subtract(const Duration(minutes: 15));
      expect(
        shouldFetchRemote(lastFetchedAt: oldFetch, isOnline: true),
        isTrue,
      );
    });
  });
}
