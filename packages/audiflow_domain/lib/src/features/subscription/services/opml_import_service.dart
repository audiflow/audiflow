import '../../monitoring/models/analytics_event.dart';
import '../models/opml_entry.dart';
import '../models/opml_import_result.dart';
import '../repositories/subscription_repository.dart';
import 'feed_placeholder_id.dart';

/// Orchestrates OPML import: checks duplicates, subscribes,
/// and collects results.
class OpmlImportService {
  OpmlImportService({required this._repository});

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

        await _repository.subscribe(
          itunesId: feedPlaceholderId(entry.feedUrl),
          feedUrl: entry.feedUrl,
          title: entry.title,
          artistName: '',
          source: SubscribeSource.opml,
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
}
