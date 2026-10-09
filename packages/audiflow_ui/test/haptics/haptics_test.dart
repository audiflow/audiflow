import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingHapticPlayer implements HapticPlayer {
  final played = <HapticToken>[];
  final prepared = <HapticToken>[];

  @override
  void play(HapticToken token) => played.add(token);

  @override
  void prepare(HapticToken token) => prepared.add(token);
}

void _prepareAndPlayAll(HapticPlayer player) {
  for (final token in HapticToken.values) {
    player
      ..prepare(token)
      ..play(token);
  }
}

void main() {
  group('HapticToken', () {
    test('Reduced mode keeps exactly the tokens in the catalog', () {
      // docs/design/haptics.md section 2, "Reduced mode" column.
      final kept = HapticToken.values.where((t) => t.playsInReducedMode);
      check(kept.toSet()).deepEquals({
        HapticToken.thresholdCross,
        HapticToken.thresholdRelease,
        HapticToken.dragPickUp,
        HapticToken.success,
        HapticToken.warning,
        HapticToken.error,
      });
    });

    test('names are the platform channel contract', () {
      // The native handlers switch on these names; renaming one silently
      // turns that haptic into a no-op.
      check(HapticToken.values.map((t) => t.name).toList()).deepEquals([
        'selection',
        'toggleOn',
        'toggleOff',
        'tap',
        'longPress',
        'thresholdCross',
        'thresholdRelease',
        'dragPickUp',
        'dragStep',
        'dragDrop',
        'detent',
        'success',
        'warning',
        'error',
      ]);
    });
  });

  group('LevelGatedHapticPlayer', () {
    late _RecordingHapticPlayer inner;

    setUp(() => inner = _RecordingHapticPlayer());

    test('on plays and prepares every token', () {
      final player = LevelGatedHapticPlayer(
        level: HapticFeedbackLevel.on,
        inner: inner,
      );
      _prepareAndPlayAll(player);
      check(inner.played).deepEquals(HapticToken.values);
      check(inner.prepared).deepEquals(HapticToken.values);
    });

    test('reduced passes only tokens that play in Reduced mode', () {
      final player = LevelGatedHapticPlayer(
        level: HapticFeedbackLevel.reduced,
        inner: inner,
      );
      _prepareAndPlayAll(player);
      final expected = HapticToken.values
          .where((t) => t.playsInReducedMode)
          .toList();
      check(inner.played).deepEquals(expected);
      check(inner.prepared).deepEquals(expected);
    });

    test('off passes nothing', () {
      final player = LevelGatedHapticPlayer(
        level: HapticFeedbackLevel.off,
        inner: inner,
      );
      _prepareAndPlayAll(player);
      check(inner.played).isEmpty();
      check(inner.prepared).isEmpty();
    });
  });

  group('HapticToggle', () {
    test('plays toggleOn or toggleOff, then forwards the value', () {
      final player = _RecordingHapticPlayer();
      final values = <bool>[];
      final onChanged = player.toggleHaptic(values.add)!;

      onChanged(true);
      onChanged(false);

      check(
        player.played,
      ).deepEquals([HapticToken.toggleOn, HapticToken.toggleOff]);
      check(values).deepEquals([true, false]);
    });

    test('keeps a null callback null', () {
      check(_RecordingHapticPlayer().toggleHaptic(null)).isNull();
    });
  });

  group('HapticSelection', () {
    test('plays selection, then forwards the value', () {
      final player = _RecordingHapticPlayer();
      final values = <int>[];
      player.selectionHaptic<int>(values.add)!(3);

      check(player.played).deepEquals([HapticToken.selection]);
      check(values).deepEquals([3]);
    });

    test('keeps a null callback null', () {
      check(_RecordingHapticPlayer().selectionHaptic<int>(null)).isNull();
    });
  });

  group('HapticsScope', () {
    testWidgets('of returns a silent player when no scope is present', (
      tester,
    ) async {
      late HapticPlayer found;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            found = HapticsScope.of(context);
            return const SizedBox();
          },
        ),
      );
      check(found).isA<NoopHapticPlayer>();
    });

    testWidgets('of returns the nearest scope player', (tester) async {
      final player = _RecordingHapticPlayer();
      late HapticPlayer found;
      await tester.pumpWidget(
        HapticsScope(
          player: player,
          child: Builder(
            builder: (context) {
              found = HapticsScope.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      check(found).identicalTo(player);
    });

    testWidgets('dependents rebuild when the player changes', (tester) async {
      var builds = 0;
      final dependent = Builder(
        builder: (context) {
          HapticsScope.of(context);
          builds++;
          return const SizedBox();
        },
      );
      await tester.pumpWidget(
        HapticsScope(player: _RecordingHapticPlayer(), child: dependent),
      );
      await tester.pumpWidget(
        HapticsScope(player: _RecordingHapticPlayer(), child: dependent),
      );
      check(builds).equals(2);
    });
  });
}
