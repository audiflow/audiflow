import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppException', () {
    test('stores message', () {
      final exception = AppException('something went wrong');
      expect(exception.message, 'something went wrong');
    });

    test('code defaults to null', () {
      final exception = AppException('error');
      expect(exception.code, isNull);
    });

    test('stores optional code', () {
      final exception = AppException('error', 'ERR_001');
      expect(exception.code, 'ERR_001');
    });

    test('toString without code returns message only', () {
      final exception = AppException('error occurred');
      expect(exception.toString(), 'error occurred');
    });

    test('toString with code returns [code] message', () {
      final exception = AppException('error occurred', 'ERR_001');
      expect(exception.toString(), '[ERR_001] error occurred');
    });

    test('implements Exception', () {
      final exception = AppException('test');
      expect(exception, isA<Exception>());
    });
  });

  group('NetworkException', () {
    test('has default message', () {
      final exception = NetworkException();
      expect(exception.message, 'Network error occurred');
    });

    test('accepts custom message', () {
      final exception = NetworkException('Connection timed out');
      expect(exception.message, 'Connection timed out');
    });

    test('has NETWORK_ERROR code', () {
      final exception = NetworkException();
      expect(exception.code, 'NETWORK_ERROR');
    });

    test('extends AppException', () {
      expect(NetworkException(), isA<AppException>());
    });

    test('toString includes code and message', () {
      final exception = NetworkException();
      expect(exception.toString(), '[NETWORK_ERROR] Network error occurred');
    });
  });

  group('ServerException', () {
    test('has default message', () {
      final exception = ServerException();
      expect(exception.message, 'Server error occurred');
    });

    test('accepts custom message', () {
      final exception = ServerException('Internal server error');
      expect(exception.message, 'Internal server error');
    });

    test('code includes status code', () {
      final exception = ServerException('error', 500);
      expect(exception.code, 'SERVER_ERROR_500');
    });

    test('code includes null when no status code', () {
      final exception = ServerException();
      expect(exception.code, 'SERVER_ERROR_null');
    });

    test('extends AppException', () {
      expect(ServerException(), isA<AppException>());
    });
  });

  group('CacheException', () {
    test('has default message', () {
      final exception = CacheException();
      expect(exception.message, 'Cache error occurred');
    });

    test('accepts custom message', () {
      final exception = CacheException('Cache miss');
      expect(exception.message, 'Cache miss');
    });

    test('has CACHE_ERROR code', () {
      final exception = CacheException();
      expect(exception.code, 'CACHE_ERROR');
    });

    test('extends AppException', () {
      expect(CacheException(), isA<AppException>());
    });
  });

  group('ValidationException', () {
    test('has default message', () {
      final exception = ValidationException();
      expect(exception.message, 'Validation error occurred');
    });

    test('accepts custom message', () {
      final exception = ValidationException('Invalid email');
      expect(exception.message, 'Invalid email');
    });

    test('has VALIDATION_ERROR code', () {
      final exception = ValidationException();
      expect(exception.code, 'VALIDATION_ERROR');
    });

    test('extends AppException', () {
      expect(ValidationException(), isA<AppException>());
    });
  });

  group('DownloadErrorType', () {
    test('has six values', () {
      expect(DownloadErrorType.values.length, 6);
    });

    test('contains all expected types', () {
      expect(
        DownloadErrorType.values,
        containsAll([
          DownloadErrorType.networkUnavailable,
          DownloadErrorType.serverError,
          DownloadErrorType.insufficientStorage,
          DownloadErrorType.fileWriteError,
          DownloadErrorType.cancelled,
          DownloadErrorType.unknown,
        ]),
      );
    });
  });

  group('DownloadException', () {
    test('stores error type', () {
      final exception = DownloadException(DownloadErrorType.cancelled);
      expect(exception.type, DownloadErrorType.cancelled);
    });

    test('has default message', () {
      final exception = DownloadException(DownloadErrorType.unknown);
      expect(exception.message, 'Download error occurred');
    });

    test('accepts custom message', () {
      final exception = DownloadException(
        DownloadErrorType.insufficientStorage,
        'No space left',
      );
      expect(exception.message, 'No space left');
    });

    test('code includes uppercase error type name', () {
      final exception = DownloadException(DownloadErrorType.networkUnavailable);
      expect(exception.code, 'DOWNLOAD_ERROR_NETWORKUNAVAILABLE');
    });

    test('code for cancelled type', () {
      final exception = DownloadException(DownloadErrorType.cancelled);
      expect(exception.code, 'DOWNLOAD_ERROR_CANCELLED');
    });

    test('code for serverError type', () {
      final exception = DownloadException(DownloadErrorType.serverError);
      expect(exception.code, 'DOWNLOAD_ERROR_SERVERERROR');
    });

    test('extends AppException', () {
      expect(DownloadException(DownloadErrorType.unknown), isA<AppException>());
    });

    test('toString includes code and message', () {
      final exception = DownloadException(DownloadErrorType.fileWriteError);
      expect(
        exception.toString(),
        '[DOWNLOAD_ERROR_FILEWRITEERROR] Download error occurred',
      );
    });
  });
}
