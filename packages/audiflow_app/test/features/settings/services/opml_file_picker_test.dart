import 'dart:io';

import 'package:audiflow_app/features/settings/services/content_uri_reader.dart';
import 'package:audiflow_app/features/settings/services/opml_file_picker.dart';
import 'package:checks/checks.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records the arguments of a pick and returns [file].
class _FakeFilePickerPlatform extends FilePickerPlatform {
  _FakeFilePickerPlatform(this.file);

  final PlatformFile? file;
  FileType? type;
  List<String>? allowedExtensions;

  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    this.type = type;
    this.allowedExtensions = allowedExtensions;
    return file;
  }
}

/// A picked file at [uri].
final class _FakePlatformFile extends PlatformFile {
  _FakePlatformFile(this.uri);

  @override
  final Uri uri;

  @override
  String get name => 'feeds.opml';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  void mockChannel(
    String name,
    Future<Object?> Function(MethodCall call) handler,
  ) {
    final channel = MethodChannel(name);
    messenger.setMockMethodCallHandler(channel, handler);
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
  }

  group('AndroidOpmlFilePicker', () {
    const uri = 'content://drive/document/1';

    /// Records what the native picker was asked to show.
    List<Object?> mockNativePicker({String? pickedUri = uri}) {
      final requested = <Object?>[];
      mockChannel(AndroidOpmlFilePicker.channelName, (call) async {
        check(call.method).equals('pickDocument');
        requested.add(call.arguments);
        return pickedUri;
      });
      return requested;
    }

    test(
      'keeps every MIME type Drive reports for .opml in the filter',
      () async {
        final requested = mockNativePicker();

        await const AndroidOpmlFilePicker().pick(OpmlPickFilter.opml);

        check(requested).deepEquals([
          [
            'text/x-opml',
            'text/xml',
            'application/xml',
            'application/octet-stream',
          ],
        ]);
      },
    );

    test('asks for any type when showing all files', () async {
      final requested = mockNativePicker();

      await const AndroidOpmlFilePicker().pick(OpmlPickFilter.allFiles);

      check(requested).deepEquals([
        ['*/*'],
      ]);
    });

    test('returns null when the picker is cancelled', () async {
      mockNativePicker(pickedUri: null);

      final file = await const AndroidOpmlFilePicker().pick(
        OpmlPickFilter.opml,
      );

      check(file).isNull();
    });

    test('reads the picked document only when asked', () async {
      mockNativePicker();
      final readUris = <Object?>[];
      mockChannel(contentResolverChannelName, (call) async {
        check(call.method).equals('readContentUri');
        readUris.add(call.arguments);
        return '<opml/>';
      });

      final file = await const AndroidOpmlFilePicker().pick(
        OpmlPickFilter.opml,
      );

      // The controller shows progress between these two steps, so the
      // download from the provider must not start until read() is called.
      check(readUris).isEmpty();
      check(await file!.read()).equals('<opml/>');
      check(readUris).deepEquals([uri]);
    });
  });

  group('IosOpmlFilePicker', () {
    late FilePickerPlatform original;

    setUp(() => original = FilePickerPlatform.instance);
    tearDown(() => FilePickerPlatform.instance = original);

    _FakeFilePickerPlatform install(PlatformFile? file) {
      final fake = _FakeFilePickerPlatform(file);
      FilePickerPlatform.instance = fake;
      return fake;
    }

    test('filters by the opml and xml extensions', () async {
      final fake = install(null);

      await const IosOpmlFilePicker().pick(OpmlPickFilter.opml);

      check(fake.type).equals(FileType.custom);
      check(fake.allowedExtensions).isNotNull().deepEquals(['opml', 'xml']);
    });

    test('drops the filter when showing all files', () async {
      final fake = install(null);

      await const IosOpmlFilePicker().pick(OpmlPickFilter.allFiles);

      check(fake.type).equals(FileType.any);
      check(fake.allowedExtensions).isNull();
    });

    test('returns null when the picker is cancelled', () async {
      install(null);

      final file = await const IosOpmlFilePicker().pick(OpmlPickFilter.opml);

      check(file).isNull();
    });

    test('reports a file with no local path as unreadable', () async {
      install(_FakePlatformFile(Uri.parse('https://example.com/feeds.opml')));

      final file = await const IosOpmlFilePicker().pick(OpmlPickFilter.opml);

      await check(file!.read()).throws<FormatException>();
    });

    group('with a file on disk', () {
      late Directory dir;

      setUp(() => dir = Directory.systemTemp.createTempSync('opml_picker'));
      tearDown(() => dir.deleteSync(recursive: true));

      Future<PickedOpmlFile> pickFileWith(List<int> bytes) async {
        final onDisk = File('${dir.path}/feeds.opml')..writeAsBytesSync(bytes);
        install(_FakePlatformFile(onDisk.uri));
        return (await const IosOpmlFilePicker().pick(OpmlPickFilter.opml))!;
      }

      test('reads its text', () async {
        final file = await pickFileWith('<opml/>'.codeUnits);

        check(await file.read()).equals('<opml/>');
      });

      test('reports content that is not UTF-8 as unreadable', () async {
        final file = await pickFileWith(const [0xFF, 0xFE, 0x00]);

        await check(file.read()).throws<FormatException>();
      });
    });
  });

  group('readContentUri', () {
    test('turns a native read failure into a FormatException', () async {
      mockChannel(contentResolverChannelName, (call) async {
        throw PlatformException(code: 'READ_FAILED', message: 'gone');
      });

      await check(
        readContentUri('content://drive/document/1'),
      ).throws<FormatException>();
    });

    test('treats a missing result as a FormatException', () async {
      mockChannel(contentResolverChannelName, (call) async => null);

      await check(
        readContentUri('content://drive/document/1'),
      ).throws<FormatException>();
    });
  });
}
