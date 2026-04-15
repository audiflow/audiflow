import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('playerLifecycleEventsProvider yields a Stream', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Provider exposes the controller's lifecycle stream directly (no
    // AsyncValue wrapping) so listeners can subscribe with a plain
    // Stream.listen.
    final stream = container.read(playerLifecycleEventsProvider);
    expect(stream, isA<Stream<PlayerLifecycleEvent>>());

    // Verify the controller's lifecycle stream (what the provider forwards)
    // is also a Stream<PlayerLifecycleEvent>. Reachability smoke check.
    final controller = container.read(audioPlayerControllerProvider.notifier);
    expect(controller.lifecycleEvents, isA<Stream<PlayerLifecycleEvent>>());
  });
}
