import 'package:audiflow_core/audiflow_core.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PodcastCountries', () {
    test('all codes are 2 lowercase letters', () {
      final pattern = RegExp(r'^[a-z]{2}$');
      for (final code in PodcastCountries.all.keys) {
        check(pattern.hasMatch(code)).isTrue();
      }
    });

    test('contains common podcast markets', () {
      check(PodcastCountries.all.containsKey('us')).isTrue();
      check(PodcastCountries.all.containsKey('gb')).isTrue();
      check(PodcastCountries.all.containsKey('jp')).isTrue();
      check(PodcastCountries.all.containsKey('de')).isTrue();
      check(PodcastCountries.all.containsKey('au')).isTrue();
    });

    test('has no duplicate display names', () {
      final names = PodcastCountries.all.values.toList();
      check(names.toSet().length).equals(names.length);
    });

    test('extractCountryCode returns lowercase 2-letter code from locale', () {
      check(PodcastCountries.extractCountryCode('en_US')).equals('us');
      check(PodcastCountries.extractCountryCode('ja_JP')).equals('jp');
      check(PodcastCountries.extractCountryCode('en')).equals('us');
      check(PodcastCountries.extractCountryCode('')).equals('us');
    });

    test('extractCountryCode falls back to us for unknown locale', () {
      check(PodcastCountries.extractCountryCode('xx')).equals('us');
      check(PodcastCountries.extractCountryCode('zz_ZZ')).equals('us');
    });
  });
}
