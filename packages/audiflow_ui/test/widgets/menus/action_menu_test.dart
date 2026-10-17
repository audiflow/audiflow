import 'dart:async';

import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';

List<ActionMenuEntry> _tiles(List<String> log) => [
  ActionMenuEntry(
    icon: Icons.remove_circle_outline,
    label: 'Unsubscribe',
    onSelected: () => log.add('unsubscribe'),
  ),
  ActionMenuEntry(
    icon: Icons.ios_share,
    label: 'Share',
    onSelected: () => log.add('share'),
  ),
];

List<List<ActionMenuEntry>> _sections(List<String> log) => [
  [
    ActionMenuEntry(
      icon: Icons.sort,
      label: 'Play order',
      onSelected: () => log.add('order'),
    ),
    ActionMenuEntry(
      icon: Icons.block,
      label: 'Unavailable',
      enabled: false,
      onSelected: () => log.add('unavailable'),
    ),
  ],
  [
    ActionMenuEntry(
      icon: Icons.link,
      label: 'Website',
      onSelected: () => log.add('web'),
    ),
    ActionMenuEntry(
      icon: Icons.delete_outline,
      label: 'Remove',
      destructive: true,
      onSelected: () => log.add('remove'),
    ),
  ],
];

class _RecordingHapticPlayer implements HapticPlayer {
  final played = <HapticToken>[];

  @override
  void play(HapticToken token) => played.add(token);

  @override
  void prepare(HapticToken token) {}
}

void main() {
  /// Pumps a trigger labelled `open` at [triggerAlignment] that opens the
  /// sample menu at [placementOf] (the `…` spot under y=[top] by default).
  Future<void> pumpTrigger(
    WidgetTester tester, {
    required List<String> log,
    double top = 100,
    Alignment triggerAlignment = Alignment.center,
    ActionMenuPlacement Function(BuildContext anchor)? placementOf,
    List<List<ActionMenuEntry>>? sections,
    HapticPlayer haptics = const NoopHapticPlayer(),
  }) async {
    await tester.pumpWidget(
      HapticsScope(
        player: haptics,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Align(
              alignment: triggerAlignment,
              child: ActionMenuTrigger(
                onOpen: (anchor, drag) => showActionMenu(
                  context: anchor,
                  placement:
                      placementOf?.call(anchor) ??
                      ActionMenuPlacement.topRight(top: top),
                  tiles: sections == null ? _tiles(log) : const [],
                  sections: sections ?? _sections(log),
                  drag: drag,
                ),
                builder: (context, open) =>
                    TextButton(onPressed: open, child: const Text('open')),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> open(
    WidgetTester tester, {
    required List<String> log,
    double top = 100,
    HapticPlayer haptics = const NoopHapticPlayer(),
  }) async {
    await pumpTrigger(tester, log: log, top: top, haptics: haptics);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  /// Pushes a second screen over the trigger's and opens its menu there;
  /// returns the navigator.
  Future<NavigatorState> openOnSecondScreen(
    WidgetTester tester, {
    required List<String> log,
  }) async {
    await pumpTrigger(tester, log: log);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    unawaited(
      navigator.push(
        MaterialPageRoute<void>(
          builder: (context) => Scaffold(
            body: ActionMenuTrigger(
              onOpen: (anchor, drag) => showActionMenu(
                context: anchor,
                placement: const ActionMenuPlacement.topRight(top: 100),
                sections: _sections(log),
              ),
              builder: (context, open) =>
                  TextButton(onPressed: open, child: const Text('second')),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('second'));
    await tester.pumpAndSettle();
    return navigator;
  }

  /// Presses `open` and holds until the menu is up; returns the finger.
  Future<TestGesture> holdOpen(WidgetTester tester) async {
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('open')),
    );
    await tester.pump(
      ActionMenuTrigger.holdDuration + const Duration(milliseconds: 10),
    );
    await tester.pumpAndSettle();
    return gesture;
  }

  group('showActionMenu', () {
    testWidgets('shows tiles side by side above the item rows', (tester) async {
      await open(tester, log: []);
      final unsubscribe = tester.getCenter(find.text('Unsubscribe'));
      final share = tester.getCenter(find.text('Share'));
      final order = tester.getCenter(find.text('Play order'));
      check(share.dy).equals(unsubscribe.dy);
      check(unsubscribe.dx).isLessThan(share.dx);
      check(unsubscribe.dy).isLessThan(order.dy);
      check(
        find.byType(Divider).evaluate(),
      ).length.equals(2); // after the tiles, and between the sections
    });

    testWidgets('sits under the given top edge on a floating surface', (
      tester,
    ) async {
      await open(tester, log: [], top: 120);
      final surface = find.byKey(ActionMenu.surfaceKey);
      check(tester.getTopRight(surface).dy).isGreaterOrEqual(120);
      final decoration =
          tester.widget<DecoratedBox>(surface).decoration as BoxDecoration;
      check(decoration.color).equals(AppColors.light.surface);
      check(decoration.boxShadow).isNotNull().deepEquals(AppShadows.floating);
    });

    testWidgets('selecting an entry closes the menu, then runs it', (
      tester,
    ) async {
      final log = <String>[];
      await open(tester, log: log);
      await tester.tap(find.text('Play order'));
      await tester.pumpAndSettle();
      check(log).deepEquals(['order']);
      check(find.text('Play order').evaluate()).isEmpty();

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();
      check(log).deepEquals(['order', 'share']);
    });

    testWidgets('a destructive entry is drawn in the error color', (
      tester,
    ) async {
      await open(tester, log: []);
      final error = AppTheme.light().colorScheme.error;
      final remove = tester.widget<Text>(find.text('Remove'));
      final website = tester.widget<Text>(find.text('Website'));
      check(remove.style?.color).equals(error);
      check(website.style?.color).equals(AppColors.light.ink);
      check(
        tester.widget<Icon>(find.byIcon(Icons.delete_outline)).color,
      ).equals(error);
    });

    testWidgets('tapping outside dismisses without running anything', (
      tester,
    ) async {
      final log = <String>[];
      await open(tester, log: log);
      await tester.tapAt(const Offset(10, 580));
      await tester.pumpAndSettle();
      check(find.text('Play order').evaluate()).isEmpty();
      check(log).isEmpty();
    });

    testWidgets('the back gesture closes the menu, not the screen', (
      tester,
    ) async {
      final log = <String>[];
      await openOnSecondScreen(tester, log: log);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      check(find.byKey(ActionMenu.surfaceKey).evaluate()).isEmpty();
      check(find.text('second').evaluate()).isNotEmpty();
      check(log).isEmpty();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      check(find.text('second').evaluate()).isEmpty();
    });

    testWidgets('closes when its screen is popped from elsewhere', (
      tester,
    ) async {
      final log = <String>[];
      final navigator = await openOnSecondScreen(tester, log: log);

      navigator.pop();
      await tester.pumpAndSettle();
      check(find.byKey(ActionMenu.surfaceKey).evaluate()).isEmpty();
      check(find.text('open').evaluate()).isNotEmpty();
      check(log).isEmpty();
    });

    testWidgets('closes when another screen covers its own', (tester) async {
      final log = <String>[];
      await open(tester, log: log);
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      unawaited(
        navigator.push(
          MaterialPageRoute<void>(
            builder: (context) => const Scaffold(body: Text('covering')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      check(find.byKey(ActionMenu.surfaceKey).evaluate()).isEmpty();
      check(find.text('covering').evaluate()).isNotEmpty();
      check(log).isEmpty();
    });

    testWidgets('a root screen over a nested navigator covers the menu', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (context) => Scaffold(
                body: Center(
                  child: ActionMenuTrigger(
                    onOpen: (anchor, drag) => showActionMenu(
                      context: anchor,
                      placement: const ActionMenuPlacement.topRight(top: 100),
                      sections: _sections([]),
                    ),
                    builder: (context, open) =>
                        TextButton(onPressed: open, child: const Text('open')),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final root = tester.state<NavigatorState>(find.byType(Navigator).first);
      unawaited(
        root.push(
          MaterialPageRoute<void>(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('covering'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      check(
        find.byKey(ActionMenu.surfaceKey).hitTestable().evaluate(),
      ).isEmpty();
      await tester.tap(find.text('covering'));
      await tester.pumpAndSettle();
      check(find.text('covering').evaluate()).isEmpty();
    });

    testWidgets('Escape closes the menu', (tester) async {
      final log = <String>[];
      await open(tester, log: log);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      check(find.byKey(ActionMenu.surfaceKey).evaluate()).isEmpty();
      check(log).isEmpty();
    });

    testWidgets('a disabled entry is faded and cannot be tapped', (
      tester,
    ) async {
      final log = <String>[];
      await open(tester, log: log);
      check(
        tester.widget<Text>(find.text('Unavailable')).style?.color,
      ).equals(AppColors.light.inkTertiary);
      await tester.tap(find.text('Unavailable'));
      await tester.pumpAndSettle();
      check(log).isEmpty();
      check(find.text('Unavailable').evaluate()).isNotEmpty();
    });

    testWidgets('a checked entry is drawn in accent with a check', (
      tester,
    ) async {
      await pumpTrigger(
        tester,
        log: [],
        sections: [
          [
            ActionMenuEntry(label: 'Newest', checked: true, onSelected: () {}),
            ActionMenuEntry(label: 'Oldest', onSelected: () {}),
          ],
        ],
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      check(
        tester.widget<Text>(find.text('Newest')).style?.color,
      ).equals(AppColors.light.accent);
      check(
        tester.widget<Text>(find.text('Oldest')).style?.color,
      ).equals(AppColors.light.ink);
      check(find.byIcon(Icons.check_rounded).evaluate()).length.equals(1);
    });
  });

  group('press, slide, and release', () {
    testWidgets('holding the trigger opens the menu under the finger', (
      tester,
    ) async {
      await pumpTrigger(tester, log: []);
      final gesture = await holdOpen(tester);
      check(find.byKey(ActionMenu.surfaceKey).evaluate()).length.equals(1);
      await gesture.up();
    });

    testWidgets('releasing on an item chooses it and closes the menu', (
      tester,
    ) async {
      final log = <String>[];
      await pumpTrigger(tester, log: log);
      final gesture = await holdOpen(tester);
      await gesture.moveTo(tester.getCenter(find.text('Website')));
      await tester.pump();
      await gesture.moveTo(tester.getCenter(find.text('Play order')));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      check(log).deepEquals(['order']);
      check(find.byKey(ActionMenu.surfaceKey).evaluate()).isEmpty();
    });

    testWidgets('releasing on a tile chooses it', (tester) async {
      final log = <String>[];
      await pumpTrigger(tester, log: log);
      final gesture = await holdOpen(tester);
      await gesture.moveTo(tester.getCenter(find.text('Share')));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      check(log).deepEquals(['share']);
    });

    testWidgets('releasing outside keeps the menu open for a tap', (
      tester,
    ) async {
      final log = <String>[];
      await pumpTrigger(tester, log: log);
      final gesture = await holdOpen(tester);
      await gesture.moveTo(tester.getCenter(find.text('Website')));
      await tester.pump();
      await gesture.moveTo(const Offset(10, 580));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      check(log).isEmpty();
      check(find.byKey(ActionMenu.surfaceKey).evaluate()).length.equals(1);

      await tester.tap(find.text('Website'));
      await tester.pumpAndSettle();
      check(log).deepEquals(['web']);
    });

    testWidgets('releasing on the trigger keeps one menu open', (tester) async {
      final log = <String>[];
      await pumpTrigger(tester, log: log);
      final gesture = await holdOpen(tester);
      await gesture.up();
      await tester.pumpAndSettle();
      check(log).isEmpty();
      check(find.byKey(ActionMenu.surfaceKey).evaluate()).length.equals(1);
    });

    testWidgets('a cancelled gesture keeps the menu open', (tester) async {
      final log = <String>[];
      await pumpTrigger(tester, log: log);
      final gesture = await holdOpen(tester);
      await gesture.moveTo(tester.getCenter(find.text('Website')));
      await tester.pump();
      await gesture.cancel();
      await tester.pumpAndSettle();
      check(log).isEmpty();
      check(find.byKey(ActionMenu.surfaceKey).evaluate()).length.equals(1);
    });

    testWidgets('releasing on a disabled entry chooses nothing', (
      tester,
    ) async {
      final log = <String>[];
      await pumpTrigger(tester, log: log);
      final gesture = await holdOpen(tester);
      await gesture.moveTo(tester.getCenter(find.text('Unavailable')));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      check(log).isEmpty();
      check(find.byKey(ActionMenu.surfaceKey).evaluate()).length.equals(1);
    });

    testWidgets('releasing below a scrolled menu chooses nothing', (
      tester,
    ) async {
      final log = <String>[];
      await pumpTrigger(
        tester,
        log: log,
        triggerAlignment: const Alignment(-0.8, -0.9),
        placementOf: ActionMenuPlacement.below,
        sections: [
          [
            for (var index = 0; index < 30; index++)
              ActionMenuEntry(
                label: 'Row $index',
                onSelected: () => log.add('row $index'),
              ),
          ],
        ],
      );
      final gesture = await holdOpen(tester);
      final menu = tester.getRect(find.byKey(ActionMenu.surfaceKey));
      final screen = tester.getRect(find.byType(Scaffold));
      final belowMenu = Offset(
        menu.center.dx,
        (menu.bottom + screen.bottom) / 2,
      );
      check(menu.bottom).isLessThan(belowMenu.dy);
      await gesture.moveTo(belowMenu);
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      check(log).isEmpty();
      check(find.byKey(ActionMenu.surfaceKey).evaluate()).length.equals(1);
    });

    testWidgets('plays a selection haptic each time the highlight moves', (
      tester,
    ) async {
      final haptics = _RecordingHapticPlayer();
      await pumpTrigger(tester, log: [], haptics: haptics);
      final gesture = await holdOpen(tester);
      check(haptics.played).isEmpty();

      final website = tester.getRect(find.text('Website'));
      await gesture.moveTo(website.centerLeft);
      await tester.pump();
      await gesture.moveTo(website.center); // same item
      await tester.pump();
      await gesture.moveTo(tester.getCenter(find.text('Unavailable')));
      await tester.pump();
      await gesture.moveTo(const Offset(10, 580)); // off the menu
      await tester.pump();
      await gesture.moveTo(tester.getCenter(find.text('Share')));
      await tester.pump();

      check(
        haptics.played,
      ).deepEquals([HapticToken.selection, HapticToken.selection]);
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('a plain tap plays no haptic', (tester) async {
      final haptics = _RecordingHapticPlayer();
      await open(tester, log: [], haptics: haptics);
      check(haptics.played).isEmpty();
    });
  });

  group('ActionMenuPlacement.below', () {
    testWidgets('opens under a trigger on the left, aligned to its left', (
      tester,
    ) async {
      await pumpTrigger(
        tester,
        log: [],
        triggerAlignment: const Alignment(-0.8, -0.5),
        placementOf: ActionMenuPlacement.below,
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final trigger = tester.getRect(find.byType(TextButton));
      final menu = tester.getRect(find.byKey(ActionMenu.surfaceKey));
      check(trigger.bottom).isLessOrEqual(menu.top);
      check(menu.left).equals(trigger.left);
    });

    testWidgets('aligns to the right edge of a trigger on the right', (
      tester,
    ) async {
      await pumpTrigger(
        tester,
        log: [],
        triggerAlignment: const Alignment(0.8, -0.5),
        placementOf: ActionMenuPlacement.below,
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final trigger = tester.getRect(find.byType(TextButton));
      final menu = tester.getRect(find.byKey(ActionMenu.surfaceKey));
      check(menu.right).equals(trigger.right);
    });

    testWidgets('opens above a trigger with no room below', (tester) async {
      await pumpTrigger(
        tester,
        log: [],
        triggerAlignment: Alignment.bottomCenter,
        placementOf: ActionMenuPlacement.below,
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final trigger = tester.getRect(find.byType(TextButton));
      final menu = tester.getRect(find.byKey(ActionMenu.surfaceKey));
      check(menu.bottom).isLessOrEqual(trigger.top);
    });

    testWidgets('stays clear of the status bar under a SafeArea', (
      tester,
    ) async {
      tester.view.padding = FakeViewPadding(
        top: 50 * tester.view.devicePixelRatio,
      );
      addTearDown(tester.view.resetPadding);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: ActionMenuTrigger(
                  onOpen: (anchor, drag) => showActionMenu(
                    context: anchor,
                    placement: ActionMenuPlacement.below(anchor),
                    sections: [
                      [
                        for (var index = 0; index < 30; index++)
                          ActionMenuEntry(
                            label: 'Row $index',
                            onSelected: () {},
                          ),
                      ],
                    ],
                  ),
                  builder: (context, open) =>
                      TextButton(onPressed: open, child: const Text('open')),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final menu = tester.getRect(find.byKey(ActionMenu.surfaceKey));
      check(50.0).isLessOrEqual(menu.top);
    });

    testWidgets('sizes to its entries within the menu width', (tester) async {
      await pumpTrigger(
        tester,
        log: [],
        triggerAlignment: const Alignment(-0.8, -0.5),
        placementOf: ActionMenuPlacement.below,
        sections: [
          [ActionMenuEntry(label: 'A', onSelected: () {})],
        ],
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final width = tester.getSize(find.byKey(ActionMenu.surfaceKey)).width;
      check(width).equals(ActionMenu.minAnchoredWidth);
    });
  });
}
