abstract class AnalyticsClient {
  Future<void> setAnalyticsCollectionEnabled({required bool enabled});

  Future<void> identifyUser(String userId);

  Future<void> resetUser();

  Future<void> trackScreenView(String routeName, String action);

  Future<void> trackOpenApp();

  Future<void> trackHomeView();

  Future<void> trackStartPlayback({
    required int pid,
    required int eid,
    required int? sid,
    required String title,
    required DateTime pubDate,
  });
}
