import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal valid 1x1 transparent PNG used as a stub response
/// so widget tests never perform real HTTP image requests.
final Uint8List _transparentPixelPng = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, // 1x1
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, // RGBA
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, // IDAT chunk
  0x54, 0x78, 0x9C, 0x62, 0x00, 0x00, 0x00, 0x02,
  0x00, 0x01, 0xE5, 0x27, 0xDE, 0xFC, 0x00, 0x00, // compressed data
  0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, // IEND chunk
  0x60, 0x82,
]);

/// Returns a fake [HttpClient] that responds to every request with a
/// 1x1 transparent PNG, preventing real network calls in widget tests.
class _FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _FakeHttpClient();
  }
}

class _FakeHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Duration? connectionTimeout;

  @override
  Duration idleTimeout = const Duration(seconds: 15);

  @override
  int? maxConnectionsPerHost;

  @override
  String? userAgent;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpClientRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _FakeHttpClientRequest();

  @override
  Future<HttpClientRequest> headUrl(Uri url) async => _FakeHttpClientRequest();

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientRequest implements HttpClientRequest {
  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  @override
  Encoding encoding = utf8;

  @override
  Uri get uri => Uri.parse('https://example.com');

  @override
  Future<HttpClientResponse> close() async => _FakeHttpClientResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => _transparentPixelPng.length;

  @override
  HttpHeaders get headers => _FakeHttpHeaders();

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_transparentPixelPng).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpHeaders implements HttpHeaders {
  @override
  List<String>? operator [](String name) => null;

  @override
  String? value(String name) => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    HttpOverrides.global = _FakeHttpOverrides();
  });

  tearDown(() {
    HttpOverrides.global = null;
  });

  group('ArtworkOverlay', () {
    const imageUrl = 'https://example.com/artwork.jpg';
    const heroTag = 'test_hero';

    Widget buildSubject() {
      return MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder<void>(
                      opaque: false,
                      barrierDismissible: true,
                      barrierColor: Colors.black87,
                      // Use zero duration to avoid animation timeouts
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return const ArtworkOverlay(
                          imageUrl: imageUrl,
                          heroTag: heroTag,
                        );
                      },
                    ),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );
    }

    testWidgets('displays overlay when opened', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Open'));
      await tester.pump();

      check(find.byType(ArtworkOverlay).evaluate()).isNotEmpty();
      check(find.byType(ExtendedImage).evaluate()).isNotEmpty();
      check(find.byType(Hero).evaluate()).isNotEmpty();
    });

    testWidgets('dismisses when tapping background', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Open'));
      await tester.pump();

      // Verify overlay is visible
      check(find.byType(ArtworkOverlay).evaluate()).isNotEmpty();

      // Tap the background (top-left corner, outside the centered artwork)
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();

      // Overlay should be dismissed
      check(find.byType(ArtworkOverlay).evaluate()).isEmpty();
    });

    testWidgets('does not dismiss when tapping artwork area', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Open'));
      await tester.pump();

      // Tap the center of the screen (where the artwork is)
      final center = tester.getCenter(find.byType(ArtworkOverlay));
      await tester.tapAt(center);
      await tester.pump();

      // Overlay should still be visible
      check(find.byType(ArtworkOverlay).evaluate()).isNotEmpty();
    });

    testWidgets('renders ClipRRect with border radius', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Open'));
      await tester.pump();

      final clipRRect = tester.widget<ClipRRect>(
        find.descendant(
          of: find.byType(ArtworkOverlay),
          matching: find.byType(ClipRRect),
        ),
      );
      check(clipRRect.borderRadius).equals(AppBorders.lg);
    });
  });
}
