import 'package:audiflow_app/features/podcast_detail/presentation/utils/play_pill_placement.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Mirrors the episode detail row: a 280 cap, and 110 of circles plus a
  // 10 gap reserved at the trailing edge.
  PlayPillPlacement place(double rowWidth, {double trailing = 120}) =>
      PlayPillPlacement.resolve(
        rowWidth: rowWidth,
        maxPillWidth: 280,
        trailingReserve: trailing,
      );

  group('PlayPillPlacement.resolve', () {
    test('centers the full pill when the row is wide enough', () {
      final placement = place(752);

      check(placement.width).equals(280);
      check(placement.start).equals((752 - 280) / 2);
    });

    test('centers exactly at the threshold width', () {
      final placement = place(520);

      check(placement.start).equals(120);
      check(placement.start + placement.width).equals(520 - 120);
    });

    test('slides toward the start to clear the trailing buttons', () {
      final placement = place(472);

      check(placement.width).equals(280);
      check(placement.start).equals(472 - 120 - 280);
    });

    test('settles at the start once only the pill fits', () {
      final placement = place(400);

      check(placement.width).equals(280);
      check(placement.start).equals(0);
    });

    test('shrinks the pill when the row cannot hold it at full width', () {
      final placement = place(350);

      check(placement.width).equals(230);
      check(placement.start).equals(0);
    });

    test('centers the pill alone when nothing trails it', () {
      final placement = place(350, trailing: 0);

      check(placement.width).equals(280);
      check(placement.start).equals(35);
    });

    test('never returns a negative width', () {
      final placement = place(100);

      check(placement.width).equals(0);
      check(placement.start).equals(0);
    });
  });
}
