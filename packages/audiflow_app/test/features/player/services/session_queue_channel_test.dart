import 'package:audiflow_app/features/player/services/session_queue_channel.dart';
import 'package:checks/checks.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(SessionQueueChannel.channelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('sends the title to the native side', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return true;
    });
    const title = 'Up Next';

    check(await const SessionQueueChannel().setTitle(title)).isTrue();

    check(calls.single)
      ..has((c) => c.method, 'method').equals('setTitle')
      ..has((c) => c.arguments, 'arguments').equals(title);
  });

  test('reports a native failure as false', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => throw PlatformException(code: 'boom'),
    );

    check(await const SessionQueueChannel().setTitle('Up Next')).isFalse();
  });

  test('tolerates a missing native side', () async {
    check(await const SessionQueueChannel().setTitle('Up Next')).isFalse();
  });
}
