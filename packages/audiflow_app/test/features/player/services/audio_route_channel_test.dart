import 'package:audiflow_app/features/player/services/audio_route_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(AudioRouteChannel.channelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late List<String> calls;

  void answer(Object? Function(MethodCall call) reply) {
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return reply(call);
    });
  }

  setUp(() => calls = []);
  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  group('AudioRouteChannel', () {
    test('reports availability from the native side', () async {
      answer((_) => true);

      expect(await const AudioRouteChannel().isPickerAvailable(), isTrue);
      expect(calls, ['isPickerAvailable']);
    });

    test('showPicker returns whether anything opened', () async {
      answer((_) => false);

      expect(await const AudioRouteChannel().showPicker(), isFalse);
      expect(calls, ['showPicker']);
    });

    test('treats a native error as unavailable', () async {
      answer((_) => throw PlatformException(code: 'boom'));

      expect(await const AudioRouteChannel().isPickerAvailable(), isFalse);
    });

    test('treats a missing native handler as unavailable', () async {
      expect(await const AudioRouteChannel().isPickerAvailable(), isFalse);
      expect(await const AudioRouteChannel().showPicker(), isFalse);
    });
  });

  group('audioOutputPickerAvailableProvider', () {
    Future<bool> availableOn(TargetPlatform platform) {
      debugDefaultTargetPlatformOverride = platform;
      final container = ProviderContainer();
      addTearDown(container.dispose);
      return container.read(audioOutputPickerAvailableProvider.future);
    }

    test('is always available on iOS without asking the channel', () async {
      answer((_) => false);

      expect(await availableOn(TargetPlatform.iOS), isTrue);
      expect(calls, isEmpty);
    });

    test('asks the channel on Android', () async {
      answer((_) => false);

      expect(await availableOn(TargetPlatform.android), isFalse);
      expect(calls, ['isPickerAvailable']);
    });

    test('is unavailable on other platforms', () async {
      expect(await availableOn(TargetPlatform.macOS), isFalse);
      expect(calls, isEmpty);
    });
  });
}
