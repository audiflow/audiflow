import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'content_uri_reader.dart';

part 'opml_file_picker.g.dart';

/// Which files the system picker offers.
enum OpmlPickFilter {
  /// OPML and XML files. A provider can label a real `.opml` file with a type
  /// this does not cover, which is why [allFiles] exists.
  opml,

  /// Every file, for when [opml] hides the file the user is looking for.
  allFiles,
}

/// A file chosen in the system picker, not necessarily read yet.
class PickedOpmlFile {
  const PickedOpmlFile(this.read);

  /// Reads the file's text. May download it from a remote provider.
  final Future<String> Function() read;
}

/// Opens the system file picker for OPML import.
// ignore: one_member_abstracts
abstract interface class OpmlFilePicker {
  /// Resolves once the user has chosen a file, or with null on cancel.
  ///
  /// The listing shown meanwhile is drawn by the system picker and the
  /// storage provider (such as Google Drive), outside this app.
  Future<PickedOpmlFile?> pick(OpmlPickFilter filter);
}

/// Picks through the Storage Access Framework via `DocumentPickerChannel`.
///
/// file_picker cannot filter `.opml` on Android: it turns extensions into MIME
/// types with `MimeTypeMap` and takes no raw MIME types, so it would drop the
/// types Drive actually reports. Reading the URI directly also skips its copy
/// of the file into the app cache.
class AndroidOpmlFilePicker implements OpmlFilePicker {
  const AndroidOpmlFilePicker([
    this._channel = const MethodChannel(channelName),
  ]);

  static const channelName = 'com.reedom.audiflow_app/document_picker';

  /// `.opml` has no standard MIME type; these are the ones Google Drive
  /// reports for such files. `application/octet-stream` also lets some
  /// unrelated files through, which beats hiding a real OPML file.
  static const _opmlMimeTypes = [
    'text/x-opml',
    'text/xml',
    'application/xml',
    'application/octet-stream',
  ];
  static const _anyMimeType = ['*/*'];

  final MethodChannel _channel;

  @override
  Future<PickedOpmlFile?> pick(OpmlPickFilter filter) async {
    final uri = await _channel.invokeMethod<String>(
      'pickDocument',
      switch (filter) {
        OpmlPickFilter.opml => _opmlMimeTypes,
        OpmlPickFilter.allFiles => _anyMimeType,
      },
    );
    if (uri == null) return null;
    return PickedOpmlFile(() => readContentUri(uri));
  }
}

/// Picks through `UIDocumentPickerViewController` via file_picker.
///
/// Filtering on `opml` relies on the `org.opml.opml` type declared in
/// Info.plist: without it iOS has no type for the extension and greys out
/// `.opml` files. The system downloads a remote file before [pick] resolves,
/// so the wait for it happens inside the system picker.
class IosOpmlFilePicker implements OpmlFilePicker {
  const IosOpmlFilePicker();

  @override
  Future<PickedOpmlFile?> pick(OpmlPickFilter filter) async {
    final file = switch (filter) {
      OpmlPickFilter.opml => await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['opml', 'xml'],
      ),
      OpmlPickFilter.allFiles => await FilePicker.pickFile(),
    };
    if (file == null) return null;

    final path = file.path;
    return PickedOpmlFile(() async {
      if (path == null) {
        throw const FormatException('Picked file has no local path');
      }
      try {
        return await File(path).readAsString();
      } on FileSystemException catch (e) {
        // Includes content that is not UTF-8, which "show all files" makes
        // easy to pick. Android reports the same files as unreadable too.
        throw FormatException(e.message);
      }
    });
  }
}

@riverpod
OpmlFilePicker opmlFilePicker(Ref ref) {
  return defaultTargetPlatform == TargetPlatform.android
      ? const AndroidOpmlFilePicker()
      : const IosOpmlFilePicker();
}
