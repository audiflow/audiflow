import 'package:audiflow_app/features/podcast_detail/presentation/helpers/podcast_visit.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

class _VisitRepository extends Fake implements SubscriptionRepository {
  _VisitRepository(this.subscription);

  final Subscription? subscription;
  final visited = <int>[];

  @override
  Future<Subscription?> getByFeedUrl(String feedUrl) async => subscription;

  @override
  Future<void> updateLastAccessed(int id) async => visited.add(id);
}

void main() {
  test('records a visit to a subscribed podcast', () async {
    final repository = _VisitRepository(Subscription()..id = 4);
    await recordPodcastVisit(repository, 'https://example.com/feed');
    check(repository.visited).deepEquals([4]);
  });

  test('records nothing for a podcast without a subscription', () async {
    final repository = _VisitRepository(null);
    await recordPodcastVisit(repository, 'https://example.com/feed');
    check(repository.visited).isEmpty();
  });
}
