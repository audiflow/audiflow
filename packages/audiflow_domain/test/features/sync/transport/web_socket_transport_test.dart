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

    test('other schemes are refused', () {
      check(
        () => WebSocketTransport.connectUri(Uri.parse('ftp://x'), 'abc'),
      ).throws<ArgumentError>();
    });
  });
}
