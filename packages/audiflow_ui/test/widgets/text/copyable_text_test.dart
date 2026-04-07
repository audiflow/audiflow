import 'package:audiflow_ui/src/widgets/text/copyable_text.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CopyableText', () {
    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    testWidgets('renders text value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CopyableText(text: '42', snackBarMessage: 'Copied'),
          ),
        ),
      );

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('renders label when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CopyableText(
              text: '42',
              label: 'Episode',
              snackBarMessage: 'Copied',
            ),
          ),
        ),
      );

      expect(find.text('Episode'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('renders copy icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CopyableText(text: '42', snackBarMessage: 'Copied'),
          ),
        ),
      );

      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
    });

    testWidgets('copies text to clipboard on tap', (tester) async {
      String? clipboardData;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.setData') {
            final args = call.arguments as Map<String, dynamic>;
            clipboardData = args['text'] as String;
          }
          return null;
        },
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CopyableText(text: 'test-value', snackBarMessage: 'Copied'),
          ),
        ),
      );

      await tester.tap(find.byType(CopyableText));
      await tester.pump();

      check(clipboardData).equals('test-value');
    });

    testWidgets('shows snackbar after copy', (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async => null,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CopyableText(text: 'value', snackBarMessage: 'Copied'),
          ),
        ),
      );

      await tester.tap(find.byType(CopyableText));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('copies only text, not label', (tester) async {
      String? clipboardData;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.setData') {
            final args = call.arguments as Map<String, dynamic>;
            clipboardData = args['text'] as String;
          }
          return null;
        },
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CopyableText(
              text: '42',
              label: 'Episode',
              snackBarMessage: 'Copied',
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CopyableText));
      await tester.pump();

      check(clipboardData).equals('42');
    });

    testWidgets('applies custom text style', (tester) async {
      const style = TextStyle(fontSize: 20, color: Colors.red);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CopyableText(
              text: '42',
              style: style,
              snackBarMessage: 'Copied',
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('42'));
      check(textWidget.style?.fontSize).equals(20.0);
    });
  });
}
