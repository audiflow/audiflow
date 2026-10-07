import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Widget child, {ThemeData? theme}) => MaterialApp(
    theme: theme ?? AppTheme.light(),
    home: Scaffold(body: ListView(children: [child])),
  );

  group('SettingsRow layout', () {
    testWidgets('is at least 54 tall without a subtitle', (tester) async {
      await tester.pumpWidget(host(const SettingsRow(title: 'Appearance')));
      check(
        tester.getSize(find.byType(SettingsRow)).height,
      ).isGreaterOrEqual(54);
    });

    testWidgets('is at least 60 tall with a subtitle', (tester) async {
      await tester.pumpWidget(
        host(const SettingsRow(title: 'Appearance', subtitle: 'Theme, text')),
      );
      check(
        tester.getSize(find.byType(SettingsRow)).height,
      ).isGreaterOrEqual(60);
      final subtitle = tester.widget<Text>(find.text('Theme, text'));
      check(subtitle.style!.color).equals(AppColors.light.inkSecondary);
      check(subtitle.maxLines).equals(1);
    });

    testWidgets('icon tile is 32px, accent glyph on accent tint', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const SettingsRow(title: 'Downloads', icon: Icons.download)),
      );
      final tile = find.byKey(SettingsRow.iconTileKey);
      check(tester.getSize(tile)).equals(const Size(32, 32));
      final decoration =
          tester.widget<DecoratedBox>(tile).decoration as BoxDecoration;
      check(decoration.color).equals(AppColors.light.accentTint);
      check(
        tester.widget<Icon>(find.byIcon(Icons.download)).color,
      ).equals(AppColors.light.accent);
    });

    testWidgets('no icon tile when icon is null', (tester) async {
      await tester.pumpWidget(host(const SettingsRow(title: 'Plain')));
      check(find.byKey(SettingsRow.iconTileKey).evaluate().length).equals(0);
    });

    testWidgets('long titles ellipsize instead of overflowing', (tester) async {
      await tester.pumpWidget(
        host(
          SettingsRow(
            title: 'Very long title ' * 20,
            trailing: const SettingsTrailing.picker(value: 'Newest first'),
            onTap: () {},
          ),
        ),
      );
      check(tester.takeException()).isNull();
    });
  });

  group('SettingsTrailing.chevron', () {
    testWidgets('shows a quaternary chevron and fires onTap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        host(
          SettingsRow(
            title: 'About',
            trailing: const SettingsTrailing.chevron(),
            onTap: () => taps++,
          ),
        ),
      );
      final chevron = tester.widget<Icon>(
        find.byIcon(Icons.chevron_right_rounded),
      );
      check(chevron.color).equals(AppColors.light.inkQuaternary);
      await tester.tap(find.text('About'));
      check(taps).equals(1);
    });
  });

  group('SettingsTrailing.picker', () {
    testWidgets('shows the value and an up/down chevron', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        host(
          SettingsRow(
            title: 'Play order',
            trailing: const SettingsTrailing.picker(value: 'Oldest first'),
            onTap: () => taps++,
          ),
        ),
      );
      final value = tester.widget<Text>(find.text('Oldest first'));
      check(value.style!.color).equals(AppColors.light.inkSecondary);
      check(find.byIcon(Icons.unfold_more_rounded).evaluate().length).equals(1);
      await tester.tap(find.text('Oldest first'));
      check(taps).equals(1);
    });
  });

  group('SettingsTrailing.toggle', () {
    testWidgets('renders a switch reflecting value', (tester) async {
      await tester.pumpWidget(
        host(
          SettingsRow(
            title: 'Skip silence',
            trailing: SettingsTrailing.toggle(value: true, onChanged: (_) {}),
          ),
        ),
      );
      check(tester.widget<Switch>(find.byType(Switch)).value).isTrue();
    });

    testWidgets('tapping the row toggles', (tester) async {
      bool? changed;
      await tester.pumpWidget(
        host(
          SettingsRow(
            title: 'Skip silence',
            trailing: SettingsTrailing.toggle(
              value: false,
              onChanged: (value) => changed = value,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Skip silence'));
      check(changed).equals(true);
    });

    testWidgets('tapping the switch itself fires once', (tester) async {
      final changes = <bool>[];
      await tester.pumpWidget(
        host(
          SettingsRow(
            title: 'Skip silence',
            trailing: SettingsTrailing.toggle(
              value: false,
              onChanged: changes.add,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(Switch));
      check(changes).deepEquals([true]);
    });

    testWidgets('null onChanged disables the switch and the row', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const SettingsRow(
            title: 'Locked',
            trailing: SettingsTrailing.toggle(value: false, onChanged: null),
          ),
        ),
      );
      check(tester.widget<Switch>(find.byType(Switch)).onChanged).isNull();
      await tester.tap(find.text('Locked'));
      check(tester.takeException()).isNull();
    });

    testWidgets('row and switch merge into one semantics node', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          SettingsRow(
            title: 'Voice boost',
            trailing: SettingsTrailing.toggle(value: true, onChanged: (_) {}),
          ),
        ),
      );
      final node = tester.getSemantics(find.byType(Switch));
      check(node.label).contains('Voice boost');
      handle.dispose();
    });
  });

  group('SettingsTrailing.stepper', () {
    Widget stepper({VoidCallback? onDecrement, VoidCallback? onIncrement}) {
      return host(
        SettingsRow(
          title: 'Speed',
          trailing: SettingsTrailing.stepper(
            valueLabel: '1.2x',
            decrementLabel: 'Slower',
            incrementLabel: 'Faster',
            onDecrement: onDecrement,
            onIncrement: onIncrement,
          ),
        ),
      );
    }

    testWidgets('shows the value with tabular figures', (tester) async {
      await tester.pumpWidget(stepper(onDecrement: () {}, onIncrement: () {}));
      check(
        tester.widget<Text>(find.text('1.2x')).style!.fontFeatures,
      ).isNotNull().contains(const FontFeature.tabularFigures());
    });

    testWidgets('buttons fire their callbacks', (tester) async {
      var down = 0;
      var up = 0;
      await tester.pumpWidget(
        stepper(onDecrement: () => down++, onIncrement: () => up++),
      );
      await tester.tap(find.byTooltip('Slower'));
      await tester.tap(find.byTooltip('Faster'));
      await tester.tap(find.byTooltip('Faster'));
      check(down).equals(1);
      check(up).equals(2);
    });

    testWidgets('buttons meet the 44px touch target', (tester) async {
      await tester.pumpWidget(stepper(onDecrement: () {}, onIncrement: () {}));
      for (final label in ['Slower', 'Faster']) {
        final size = tester.getSize(find.byTooltip(label));
        check(size.width).isGreaterOrEqual(44);
        check(size.height).isGreaterOrEqual(44);
      }
    });

    testWidgets('null callback disables that button only', (tester) async {
      await tester.pumpWidget(stepper(onIncrement: () {}));
      final buttons = tester.widgetList<IconButton>(find.byType(IconButton));
      check(buttons.first.onPressed).isNull();
      check(buttons.last.onPressed).isNotNull();
    });
  });
}
