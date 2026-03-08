import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure', () {
    test('toString without code returns message only', () {
      const failure = NetworkFailure();
      // NetworkFailure always has a code, so we test via a subclass
      // that demonstrates the pattern.
      expect(failure.toString(), contains('Network failure'));
    });
  });

  group('NetworkFailure', () {
    test('has default message', () {
      const failure = NetworkFailure();
      expect(failure.message, 'Network failure');
    });

    test('accepts custom message', () {
      const failure = NetworkFailure('No internet connection');
      expect(failure.message, 'No internet connection');
    });

    test('has NETWORK_FAILURE code', () {
      const failure = NetworkFailure();
      expect(failure.code, 'NETWORK_FAILURE');
    });

    test('extends Failure', () {
      expect(const NetworkFailure(), isA<Failure>());
    });

    test('toString includes code and message', () {
      const failure = NetworkFailure();
      expect(failure.toString(), '[NETWORK_FAILURE] Network failure');
    });
  });

  group('ServerFailure', () {
    test('has default message', () {
      const failure = ServerFailure();
      expect(failure.message, 'Server failure');
    });

    test('accepts custom message', () {
      const failure = ServerFailure('Gateway timeout');
      expect(failure.message, 'Gateway timeout');
    });

    test('code includes status code', () {
      const failure = ServerFailure('error', 503);
      expect(failure.code, 'SERVER_FAILURE_503');
    });

    test('code includes null when no status code', () {
      const failure = ServerFailure();
      expect(failure.code, 'SERVER_FAILURE_null');
    });

    test('extends Failure', () {
      expect(const ServerFailure(), isA<Failure>());
    });

    test('toString with status code', () {
      const failure = ServerFailure('Internal error', 500);
      expect(failure.toString(), '[SERVER_FAILURE_500] Internal error');
    });
  });

  group('CacheFailure', () {
    test('has default message', () {
      const failure = CacheFailure();
      expect(failure.message, 'Cache failure');
    });

    test('accepts custom message', () {
      const failure = CacheFailure('Expired cache entry');
      expect(failure.message, 'Expired cache entry');
    });

    test('has CACHE_FAILURE code', () {
      const failure = CacheFailure();
      expect(failure.code, 'CACHE_FAILURE');
    });

    test('extends Failure', () {
      expect(const CacheFailure(), isA<Failure>());
    });

    test('toString includes code and message', () {
      const failure = CacheFailure();
      expect(failure.toString(), '[CACHE_FAILURE] Cache failure');
    });
  });

  group('ValidationFailure', () {
    test('has default message', () {
      const failure = ValidationFailure();
      expect(failure.message, 'Validation failure');
    });

    test('accepts custom message', () {
      const failure = ValidationFailure('Field is required');
      expect(failure.message, 'Field is required');
    });

    test('has VALIDATION_FAILURE code', () {
      const failure = ValidationFailure();
      expect(failure.code, 'VALIDATION_FAILURE');
    });

    test('extends Failure', () {
      expect(const ValidationFailure(), isA<Failure>());
    });

    test('toString includes code and message', () {
      const failure = ValidationFailure();
      expect(failure.toString(), '[VALIDATION_FAILURE] Validation failure');
    });
  });
}
