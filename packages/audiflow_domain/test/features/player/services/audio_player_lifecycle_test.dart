import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('playerLifecycleEventsProvider yields a Stream', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Eagerly materialize the provider. The provider's create() returns the
    // underlying Stream<PlayerLifecycleEvent>; AsyncValue wraps its emissions.
    final value = container.read(playerLifecycleEventsProvider);
    expect(value, isA<AsyncValue<PlayerLifecycleEvent>>());

    // Verify the controller's lifecycle stream (what the provider forwards) is
    // a Stream<PlayerLifecycleEvent>. This is the "reachability" smoke check.
    final controller = container.read(audioPlayerControllerProvider.notifier);
    expect(controller.lifecycleEvents, isA<Stream<PlayerLifecycleEvent>>());
  });
}
