import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeLifecycle {
  final _ctrl = StreamController<PlayerLifecycleEvent>.broadcast();
  Stream<PlayerLifecycleEvent> get stream => _ctrl.stream;
  void emit(PlayerLifecycleEvent e) => _ctrl.add(e);
  Future<void> close() => _ctrl.close();
}

void main() {
  group('SleepTimerController', () {
    late _FakeLifecycle fakeLifecycle;

    setUp(() async {
      fakeLifecycle = _FakeLifecycle();
      SharedPreferences.setMockInitialValues({
        'sleep_timer.last_minutes': 30,
        'sleep_timer.last_episodes': 3,
      });
    });

    tearDown(() async {
      await fakeLifecycle.close();
    });

    Future<ProviderContainer> makeContainer() async {
      final prefs = await SharedPreferences.getInstance();
      return ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          playerLifecycleEventsProvider.overrideWith(
            (ref) => fakeLifecycle.stream,
          ),
          currentEpisodeHasChaptersProvider.overrideWith((ref) async => false),
        ],
      );
    }

    test('build() seeds lastMinutes and lastEpisodes from prefs', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      final state = container.read(sleepTimerControllerProvider);
      expect(state.config, const SleepTimerConfig.off());
      expect(state.lastMinutes, 30);
      expect(state.lastEpisodes, 3);
    });

    test('setDuration persists minutes and sets duration config', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      await container
          .read(sleepTimerControllerProvider.notifier)
          .setDuration(const Duration(minutes: 15));

      final state = container.read(sleepTimerControllerProvider);
      expect(state.lastMinutes, 15);
      switch (state.config) {
        case SleepTimerConfigDuration(:final total):
          expect(total, const Duration(minutes: 15));
        default:
          fail('expected duration config');
      }
    });

    test('setEpisodes persists count and sets episodes config', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      await container
          .read(sleepTimerControllerProvider.notifier)
          .setEpisodes(4);

      final state = container.read(sleepTimerControllerProvider);
      expect(state.lastEpisodes, 4);
      switch (state.config) {
        case SleepTimerConfigEpisodes(:final total, :final remaining):
          expect(total, 4);
          expect(remaining, 4);
        default:
          fail('expected episodes config');
      }
    });

    test('EpisodeCompletedLifecycle decrements episodes remaining', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      await container
          .read(sleepTimerControllerProvider.notifier)
          .setEpisodes(3);

      fakeLifecycle.emit(const EpisodeCompletedLifecycle());
      await pumpEventQueue();

      final state = container.read(sleepTimerControllerProvider);
      switch (state.config) {
        case SleepTimerConfigEpisodes(:final remaining):
          expect(remaining, 2);
        default:
          fail('expected episodes config still active');
      }
    });

    test(
      'EpisodeCompletedLifecycle with endOfEpisode fires and resets',
      () async {
        final container = await makeContainer();
        addTearDown(container.dispose);

        container.read(sleepTimerControllerProvider.notifier).setEndOfEpisode();

        final events = <SleepTimerEvent>[];
        final sub = container
            .read(sleepTimerControllerProvider.notifier)
            .events
            .listen(events.add);
        addTearDown(sub.cancel);

        fakeLifecycle.emit(const EpisodeCompletedLifecycle());
        await Future<void>.delayed(Duration.zero);

        final state = container.read(sleepTimerControllerProvider);
        expect(state.config, const SleepTimerConfig.off());
        expect(events, contains(isA<SleepTimerFired>()));
      },
    );

    test('setOff() while episodes active clears config', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      await container
          .read(sleepTimerControllerProvider.notifier)
          .setEpisodes(2);
      container.read(sleepTimerControllerProvider.notifier).setOff();

      final state = container.read(sleepTimerControllerProvider);
      expect(state.config, const SleepTimerConfig.off());
    });
  });
}
