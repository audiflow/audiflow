import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EpisodeFilter', () {
    test('has exactly three values', () {
      expect(EpisodeFilter.values.length, 3);
    });

    test('contains all expected values', () {
      expect(EpisodeFilter.values, contains(EpisodeFilter.all));
      expect(EpisodeFilter.values, contains(EpisodeFilter.unplayed));
      expect(EpisodeFilter.values, contains(EpisodeFilter.inProgress));
    });

    test('all has label "All"', () {
      expect(EpisodeFilter.all.label, 'All');
    });

    test('unplayed has label "Unplayed"', () {
      expect(EpisodeFilter.unplayed.label, 'Unplayed');
    });

    test('inProgress has label "In Progress"', () {
      expect(EpisodeFilter.inProgress.label, 'In Progress');
    });

    test('values are in expected order', () {
      expect(EpisodeFilter.values[0], EpisodeFilter.all);
      expect(EpisodeFilter.values[1], EpisodeFilter.unplayed);
      expect(EpisodeFilter.values[2], EpisodeFilter.inProgress);
    });
  });
}
