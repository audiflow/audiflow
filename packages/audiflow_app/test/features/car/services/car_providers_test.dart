import 'package:audiflow_app/features/car/services/car_media_controls.dart';
import 'package:audiflow_app/features/car/services/car_providers.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/player_stubs.dart';

class _Speed extends Notifier<double> {
  @override
  double build() => 1.2;

  void set(double value) => state = value;
}

final _speedProvider = NotifierProvider<_Speed, double>(_Speed.new);

void main() {
  late List<NowPlayingControlValues> seen;
  late ProviderContainer container;
  var forwardSeconds = 30;

  setUp(() {
    seen = [];
    forwardSeconds = 30;
    container = ProviderContainer(
      overrides: [
        nowPlayingSpeedProvider.overrideWith(
          (ref) => ref.watch(_speedProvider),
        ),
        appSettingsRepositoryProvider.overrideWith(
          (ref) => StubAppSettingsRepository(
            skipForwardSeconds: forwardSeconds,
            skipBackwardSeconds: 15,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.read(
      Provider<void>((ref) => watchNowPlayingControlValues(ref, seen.add)),
    );
  });

  test('reports the current values at once', () {
    check(seen).deepEquals([
      (speed: 1.2, skipForwardSeconds: 30, skipBackwardSeconds: 15),
    ]);
  });

  test('reports a speed change, as one made on the phone', () {
    container.read(_speedProvider.notifier).set(1.5);
    container.read(nowPlayingSpeedProvider);

    check(
      seen.last,
    ).equals((speed: 1.5, skipForwardSeconds: 30, skipBackwardSeconds: 15));
  });

  test('reports a skip change, which the settings screen invalidates', () {
    forwardSeconds = 45;
    container
      ..invalidate(appSettingsRepositoryProvider)
      ..read(appSettingsRepositoryProvider);

    check(seen.last.skipForwardSeconds).equals(45);
  });
}
