import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EpisodeFilter', () {
    test('values are in menu order', () {
      check(EpisodeFilter.values).deepEquals([
        EpisodeFilter.all,
        EpisodeFilter.unplayed,
        EpisodeFilter.inProgress,
        EpisodeFilter.played,
        EpisodeFilter.downloaded,
      ]);
    });

    test('labels', () {
      check(EpisodeFilter.all.label).equals('All');
      check(EpisodeFilter.unplayed.label).equals('Unplayed');
      check(EpisodeFilter.inProgress.label).equals('In Progress');
      check(EpisodeFilter.played.label).equals('Played');
      check(EpisodeFilter.downloaded.label).equals('Downloaded');
    });
  });
}
