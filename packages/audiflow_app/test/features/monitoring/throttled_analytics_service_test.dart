import 'package:audiflow_app/features/monitoring/services/throttled_analytics_service.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThrottledAnalyticsService', () {
    test('forwards non-throttled events without filtering', () async {
      final inner = FakeAnalyticsService();
      final clock = _FakeClock(DateTime(2026, 1, 1));
      final svc = ThrottledAnalyticsService(inner, now: clock.now);

      await svc.log(
        PodcastSubscribed(
          podcastId: 'p',
          podcastTitle: 'Pod',
          source: SubscribeSource.search,
        ),
      );
      await svc.log(
        PodcastSubscribed(
          podcastId: 'p',
          podcastTitle: 'Pod',
          source: SubscribeSource.search,
        ),
      );

      check(inner.events).length.equals(2);
    });

    test('throttles repeated pause for same episode within window', () async {
      final inner = FakeAnalyticsService();
      final clock = _FakeClock(DateTime(2026, 1, 1));
      final svc = ThrottledAnalyticsService(inner, now: clock.now);

      await svc.log(
        EpisodePaused(
          podcastId: 'p',
          episodeId: 'e1',
          podcastTitle: 'Pod',
          episodeTitle: 'Ep1',
          positionSec: 1,
        ),
      );
      clock.advance(const Duration(seconds: 2));
      await svc.log(
        EpisodePaused(
          podcastId: 'p',
          episodeId: 'e1',
          podcastTitle: 'Pod',
          episodeTitle: 'Ep1',
          positionSec: 3,
        ),
      );

      check(inner.events).length.equals(1);
    });

    test('allows pause after window elapses', () async {
      final inner = FakeAnalyticsService();
      final clock = _FakeClock(DateTime(2026, 1, 1));
      final svc = ThrottledAnalyticsService(inner, now: clock.now);

      await svc.log(
        EpisodePaused(
          podcastId: 'p',
          episodeId: 'e1',
          podcastTitle: 'Pod',
          episodeTitle: 'Ep1',
          positionSec: 1,
        ),
      );
      clock.advance(const Duration(seconds: 6));
      await svc.log(
        EpisodePaused(
          podcastId: 'p',
          episodeId: 'e1',
          podcastTitle: 'Pod',
          episodeTitle: 'Ep1',
          positionSec: 7,
        ),
      );

      check(inner.events).length.equals(2);
    });

    test(
      'keys throttle by episode id (different episodes pass through)',
      () async {
        final inner = FakeAnalyticsService();
        final clock = _FakeClock(DateTime(2026, 1, 1));
        final svc = ThrottledAnalyticsService(inner, now: clock.now);

        await svc.log(
          EpisodePaused(
            podcastId: 'p',
            episodeId: 'e1',
            podcastTitle: 'Pod',
            episodeTitle: 'Ep1',
            positionSec: 1,
          ),
        );
        await svc.log(
          EpisodePaused(
            podcastId: 'p',
            episodeId: 'e2',
            podcastTitle: 'Pod',
            episodeTitle: 'Ep2',
            positionSec: 1,
          ),
        );

        check(inner.events).length.equals(2);
      },
    );
  });
}

class _FakeClock {
  _FakeClock(this._now);
  DateTime _now;
  DateTime now() => _now;
  void advance(Duration d) => _now = _now.add(d);
}
