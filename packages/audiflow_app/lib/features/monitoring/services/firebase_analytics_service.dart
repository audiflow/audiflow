import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService(this._fa);

  final FirebaseAnalytics _fa;

  @override
  Future<void> log(AnalyticsEvent event) async {
    await _fa.logEvent(name: event.name, parameters: event.params);
  }

  @override
  Future<void> setUserId(String? id) => _fa.setUserId(id: id);

  @override
  Future<void> setOptIn(bool optIn) => _fa.setAnalyticsCollectionEnabled(optIn);
}
