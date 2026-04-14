import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SleepTimerState', () {
    test('defaults via copyWith work', () {
      const s = SleepTimerState(
        config: SleepTimerConfig.off(),
        lastMinutes: 0,
        lastEpisodes: 0,
      );
      final updated = s.copyWith(lastMinutes: 30);
      expect(updated.lastMinutes, 30);
      expect(updated.lastEpisodes, 0);
      expect(updated.config, const SleepTimerConfig.off());
    });
  });

  group('SleepTimerEvent', () {
    test('SleepTimerFired is a distinct event', () {
      const e = SleepTimerFired();
      expect(e, isA<SleepTimerEvent>());
    });
  });
}
