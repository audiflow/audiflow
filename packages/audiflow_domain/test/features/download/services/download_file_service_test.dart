import 'dart:io';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([Dio])
import 'download_file_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDio mockDio;
  late DownloadFileService service;
  late Directory tempDir;

  setUp(() async {
    mockDio = MockDio();
    service = DownloadFileService(dio: mockDio);

    // Create a temp directory for tests
    tempDir = await Directory.systemTemp.createTemp('download_test_');

    // Mock path_provider to return our temp directory
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getApplicationDocumentsDirectory') {
              return tempDir.path;
            }
            return null;
          },
        );
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('cancelDownload', () {
    test('does not throw when cancelling non-existent task', () {
      // Act & Assert - should not throw
      service.cancelDownload(42);
    });
  });

  group('downloadFile', () {
    test('throws DownloadException with cancelled type '
        'when DioException cancel occurs', () async {
      // Arrange
      when(
        mockDio.download(
          any,
          any,
          cancelToken: anyNamed('cancelToken'),
          deleteOnError: anyNamed('deleteOnError'),
          options: anyNamed('options'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenThrow(
        DioException(
          type: DioExceptionType.cancel,
          requestOptions: RequestOptions(path: '/test'),
        ),
      );

      // Act & Assert
      expect(
        () => service.downloadFile(
          taskId: 1,
          url: 'https://example.com/ep.mp3',
          episodeId: 1,
          episodeTitle: 'Test Episode',
          onProgress: (_, __) {},
        ),
        throwsA(
          isA<DownloadException>().having(
            (e) => e.type,
            'type',
            DownloadErrorType.cancelled,
          ),
        ),
      );
    });

    test('throws DownloadException with networkUnavailable '
        'on connection error', () async {
      // Arrange
      when(
        mockDio.download(
          any,
          any,
          cancelToken: anyNamed('cancelToken'),
          deleteOnError: anyNamed('deleteOnError'),
          options: anyNamed('options'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenThrow(
        DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/test'),
          message: 'No connection',
        ),
      );

      // Act & Assert
      expect(
        () => service.downloadFile(
          taskId: 1,
          url: 'https://example.com/ep.mp3',
          episodeId: 1,
          episodeTitle: 'Test Episode',
          onProgress: (_, __) {},
        ),
        throwsA(
          isA<DownloadException>().having(
            (e) => e.type,
            'type',
            DownloadErrorType.networkUnavailable,
          ),
        ),
      );
    });

    test('throws DownloadException with networkUnavailable '
        'on connection timeout', () async {
      // Arrange
      when(
        mockDio.download(
          any,
          any,
          cancelToken: anyNamed('cancelToken'),
          deleteOnError: anyNamed('deleteOnError'),
          options: anyNamed('options'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenThrow(
        DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/test'),
          message: 'Timeout',
        ),
      );

      // Act & Assert
      expect(
        () => service.downloadFile(
          taskId: 1,
          url: 'https://example.com/ep.mp3',
          episodeId: 1,
          episodeTitle: 'Test Episode',
          onProgress: (_, __) {},
        ),
        throwsA(
          isA<DownloadException>().having(
            (e) => e.type,
            'type',
            DownloadErrorType.networkUnavailable,
          ),
        ),
      );
    });

    test('throws DownloadException with serverError '
        'on other DioException types', () async {
      // Arrange
      when(
        mockDio.download(
          any,
          any,
          cancelToken: anyNamed('cancelToken'),
          deleteOnError: anyNamed('deleteOnError'),
          options: anyNamed('options'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          message: 'Bad response',
        ),
      );

      // Act & Assert
      expect(
        () => service.downloadFile(
          taskId: 1,
          url: 'https://example.com/ep.mp3',
          episodeId: 1,
          episodeTitle: 'Test Episode',
          onProgress: (_, __) {},
        ),
        throwsA(
          isA<DownloadException>().having(
            (e) => e.type,
            'type',
            DownloadErrorType.serverError,
          ),
        ),
      );
    });

    test('removes cancel token after download failure', () async {
      // Arrange
      when(
        mockDio.download(
          any,
          any,
          cancelToken: anyNamed('cancelToken'),
          deleteOnError: anyNamed('deleteOnError'),
          options: anyNamed('options'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenThrow(
        DioException(
          type: DioExceptionType.cancel,
          requestOptions: RequestOptions(path: '/test'),
        ),
      );

      // Act
      try {
        await service.downloadFile(
          taskId: 99,
          url: 'https://example.com/ep.mp3',
          episodeId: 1,
          episodeTitle: 'Test',
          onProgress: (_, __) {},
        );
      } on DownloadException {
        // expected
      }

      // Assert - cancel on same taskId is safe (token already cleaned up)
      service.cancelDownload(99);
    });

    test('passes Range header when resuming download', () async {
      // Arrange
      Options? capturedOptions;
      when(
        mockDio.download(
          any,
          any,
          cancelToken: anyNamed('cancelToken'),
          deleteOnError: anyNamed('deleteOnError'),
          options: anyNamed('options'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenAnswer((invocation) {
        capturedOptions =
            invocation.namedArguments[const Symbol('options')] as Options?;
        return Future.value(
          Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 206,
          ),
        );
      });

      // Act
      await service.downloadFile(
        taskId: 1,
        url: 'https://example.com/ep.mp3',
        episodeId: 1,
        episodeTitle: 'Test',
        resumeFromBytes: 5000,
        onProgress: (_, __) {},
      );

      // Assert
      expect(capturedOptions, isNotNull);
      expect(capturedOptions!.headers?['Range'], 'bytes=5000-');
    });

    test('does not set Range header for fresh download', () async {
      // Arrange
      Options? capturedOptions;
      when(
        mockDio.download(
          any,
          any,
          cancelToken: anyNamed('cancelToken'),
          deleteOnError: anyNamed('deleteOnError'),
          options: anyNamed('options'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenAnswer((invocation) {
        capturedOptions =
            invocation.namedArguments[const Symbol('options')] as Options?;
        return Future.value(
          Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 200,
          ),
        );
      });

      // Act
      await service.downloadFile(
        taskId: 1,
        url: 'https://example.com/ep.mp3',
        episodeId: 1,
        episodeTitle: 'Test',
        onProgress: (_, __) {},
      );

      // Assert
      expect(capturedOptions, isNotNull);
      expect(capturedOptions!.headers?['Range'], isNull);
    });

    test('returns local file path on successful download', () async {
      // Arrange
      when(
        mockDio.download(
          any,
          any,
          cancelToken: anyNamed('cancelToken'),
          deleteOnError: anyNamed('deleteOnError'),
          options: anyNamed('options'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenAnswer(
        (_) => Future.value(
          Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 200,
          ),
        ),
      );

      // Act
      final result = await service.downloadFile(
        taskId: 1,
        url: 'https://example.com/ep.mp3',
        episodeId: 42,
        episodeTitle: 'My Episode',
        onProgress: (_, __) {},
      );

      // Assert
      expect(result, contains('downloads'));
      expect(result, contains('42'));
      expect(result, contains('.mp3'));
    });

    test('throws serverError for non-200/206 status', () async {
      // Arrange
      when(
        mockDio.download(
          any,
          any,
          cancelToken: anyNamed('cancelToken'),
          deleteOnError: anyNamed('deleteOnError'),
          options: anyNamed('options'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenAnswer(
        (_) => Future.value(
          Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 500,
          ),
        ),
      );

      // Act & Assert
      expect(
        () => service.downloadFile(
          taskId: 1,
          url: 'https://example.com/ep.mp3',
          episodeId: 1,
          episodeTitle: 'Test',
          onProgress: (_, __) {},
        ),
        throwsA(
          isA<DownloadException>().having(
            (e) => e.type,
            'type',
            DownloadErrorType.serverError,
          ),
        ),
      );
    });

    test('calls onProgress callback with correct values', () async {
      // Arrange
      final progressUpdates = <(int, int)>[];
      late void Function(int, int) capturedCallback;

      when(
        mockDio.download(
          any,
          any,
          cancelToken: anyNamed('cancelToken'),
          deleteOnError: anyNamed('deleteOnError'),
          options: anyNamed('options'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenAnswer((invocation) {
        capturedCallback =
            invocation.namedArguments[const Symbol('onReceiveProgress')]
                as void Function(int, int);
        // Simulate progress
        capturedCallback(500, 1000);
        capturedCallback(1000, 1000);
        return Future.value(
          Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 200,
          ),
        );
      });

      // Act
      await service.downloadFile(
        taskId: 1,
        url: 'https://example.com/ep.mp3',
        episodeId: 1,
        episodeTitle: 'Test',
        onProgress: (downloaded, total) {
          progressUpdates.add((downloaded, total));
        },
      );

      // Assert
      expect(progressUpdates.length, 2);
      expect(progressUpdates[0], (500, 1000));
      expect(progressUpdates[1], (1000, 1000));
    });

    test('adjusts progress for resumed downloads', () async {
      // Arrange
      final progressUpdates = <(int, int)>[];

      when(
        mockDio.download(
          any,
          any,
          cancelToken: anyNamed('cancelToken'),
          deleteOnError: anyNamed('deleteOnError'),
          options: anyNamed('options'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenAnswer((invocation) {
        final callback =
            invocation.namedArguments[const Symbol('onReceiveProgress')]
                as void Function(int, int);
        // received=500 of remaining, total=500 remaining
        callback(500, 500);
        return Future.value(
          Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 206,
          ),
        );
      });

      // Act
      await service.downloadFile(
        taskId: 1,
        url: 'https://example.com/ep.mp3',
        episodeId: 1,
        episodeTitle: 'Test',
        resumeFromBytes: 3000,
        onProgress: (downloaded, total) {
          progressUpdates.add((downloaded, total));
        },
      );

      // Assert - should add resumeFromBytes to both values
      expect(progressUpdates.length, 1);
      // downloadedBytes = 500 + 3000 = 3500
      // totalBytes = 500 + 3000 = 3500
      expect(progressUpdates[0], (3500, 3500));
    });

    test('reports zero totalBytes when content-length unknown', () async {
      // Arrange
      final progressUpdates = <(int, int)>[];

      when(
        mockDio.download(
          any,
          any,
          cancelToken: anyNamed('cancelToken'),
          deleteOnError: anyNamed('deleteOnError'),
          options: anyNamed('options'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenAnswer((invocation) {
        final callback =
            invocation.namedArguments[const Symbol('onReceiveProgress')]
                as void Function(int, int);
        // total=-1 means unknown
        callback(1000, -1);
        return Future.value(
          Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 200,
          ),
        );
      });

      // Act
      await service.downloadFile(
        taskId: 1,
        url: 'https://example.com/ep.mp3',
        episodeId: 1,
        episodeTitle: 'Test',
        onProgress: (downloaded, total) {
          progressUpdates.add((downloaded, total));
        },
      );

      // Assert - total=-1 maps to 0 (+ resumeFromBytes=0)
      expect(progressUpdates[0].$2, 0);
    });
  });

  group('getDownloadsDirectory', () {
    test('returns path under application documents directory', () async {
      // Act
      final dir = await service.getDownloadsDirectory();

      // Assert
      expect(dir, contains(tempDir.path));
      expect(dir, endsWith('downloads'));
    });
  });

  group('deleteFile', () {
    test('deletes existing file', () async {
      // Arrange
      final file = File('${tempDir.path}/test_file.mp3');
      await file.create();
      expect(await file.exists(), isTrue);

      // Act
      await service.deleteFile(file.path);

      // Assert
      expect(await file.exists(), isFalse);
    });

    test('does nothing when file does not exist', () async {
      // Act & Assert - should not throw
      await service.deleteFile('${tempDir.path}/nonexistent.mp3');
    });
  });

  group('getFileSize', () {
    test('returns file size for existing file', () async {
      // Arrange
      final file = File('${tempDir.path}/test_file.mp3');
      await file.writeAsBytes(List.filled(1024, 0));

      // Act
      final size = await service.getFileSize(file.path);

      // Assert
      expect(size, 1024);
    });

    test('returns zero when file does not exist', () async {
      // Act
      final size = await service.getFileSize('${tempDir.path}/nonexistent.mp3');

      // Assert
      expect(size, 0);
    });
  });

  group('fileExists', () {
    test('returns true for existing file', () async {
      // Arrange
      final file = File('${tempDir.path}/test_file.mp3');
      await file.create();

      // Act
      final exists = await service.fileExists(file.path);

      // Assert
      expect(exists, isTrue);
    });

    test('returns false for non-existing file', () async {
      // Act
      final exists = await service.fileExists(
        '${tempDir.path}/nonexistent.mp3',
      );

      // Assert
      expect(exists, isFalse);
    });
  });
}
