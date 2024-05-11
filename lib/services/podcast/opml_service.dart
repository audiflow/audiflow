/// This service handles the import and export of Podcasts via
/// the OPML format.
abstract class OPMLService {
  Future<void> loadOPMLFile(String file);

  Future<void> saveOPMLFile();

  void cancel();
}
