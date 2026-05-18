import '../models/analytics_event.dart';
import '../services/analytics_service.dart';

/// Records calls so tests can assert against them.
///
/// Lives under `lib/` (not `test/`) so dependent packages can import it.
class FakeAnalyticsService implements AnalyticsService {
  final events = <AnalyticsEvent>[];
  String? userId;
  bool optIn = true;

  @override
  Future<void> log(AnalyticsEvent event) async {
    events.add(event);
  }

  @override
  Future<void> setUserId(String? id) async {
    userId = id;
  }

  @override
  Future<void> setOptIn(bool value) async {
    optIn = value;
  }

  void reset() {
    events.clear();
    userId = null;
    optIn = true;
  }
}
