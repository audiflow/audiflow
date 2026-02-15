import '../models/opml_entry.dart';
import '../models/opml_import_result.dart';
import '../repositories/subscription_repository.dart';

/// Orchestrates OPML import: checks duplicates, subscribes,
/// and collects results.
class OpmlImportService {
  OpmlImportService({required SubscriptionRepository repository})
    : _repository = repository;

  final SubscriptionRepository _repository;

  /// Imports a list of [OpmlEntry] as subscriptions.
  ///
  /// For each entry:
  /// - Skips if already subscribed (matched by feedUrl)
  /// - Subscribes with placeholder itunesId (`opml:<hash>`)
  /// - Collects failures without aborting
  Future<OpmlImportResult> importEntries(List<OpmlEntry> entries) async {
    final succeeded = <OpmlEntry>[];
    final alreadySubscribed = <OpmlEntry>[];
    final failed = <OpmlEntry>[];

    for (final entry in entries) {
      try {
        final exists = await _repository.isSubscribedByFeedUrl(entry.feedUrl);
        if (exists) {
          alreadySubscribed.add(entry);
          continue;
        }

        final placeholderId = _generatePlaceholderId(entry.feedUrl);
        await _repository.subscribe(
          itunesId: placeholderId,
          feedUrl: entry.feedUrl,
          title: entry.title,
          artistName: '',
        );
        succeeded.add(entry);
      } on Exception {
        failed.add(entry);
      }
    }

    return OpmlImportResult(
      succeeded: succeeded,
      alreadySubscribed: alreadySubscribed,
      failed: failed,
    );
  }

  String _generatePlaceholderId(String feedUrl) {
    final hash = feedUrl.hashCode.toRadixString(16);
    return 'opml:$hash';
  }
}
