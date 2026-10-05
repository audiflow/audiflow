import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _container(EffectiveAudioSettings? resolved) async {
  SharedPreferences.setMockInitialValues({'settings_playback_speed': 1.3});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      nowPlayingAudioSettingsProvider.overrideWith((ref) => resolved),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('is the resolved speed for the now-playing podcast', () async {
    final container = await _container((
      scope: const PodcastAudioSettingsScope(7),
      settings: const AudioSettings(speed: 1.8, effects: PlaybackEffects.off),
    ));
    check(container.read(nowPlayingSpeedProvider)).equals(1.8);
  });

  test('falls back to the global speed while unresolved', () async {
    final container = await _container(null);
    check(container.read(nowPlayingSpeedProvider)).equals(1.3);
  });
}
