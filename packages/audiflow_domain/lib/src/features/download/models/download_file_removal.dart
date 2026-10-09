import 'package:isar_community/isar.dart';

part 'download_file_removal.g.dart';

/// Files of a download whose record is already deleted, kept until the
/// files are gone: written by retention, and by a bulk delete for files it
/// could not remove.
///
/// Retention deletes the record first, atomically with its origin check,
/// so a keep request can never lose its file. This row is written in that
/// same transaction, so a file that fails to delete, or an app killed
/// before the files go, is retried by the next retention pass instead of
/// staying on disk with nothing pointing at it.
@collection
class DownloadFileRemoval {
  Id id = Isar.autoIncrement;

  /// The episode whose `<episodeId>_*` files are to be removed. Unique so a
  /// later removal for the same episode replaces, rather than duplicates,
  /// one that is still pending; both sweep the same files.
  @Index(unique: true, replace: true)
  late int episodeId;

  /// The path the deleted task recorded, if it finished.
  String? storedPath;
}
