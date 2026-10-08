import 'package:audiflow_app/features/podcast_detail/presentation/controllers/podcast_detail_controller.dart';
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runs [refreshPlayedStateViews] each time it is refreshed.
final _refresher = Provider.autoDispose<void>(refreshPlayedStateViews);

void main() {
  group('refreshPlayedStateViews', () {
    test('refetches the episode detail progress', () async {
      const audioUrl = 'https://example.com/episode.mp3';
      var fetches = 0;
      final container = ProviderContainer(
        overrides: [
          episodeProgressProvider.overrideWith((ref, url) async {
            fetches++;
            return null;
          }),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        episodeProgressProvider(audioUrl),
        (_, _) {},
      );
      addTearDown(subscription.close);
      await container.read(episodeProgressProvider(audioUrl).future);
      check(fetches).equals(1);

      container.read(_refresher);
      await container.read(episodeProgressProvider(audioUrl).future);

      check(fetches).equals(2);
    });
  });
}
