import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService(this._fa);

  final FirebaseAnalytics _fa;

  @override
  Future<void> log(AnalyticsEvent event) async {
    if (kDebugMode) {
      debugPrint('[ANALYTICS] emit ${event.name} ${event.params}');
    }
    try {
      await _fa.logEvent(name: event.name, parameters: event.params);
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[ANALYTICS] emit FAILED ${event.name}: $e\n$stack');
      }
      rethrow;
    }
  }

  @override
  Future<void> setUserId(String? id) {
    if (kDebugMode) {
      debugPrint('[ANALYTICS] setUserId $id');
    }
    return _fa.setUserId(id: id);
  }

  @override
  Future<void> setOptIn(bool optIn) {
    if (kDebugMode) {
      debugPrint('[ANALYTICS] setOptIn $optIn');
    }
    return _fa.setAnalyticsCollectionEnabled(optIn);
  }
}
