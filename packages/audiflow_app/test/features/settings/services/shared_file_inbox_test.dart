import 'dart:io';

import 'package:audiflow_app/features/settings/services/shared_file_inbox.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory root;
  late Directory inbox;

  setUp(() {
    root = Directory.systemTemp.createTempSync('shared_file_inbox_test');
    inbox = Directory('${root.path}/Inbox')..createSync();
  });

  tearDown(() => root.deleteSync(recursive: true));

  File writeFile(String path) => File(path)..writeAsStringSync('<opml/>');

  group('DirectorySharedFileInbox.discard', () {
    test('deletes a file directly inside the inbox', () async {
      final file = writeFile('${inbox.path}/shared.opml');

      await DirectorySharedFileInbox(() async => inbox).discard(file.path);

      check(file.existsSync()).isFalse();
    });

    test('matches the inbox through symlinked paths', () async {
      // iOS hands over /private/var/... URLs while path_provider reports
      // /var/..., so the comparison must resolve symlinks on both sides.
      final file = writeFile('${inbox.path}/shared.opml');
      final link = Link('${root.path}/InboxLink')..createSync(inbox.path);

      await DirectorySharedFileInbox(
        () async => Directory(link.path),
      ).discard(file.path);

      check(file.existsSync()).isFalse();
    });

    test('keeps a file outside the inbox', () async {
      final file = writeFile('${root.path}/elsewhere.opml');

      await DirectorySharedFileInbox(() async => inbox).discard(file.path);

      check(file.existsSync()).isTrue();
    });

    test('keeps a file in a folder nested under the inbox', () async {
      final nested = Directory('${inbox.path}/nested')..createSync();
      final file = writeFile('${nested.path}/shared.opml');

      await DirectorySharedFileInbox(() async => inbox).discard(file.path);

      check(file.existsSync()).isTrue();
    });

    test('keeps a file reached through ".." out of the inbox', () async {
      final file = writeFile('${root.path}/elsewhere.opml');

      await DirectorySharedFileInbox(
        () async => inbox,
      ).discard('${inbox.path}/../elsewhere.opml');

      check(file.existsSync()).isTrue();
    });

    test('does nothing when the platform has no inbox', () async {
      final file = writeFile('${inbox.path}/shared.opml');

      await DirectorySharedFileInbox(() async => null).discard(file.path);

      check(file.existsSync()).isTrue();
    });

    test('does nothing when the file is already gone', () async {
      await DirectorySharedFileInbox(
        () async => inbox,
      ).discard('${inbox.path}/missing.opml');
    });

    test('does nothing when the inbox does not exist', () async {
      final file = writeFile('${root.path}/elsewhere.opml');

      await DirectorySharedFileInbox(
        () async => Directory('${root.path}/NoInbox'),
      ).discard(file.path);

      check(file.existsSync()).isTrue();
    });
  });
}
