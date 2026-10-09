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
    for (final (path, _) in await _filesOfEpisodes(downloadsDir, {episodeId}))
      path,
  };
  for (final path in paths) {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}

/// [deleteEpisodeDownloadFiles] for many episodes, listing [downloadsDir]
/// once instead of once per episode. [storedPaths] maps each episode ID to
/// its task's stored path, if any.
///
/// Returns the episodes whose files could not all be deleted. A file that
/// fails to delete does not stop the others: their deletes cannot be
/// undone, so the caller must commit their records' removal either way and
/// record the failed episodes for a retry.
Future<Set<int>> deleteEpisodesDownloadFiles({
  required String downloadsDir,
  required Map<int, String?> storedPaths,
}) async {
  if (storedPaths.isEmpty) return const {};
  final episodeIdsByPath = <String, int>{
    for (final MapEntry(key: episodeId, value: storedPath)
        in storedPaths.entries)
      if (storedPath != null)
        p.join(downloadsDir, p.basename(storedPath)): episodeId,
    for (final (path, episodeId) in await _filesOfEpisodes(
      downloadsDir,
      storedPaths.keys.toSet(),
    ))
      path: episodeId,
  };
  final failed = <int>{};
  for (final MapEntry(key: path, value: episodeId)
      in episodeIdsByPath.entries) {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      failed.add(episodeId);
    }
  }
  return failed;
}

/// The download files of [episodeIds] in [directory], with their episode.
Future<List<(String, int)>> _filesOfEpisodes(
  String directory,
  Set<int> episodeIds,
) async {
  final dir = Directory(directory);
  if (!await dir.exists()) return const [];
  return [
    await for (final entity in dir.list(followLinks: false))
      if (entity is File)
        if (_episodeIdOf(entity.path) case final episodeId?
            when episodeIds.contains(episodeId))
          (entity.path, episodeId),
  ];
}

final _episodeIdPrefix = RegExp(r'^(\d+)_');

/// The episode ID a `<episodeId>_...` download file is named after.
int? _episodeIdOf(String path) {
  final match = _episodeIdPrefix.firstMatch(p.basename(path));
  return match == null ? null : int.parse(match.group(1)!);
}
