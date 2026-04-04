import 'package:checks/checks.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:test/test.dart';

void main() {
  group('PodcastSortOrder', () {
    test('has three values', () {
      check(PodcastSortOrder.values).length.equals(3);
    });

    test('fromName returns correct value for valid names', () {
      check(
        PodcastSortOrder.fromName('latestEpisode'),
      ).equals(PodcastSortOrder.latestEpisode);
      check(
        PodcastSortOrder.fromName('subscribedAt'),
      ).equals(PodcastSortOrder.subscribedAt);
      check(
        PodcastSortOrder.fromName('alphabetical'),
      ).equals(PodcastSortOrder.alphabetical);
    });

    test('fromName returns defaultValue for unknown names', () {
      check(
        PodcastSortOrder.fromName('unknown'),
      ).equals(PodcastSortOrder.latestEpisode);
      check(
        PodcastSortOrder.fromName(''),
      ).equals(PodcastSortOrder.latestEpisode);
    });

    test('fromName returns custom defaultValue when provided', () {
      check(
        PodcastSortOrder.fromName(
          'unknown',
          defaultValue: PodcastSortOrder.alphabetical,
        ),
      ).equals(PodcastSortOrder.alphabetical);
    });
  });
}
