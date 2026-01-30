import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';

import 'package:audiflow_domain/src/features/feed/models/smart_playlists.dart';

void main() {
  group('SmartPlaylists table', () {
    test('table class exists and extends Table', () {
      expect(SmartPlaylists, isNotNull);
      expect(
        SmartPlaylists().runtimeType.toString(),
        contains('SmartPlaylists'),
      );
    });

    test('SmartPlaylists is a Drift Table subclass', () {
      expect(SmartPlaylists(), isA<Table>());
    });
  });
}
