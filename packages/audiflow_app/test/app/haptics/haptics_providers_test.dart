import 'package:audiflow_app/app/haptics/haptics_providers.dart';
import 'package:audiflow_app/app/haptics/method_channel_haptic_player.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(MethodChannelHapticPlayer.channelName);
  late List<MethodCall> calls;
  // The players also ask the channel whether the device has haptics.
  Iterable<MethodCall> plays() => calls.where((c) => c.method == 'play');

  void handleChannel(Future<Object?>? Function(MethodCall call) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handler);
  }

  setUp(() {
    calls = [];
    handleChannel((call) async {
      calls.add(call);
      return null;
    });
  });

  tearDown(() => handleChannel((_) => null));

  group('MethodChannelHapticPlayer', () {
    test('play sends the token name', () async {
      const MethodChannelHapticPlayer().play(HapticToken.thresholdCross);
      await pumpEventQueue();
      check(calls.single)
        ..has((c) => c.method, 'method').equals('play')
        ..has((c) => c.arguments, 'arguments').equals('thresholdCross');
    });

    test('prepare sends the token name', () async {
      const MethodChannelHapticPlayer().prepare(HapticToken.dragPickUp);
      await pumpEventQueue();
      check(calls.single)
        ..has((c) => c.method, 'method').equals('prepare')
        ..has((c) => c.arguments, 'arguments').equals('dragPickUp');
    });

    test('swallows a missing native handler', () async {
      handleChannel((_) => throw MissingPluginException());
      const MethodChannelHapticPlayer().play(HapticToken.success);
      await pumpEventQueue();
    });

    test('swallows a platform error', () async {
      handleChannel((_) => throw PlatformException(code: 'failed'));
      const MethodChannelHapticPlayer().play(HapticToken.error);
      await pumpEventQueue();
    });
  });

  group('MethodChannelHapticPlayer.isSupported', () {
    test('returns the native answer', () async {
      handleChannel((call) async => call.method == 'isSupported' ? false : null);
      check(await const MethodChannelHapticPlayer().isSupported()).isFalse();
    });

    // A failed lookup must not hide the setting on a device that has haptics.
    test('assumes support when the native side does not answer', () async {
      handleChannel((_) => throw MissingPluginException());
      check(await const MethodChannelHapticPlayer().isSupported()).isTrue();
    });

    test('assumes support on a platform error', () async {
      handleChannel((_) => throw PlatformException(code: 'failed'));
      check(await const MethodChannelHapticPlayer().isSupported()).isTrue();
    });
  });

  group('hapticPlayerProvider', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    ProviderContainer createContainer() {
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('level defaults to on', () {
      final container = createContainer();
      check(
        container.read(hapticFeedbackLevelControllerProvider),
      ).equals(HapticFeedbackLevel.on);
    });

    test('setLevel persists and updates state', () async {
      final container = createContainer();
      await container
          .read(hapticFeedbackLevelControllerProvider.notifier)
          .setLevel(HapticFeedbackLevel.reduced);

      check(
        container.read(hapticFeedbackLevelControllerProvider),
      ).equals(HapticFeedbackLevel.reduced);
      check(
        prefs.getString(SettingsKeys.hapticFeedbackLevel),
      ).equals('reduced');
    });

    test('player follows the level', () async {
      final container = createContainer();
      await container
          .read(hapticFeedbackLevelControllerProvider.notifier)
          .setLevel(HapticFeedbackLevel.off);

      container.read(hapticPlayerProvider).play(HapticToken.success);
      await pumpEventQueue();
      check(plays()).isEmpty();

      await container
          .read(hapticFeedbackLevelControllerProvider.notifier)
          .setLevel(HapticFeedbackLevel.on);

      container.read(hapticPlayerProvider).play(HapticToken.success);
      await pumpEventQueue();
      check(plays()).length.equals(1);
    });

    test('player stays silent on a device without haptics', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          hapticsSupportedProvider.overrideWithValue(const AsyncData(false)),
        ],
      );
      addTearDown(container.dispose);
      await container
          .read(hapticFeedbackLevelControllerProvider.notifier)
          .setLevel(HapticFeedbackLevel.on);

      container.read(hapticPlayerProvider).play(HapticToken.success);
      await pumpEventQueue();
      check(plays()).isEmpty();
    });
  });
}
