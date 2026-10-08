import 'dart:io';

import 'package:path/path.dart' as p;

/// Deletes every file a download of [episodeId] left in [downloadsDir].
///
/// A task records its file path only once the download finishes, so a
/// paused, cancelled, or failed task points at nothing while its partial
/// file sits on disk. Every download file is named `<episodeId>_...` (see
/// `buildDownloadPath`), so the episode's files are found by that prefix
/// rather than by the stored path, and wherever the title or URL changed
/// since the transfer started.
///
/// [storedPath] is resolved against [downloadsDir] by file name: the stored
/// absolute path goes stale when iOS rotates the app container.
Future<void> deleteEpisodeDownloadFiles({
  required String downloadsDir,
  required int episodeId,
  String? storedPath,
}) async {
  final paths = <String>{
    if (storedPath != null) p.join(downloadsDir, p.basename(storedPath)),
    ...await _filesWithPrefix(downloadsDir, '${episodeId}_'),
  };
  for (final path in paths) {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}

Future<List<String>> _filesWithPrefix(String directory, String prefix) async {
  final dir = Directory(directory);
  if (!await dir.exists()) return const [];
  return [
    await for (final entity in dir.list(followLinks: false))
      if (entity is File && p.basename(entity.path).startsWith(prefix))
        entity.path,
  ];
}
