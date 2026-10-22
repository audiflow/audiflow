import 'dart:async';

import 'package:audiflow_app/features/car/services/car_artwork_resolver.dart';
import 'package:audiflow_app/features/car/services/car_catalog.dart';
import 'package:audiflow_app/features/car/services/car_media_browser.dart';
import 'package:audiflow_app/features/car/services/car_playback.dart';
import 'package:audiflow_app/features/car/services/car_providers.dart';
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

class _FakeCatalog extends Fake implements CarCatalog {}

class _FakePlayback extends Fake implements CarPlayback {}

class _FakeArtwork extends Fake implements CarArtworkResolver {}

/// Stands in for the list data the browser watches: database watches,
/// which Riverpod pauses while nothing actively listens to them.
final _signalSource = StreamController<int>.broadcast();
final _signalProvider = StreamProvider<int>((ref) => _signalSource.stream);

/// Hands out a provider's [Ref], as `audioHandlerProvider` hands its own to
/// the audio handler.
final _hostRefProvider = Provider<Ref>((ref) => ref);

void main() {
  late ProviderContainer container;
  late int changes;

  setUp(() {
    changes = 0;
    container = ProviderContainer(
      overrides: [
        carMediaBrowserProvider.overrideWith((ref) async {
          ref.listen(_signalProvider, (_, _) => changes++);
          return CarMediaBrowser(
            catalog: _FakeCatalog.new,
            playback: _FakePlayback(),
            artwork: _FakeArtwork(),
            tabTitles: () => const {},
            logger: Logger(level: Level.off),
            onFirstBrowse: () {},
          );
        }),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('keeps the browser watching changes across browse requests', () async {
    // Read once and never listened to again, like the audio handler.
    final link = CarBrowserLink(container.read(_hostRefProvider));

    // Every browse request reaches the browser through the link.
    for (var request = 0; request < 3; request++) {
      await link.browser;
    }
    _signalSource.add(1);
    await pumpEventQueue();

    check(changes).equals(1);
  });
}
