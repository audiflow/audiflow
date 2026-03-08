import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('holds data', () {
        const result = Success(42);
        expect(result.data, 42);
      });

      test('holds null data', () {
        const result = Success<int?>(null);
        expect(result.data, isNull);
      });

      test('holds string data', () {
        const result = Success('hello');
        expect(result.data, 'hello');
      });

      test('holds empty string', () {
        const result = Success('');
        expect(result.data, '');
      });

      test('is subtype of Result', () {
        const Result<int> result = Success(1);
        expect(result, isA<Success<int>>());
      });
    });

    group('Failure', () {
      test('holds error', () {
        final result = Failure<int>(Exception('oops'));
        expect(result.error, isA<Exception>());
      });

      test('holds string error', () {
        const result = Failure<int>('error message');
        expect(result.error, 'error message');
      });

      test('is subtype of Result', () {
        const Result<int> result = Failure('err');
        expect(result, isA<Failure<int>>());
      });
    });

    group('isSuccess', () {
      test('returns true for Success', () {
        const Result<int> result = Success(1);
        expect(result.isSuccess, isTrue);
      });

      test('returns false for Failure', () {
        const Result<int> result = Failure('err');
        expect(result.isSuccess, isFalse);
      });
    });

    group('isFailure', () {
      test('returns true for Failure', () {
        const Result<int> result = Failure('err');
        expect(result.isFailure, isTrue);
      });

      test('returns false for Success', () {
        const Result<int> result = Success(1);
        expect(result.isFailure, isFalse);
      });
    });

    group('dataOrNull', () {
      test('returns data for Success', () {
        const Result<int> result = Success(42);
        expect(result.dataOrNull, 42);
      });

      test('returns null for Failure', () {
        const Result<int> result = Failure('err');
        expect(result.dataOrNull, isNull);
      });

      test('returns null for Success with null data', () {
        const Result<int?> result = Success(null);
        expect(result.dataOrNull, isNull);
      });
    });

    group('errorOrNull', () {
      test('returns error for Failure', () {
        const Result<int> result = Failure('err');
        expect(result.errorOrNull, 'err');
      });

      test('returns null for Success', () {
        const Result<int> result = Success(42);
        expect(result.errorOrNull, isNull);
      });
    });

    group('map', () {
      test('transforms Success data', () {
        const Result<int> result = Success(5);
        final mapped = result.map((v) => v * 2);

        expect(mapped.isSuccess, isTrue);
        expect(mapped.dataOrNull, 10);
      });

      test('passes through Failure unchanged', () {
        const Result<int> result = Failure('err');
        final mapped = result.map((v) => v * 2);

        expect(mapped.isFailure, isTrue);
        expect(mapped.errorOrNull, 'err');
      });

      test('transforms to different type', () {
        const Result<int> result = Success(42);
        final mapped = result.map((v) => v.toString());

        expect(mapped.isSuccess, isTrue);
        expect(mapped.dataOrNull, '42');
      });

      test('handles zero value', () {
        const Result<int> result = Success(0);
        final mapped = result.map((v) => v + 1);

        expect(mapped.dataOrNull, 1);
      });
    });

    group('pattern matching', () {
      test('exhaustive switch on Success', () {
        const Result<int> result = Success(1);

        final value = switch (result) {
          Success(:final data) => 'data: $data',
          Failure(:final error) => 'error: $error',
        };

        expect(value, 'data: 1');
      });

      test('exhaustive switch on Failure', () {
        const Result<int> result = Failure('oops');

        final value = switch (result) {
          Success(:final data) => 'data: $data',
          Failure(:final error) => 'error: $error',
        };

        expect(value, 'error: oops');
      });
    });
  });
}
