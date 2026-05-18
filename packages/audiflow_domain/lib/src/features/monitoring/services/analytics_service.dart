import '../models/analytics_event.dart';

abstract interface class AnalyticsService {
  Future<void> log(AnalyticsEvent event);

  /// Identify the current install. Pass null on opt-out.
  Future<void> setUserId(String? id);

  /// Toggle event recording at the SDK boundary.
  Future<void> setOptIn(bool optIn);
}
