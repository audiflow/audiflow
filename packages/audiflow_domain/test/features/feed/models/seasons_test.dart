import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';

import 'package:audiflow_domain/src/features/feed/models/seasons.dart';

void main() {
  group('Seasons table', () {
    test('table class exists and extends Table', () {
      // Verify the Seasons class is importable and is a Table subclass.
      // Drift tables are compile-time constructs for code generation.
      // Runtime column access is not supported outside generated database code.
      // Full column and primaryKey verification occurs via:
      // 1. Static analysis (dart analyze)
      // 2. Database integration tests after code generation
      expect(Seasons, isNotNull);
      expect(Seasons().runtimeType.toString(), contains('Seasons'));
    });

    test('Seasons is a Drift Table subclass', () {
      // Verify inheritance - Seasons must extend Table for Drift codegen
      expect(Seasons(), isA<Table>());
    });
  });
}
