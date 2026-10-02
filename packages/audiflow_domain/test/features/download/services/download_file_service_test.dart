import 'dart:io';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
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

  /// Writes a partial download of [length] bytes where the service stores
  /// episode 1 titled "Test" from an .mp3 url.
  Future<File> writePartialFile(int length) async {
    final file = File('${tempDir.path}/downloads/1_Test.mp3');
    await file.create(recursive: true);
    await file.writeAsBytes(List.filled(length, 0));
    return file;
  }

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
          onProgress: (_, _) {},
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
          onProgress: (_, _) {},
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
          onProgress: (_, _) {},
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
          onProgress: (_, _) {},
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
          onProgress: (_, _) {},
        );
      } on DownloadException {
        // expected
      }

      // Assert - cancel on same taskId is safe (token already cleaned up)
      service.cancelDownload(99);
    });

    test('resumes from the partial file length in append mode', () async {
      // Arrange: the stored byte count lags behind the file on disk, as
      // throttled progress writes leave it.
      await writePartialFile(5000);
      Options? capturedOptions;
      FileAccessMode? capturedMode;
      when(
        mockDio.download(
          any,
          any,
          cancelToken: anyNamed('cancelToken'),
          deleteOnError: anyNamed('deleteOnError'),
          fileAccessMode: anyNamed('fileAccessMode'),
          options: anyNamed('options'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenAnswer((invocation) {
        capturedOptions =
            invocation.namedArguments[const Symbol('options')] as Options?;
        capturedMode =
            invocation.namedArguments[const Symbol('fileAccessMode')]
                as FileAccessMode?;
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
        resumeFromBytes: 4000,
        onProgress: (_, _) {},
      );

      // Assert
      check(capturedOptions?.headers?['Range']).equals('bytes=5000-');
      check(capturedMode).equals(FileAccessMode.append);
    });

    test('downloads afresh when the partial file is missing', () async {
      // Arrange
      Options? capturedOptions;
      FileAccessMode? capturedMode;
      when(
        mockDio.download(
          any,
          any,
          cancelToken: anyNamed('cancelToken'),
          deleteOnError: anyNamed('deleteOnError'),
          fileAccessMode: anyNamed('fileAccessMode'),
          options: anyNamed('options'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenAnswer((invocation) {
        capturedOptions =
            invocation.namedArguments[const Symbol('options')] as Options?;
        capturedMode =
            invocation.namedArguments[const Symbol('fileAccessMode')]
                as FileAccessMode?;
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
        resumeFromBytes: 5000,
        onProgress: (_, _) {},
      );

      // Assert
      check(capturedOptions?.headers?['Range']).isNull();
      check(capturedMode).equals(FileAccessMode.write);
    });

    test('discards the partial file when the server ignores Range', () async {
      // Arrange
      final partial = await writePartialFile(5000);
      when(
        mockDio.download(
          any,
          any,
          cancelToken: anyNamed('cancelToken'),
          deleteOnError: anyNamed('deleteOnError'),
          fileAccessMode: anyNamed('fileAccessMode'),
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
      final download = service.downloadFile(
        taskId: 1,
        url: 'https://example.com/ep.mp3',
        episodeId: 1,
        episodeTitle: 'Test',
        resumeFromBytes: 5000,
        onProgress: (_, _) {},
      );

      // Assert
      await check(download).throws<DownloadException>(
        (e) =>
            e.has((d) => d.type, 'type').equals(DownloadErrorType.serverError),
      );
      check(await partial.exists()).isFalse();
    });

    test('discards the partial file when the range is unsatisfiable', () async {
      // Arrange: the partial file is already as long as the remote file.
      final partial = await writePartialFile(5000);
      when(
        mockDio.download(
          any,
          any,
          cancelToken: anyNamed('cancelToken'),
          deleteOnError: anyNamed('deleteOnError'),
          fileAccessMode: anyNamed('fileAccessMode'),
          options: anyNamed('options'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 416,
          ),
        ),
      );

      // Act
      final download = service.downloadFile(
        taskId: 1,
        url: 'https://example.com/ep.mp3',
        episodeId: 1,
        episodeTitle: 'Test',
        resumeFromBytes: 5000,
        onProgress: (_, _) {},
      );

      // Assert
      await check(download).throws<DownloadException>(
        (e) =>
            e.has((d) => d.type, 'type').equals(DownloadErrorType.serverError),
      );
      check(await partial.exists()).isFalse();
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
        onProgress: (_, _) {},
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
        onProgress: (_, _) {},
      );

      // Assert
      expect(result, contains('downloads'));
      expect(result, contains('42'));
      expect(result, contains('.mp3'));
    });

    test(
      'strips URI-reserved characters from episode title in filename',
      () async {
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

        // Act — title contains #, ?, and % which would otherwise be parsed as
        // fragment/query/percent-encoding when the path is handed to the
        // underlying player as a file:// URI.
        final result = await service.downloadFile(
          taskId: 1,
          url: 'https://example.com/ep.mp3',
          episodeId: 7,
          episodeTitle: 'News #211? 50% off',
          onProgress: (_, _) {},
        );

        // Assert
        expect(result, isNot(contains('#')));
        expect(result, isNot(contains('?')));
        expect(result, isNot(contains('%')));
        expect(result, endsWith('.mp3'));
      },
    );

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
          onProgress: (_, _) {},
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
      await writePartialFile(3000);
      final progressUpdates = <(int, int)>[];

      when(
        mockDio.download(
          any,
          any,
          cancelToken: anyNamed('cancelToken'),
          deleteOnError: anyNamed('deleteOnError'),
          fileAccessMode: anyNamed('fileAccessMode'),
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

      // Assert - should add the resume offset to both values
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
