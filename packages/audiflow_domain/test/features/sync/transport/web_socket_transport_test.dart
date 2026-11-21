import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;

void main() {
  group('connectUri', () {
    test('https becomes wss under the base path', () {
      check(
        WebSocketTransport.connectUri(
          Uri.parse('https://relay.example.com/'),
          'abc',
        ).toString(),
      ).equals('wss://relay.example.com/v1/connect?account=abc');
    });

    test('a local http relay uses ws and keeps its port and path', () {
      check(
        WebSocketTransport.connectUri(
          Uri.parse('http://localhost:8787/base'),
          'abc',
        ).toString(),
      ).equals('ws://localhost:8787/base/v1/connect?account=abc');
    });

    test('cleartext to anywhere but a local relay is refused', () {
      check(
        () => WebSocketTransport.connectUri(
          Uri.parse('http://relay.example.com'),
          'abc',
        ),
      ).throws<ArgumentError>();
    });

    test('other schemes are refused', () {
      check(
        () => WebSocketTransport.connectUri(Uri.parse('ftp://x'), 'abc'),
      ).throws<ArgumentError>();
    });
  });

  group('over a socket', () {
    late HttpServer server;
    late Completer<WebSocket> accepted;

    setUp(() async {
      accepted = Completer();
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        accepted.complete(await WebSocketTransformer.upgrade(request));
      });
    });

    tearDown(() => server.close(force: true));

    Future<WebSocketTransport> open() => WebSocketTransport.connect(
      Uri.parse('http://127.0.0.1:${server.port}'),
      'abc',
    );

    test('carries messages both ways', () async {
      final transport = await open();
      final socket = await accepted.future;
      final received = socket.first;

      transport.send(
        UploadSnapshot(RelaySnapshot(coversSeq: 0, blob: Uint8List(0))),
      );
      socket.add('{"type":"stored","coversSeq":3}');

      check(await received).isA<String>().contains('"type":"snapshot"');
      check(await transport.messages.first).isA<SnapshotStored>();
      await transport.close();
    });

    test('a wrongly typed field is a stream error', () async {
      final transport = await open();
      final socket = await accepted.future;

      socket.add('{"type":"stored","coversSeq":"three"}');

      await check(transport.messages.first).throws<FormatException>();
      await transport.close();
    });
  });

  test('an upgrade that never answers times out', () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    // Accepts the TCP connection and never replies.
    final held = <Socket>[];
    server.listen(held.add);
    addTearDown(() async {
      for (final s in held) {
        s.destroy();
      }
      await server.close();
    });

    await check(
      WebSocketTransport.connect(
        Uri.parse('http://127.0.0.1:${server.port}'),
        'abc',
        timeout: const Duration(milliseconds: 100),
      ),
    ).throws<TimeoutException>();
  });
}
