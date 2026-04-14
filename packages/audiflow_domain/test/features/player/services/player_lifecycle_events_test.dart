import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lifecycle events are distinct sealed variants', () {
    const a = EpisodeCompletedLifecycle();
    const b = EpisodeSwitchedLifecycle();
    const c = SeekLifecycle(Duration(seconds: 30));

    expect(a, isA<PlayerLifecycleEvent>());
    expect(b, isA<PlayerLifecycleEvent>());
    expect(c, isA<PlayerLifecycleEvent>());
    expect(c.position, const Duration(seconds: 30));
  });
}
