import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromString parses all valid values', () {
    check(
      StationPodcastSort.fromString('subscribe_asc'),
    ).equals(StationPodcastSort.subscribeAsc);
    check(
      StationPodcastSort.fromString('subscribe_desc'),
    ).equals(StationPodcastSort.subscribeDesc);
    check(
      StationPodcastSort.fromString('name_asc'),
    ).equals(StationPodcastSort.nameAsc);
    check(
      StationPodcastSort.fromString('name_desc'),
    ).equals(StationPodcastSort.nameDesc);
    check(
      StationPodcastSort.fromString('manual'),
    ).equals(StationPodcastSort.manual);
  });

  test('fromString defaults to manual for unknown values', () {
    check(
      StationPodcastSort.fromString('unknown'),
    ).equals(StationPodcastSort.manual);
    check(StationPodcastSort.fromString('')).equals(StationPodcastSort.manual);
  });

  test('storedValue returns correct string', () {
    check(StationPodcastSort.subscribeAsc.storedValue).equals('subscribe_asc');
    check(
      StationPodcastSort.subscribeDesc.storedValue,
    ).equals('subscribe_desc');
    check(StationPodcastSort.nameAsc.storedValue).equals('name_asc');
    check(StationPodcastSort.nameDesc.storedValue).equals('name_desc');
    check(StationPodcastSort.manual.storedValue).equals('manual');
  });
}
