import 'package:audiflow_app/features/search/presentation/controllers/search_controller.dart';
import 'package:audiflow_domain/audiflow_domain.dart'
    hide podcastSearchServiceProvider;
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/search_mocks.dart';

void main() {
  group('PodcastSearchController country', () {
    late ProviderContainer container;
    late MockPodcastSearchService mockService;
    late FakeAppSettingsRepository fakeSettings;

    setUp(() {
      mockService = MockPodcastSearchService();
      fakeSettings = FakeAppSettingsRepository();
      container = ProviderContainer(
        overrides: [
          podcastSearchServiceProvider.overrideWithValue(mockService),
          appSettingsRepositoryProvider.overrideWithValue(fakeSettings),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('passes device-derived country when no setting', () async {
      final controller = container.read(
        podcastSearchControllerProvider.notifier,
      );
      await controller.searchImmediate('flutter');
      check(mockService.lastSearchCountry).isNotNull();
    });

    test('passes saved country setting to search query', () async {
      await fakeSettings.setSearchCountry('jp');
      final controller = container.read(
        podcastSearchControllerProvider.notifier,
      );
      await controller.searchImmediate('flutter');
      check(mockService.lastSearchCountry).equals('jp');
    });

    test('onCountryChanged re-executes search with new country', () async {
      final controller = container.read(
        podcastSearchControllerProvider.notifier,
      );
      await controller.searchImmediate('flutter');
      check(mockService.searchCallCount).equals(1);

      controller.onCountryChanged('gb');
      // Allow microtasks to settle
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      check(mockService.searchCallCount).equals(2);
      check(mockService.lastSearchCountry).equals('gb');
    });

    test('onCountryChanged does nothing when no active query', () async {
      final controller = container.read(
        podcastSearchControllerProvider.notifier,
      );
      controller.onCountryChanged('gb');
      await Future<void>.delayed(Duration.zero);
      check(mockService.searchCallCount).equals(0);
    });
  });
}
