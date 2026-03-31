import 'dart:io';

import 'package:audiflow_app/features/settings/presentation/controllers/opml_file_receiver_controller.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../../../helpers/fakes.dart';

const _validOpml = '''<?xml version="1.0" encoding="UTF-8"?>
<opml version="1.0">
  <body>
    <outline type="rss" text="Test Podcast" xmlUrl="https://example.com/feed.xml"/>
  </body>
</opml>''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  const appLinksChannel = MethodChannel('com.llfbandit.app_links/messages');
  const appLinksEvents = EventChannel('com.llfbandit.app_links/events');

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        subscriptionRepositoryProvider.overrideWithValue(
          _TestSubscriptionRepository(),
        ),
      ],
    );
  }

  setUp(() {
    // Mock app_links platform channels so build() doesn't throw
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(appLinksChannel, (call) async {
          if (call.method == 'getInitialLink') return null;
          if (call.method == 'getLatestLink') return null;
          return null;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(appLinksEvents, _EmptyStreamHandler());
    container = createContainer();
  });

  tearDown(() {
    container.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(appLinksChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(appLinksEvents, null);
  });

  group('OpmlFileReceiverController', () {
    test('initial state is idle', () {
      final state = container.read(opmlFileReceiverControllerProvider);
      check(state).isA<OpmlFileReceiverIdle>();
    });

    test('reset returns to idle', () {
      container.read(opmlFileReceiverControllerProvider.notifier).reset();
      final state = container.read(opmlFileReceiverControllerProvider);
      check(state).isA<OpmlFileReceiverIdle>();
    });
  });

  group('_handleUri scheme filtering', () {
    test('ignores https:// URIs', () async {
      final notifier = container.read(
        opmlFileReceiverControllerProvider.notifier,
      );
      // Call handleUri indirectly via the public test helper
      await notifier.handleUriForTest(
        Uri.parse('https://example.com/feed.opml'),
      );
      final state = container.read(opmlFileReceiverControllerProvider);
      // Should remain idle since https is not a supported scheme
      check(state).isA<OpmlFileReceiverIdle>();
    });

    test('ignores mailto: URIs', () async {
      final notifier = container.read(
        opmlFileReceiverControllerProvider.notifier,
      );
      await notifier.handleUriForTest(Uri.parse('mailto:test@example.com'));
      final state = container.read(opmlFileReceiverControllerProvider);
      check(state).isA<OpmlFileReceiverIdle>();
    });

    test('ignores file:// URIs without .opml or .xml extension', () async {
      final notifier = container.read(
        opmlFileReceiverControllerProvider.notifier,
      );
      await notifier.handleUriForTest(Uri.parse('file:///tmp/test.txt'));
      final state = container.read(opmlFileReceiverControllerProvider);
      check(state).isA<OpmlFileReceiverIdle>();
    });

    test('processes file:// URI with .opml extension', () async {
      // Write a temporary OPML file
      final tmpDir = Directory.systemTemp.createTempSync('opml_test');
      final file = File(p.join(tmpDir.path, 'test.opml'));
      file.writeAsStringSync(_validOpml);
      addTearDown(() => tmpDir.deleteSync(recursive: true));

      final notifier = container.read(
        opmlFileReceiverControllerProvider.notifier,
      );
      await notifier.handleUriForTest(Uri.file(file.path));
      final state = container.read(opmlFileReceiverControllerProvider);
      check(state).isA<OpmlFileReceiverSuccess>();
    });
  });

  group('content:// URI handling', () {
    test('reads content via platform channel', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('com.reedom.audiflow_app/content_resolver'),
            (call) async {
              if (call.method == 'readContentUri') {
                return _validOpml;
              }
              return null;
            },
          );
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('com.reedom.audiflow_app/content_resolver'),
              null,
            );
      });

      final notifier = container.read(
        opmlFileReceiverControllerProvider.notifier,
      );
      await notifier.handleUriForTest(
        Uri.parse('content://com.android.providers.downloads/document/123'),
      );
      final state = container.read(opmlFileReceiverControllerProvider);
      check(state).isA<OpmlFileReceiverSuccess>();
    });

    test('maps PlatformException to error state', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('com.reedom.audiflow_app/content_resolver'),
            (call) async {
              throw PlatformException(
                code: 'READ_FAILED',
                message: 'Could not read URI',
              );
            },
          );
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('com.reedom.audiflow_app/content_resolver'),
              null,
            );
      });

      final notifier = container.read(
        opmlFileReceiverControllerProvider.notifier,
      );
      await notifier.handleUriForTest(
        Uri.parse('content://com.android.providers.downloads/document/123'),
      );
      final state = container.read(opmlFileReceiverControllerProvider);
      check(state).isA<OpmlFileReceiverError>();
    });
  });
}

class _TestSubscriptionRepository extends FakeSubscriptionRepository {
  @override
  Future<bool> isSubscribedByFeedUrl(String feedUrl) async => false;
}

class _EmptyStreamHandler extends MockStreamHandler {
  @override
  void onListen(dynamic arguments, MockStreamHandlerEventSink events) {
    // No events — idle stream
  }

  @override
  void onCancel(dynamic arguments) {}
}
