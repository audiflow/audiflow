import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SleepTimerConfig', () {
    test('off is a distinct variant', () {
      const cfg = SleepTimerConfig.off();
      expect(cfg, isA<SleepTimerConfig>());
      final isOff = switch (cfg) {
        SleepTimerConfigOff() => true,
        _ => false,
      };
      expect(isOff, isTrue);
    });

    test('duration carries total and deadline', () {
      final deadline = DateTime.utc(2026, 4, 14, 12);
      final cfg = SleepTimerConfig.duration(
        total: const Duration(minutes: 30),
        deadline: deadline,
      );
      switch (cfg) {
        case SleepTimerConfigDuration(:final total, :final deadline):
          expect(total, const Duration(minutes: 30));
          expect(deadline, DateTime.utc(2026, 4, 14, 12));
        default:
          fail('expected duration variant');
      }
    });

    test('episodes carries total and remaining', () {
      const cfg = SleepTimerConfig.episodes(total: 3, remaining: 2);
      switch (cfg) {
        case SleepTimerConfigEpisodes(:final total, :final remaining):
          expect(total, 3);
          expect(remaining, 2);
        default:
          fail('expected episodes variant');
      }
    });
  });
}
