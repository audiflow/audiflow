import 'package:audiflow/features/monitoring/analytics_client.dart';
import 'package:audiflow/features/monitoring/logger_analytics_client.dart';
import 'package:audiflow/features/monitoring/mixpanel_analytics_client.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_facade.g.dart';

@Riverpod(keepAlive: true)
AnalyticsFacade analyticsFacade(AnalyticsFacadeRef ref) {
  final mixpanelAnalyticsClient = ref.watch(mixpanelAnalyticsClientProvider);
  return AnalyticsFacade([
    mixpanelAnalyticsClient,
    if (!kReleaseMode) LoggerAnalyticsClient(),
  ]);
}

class AnalyticsFacade implements AnalyticsClient {
  const AnalyticsFacade(this.clients);

  final List<AnalyticsClient> clients;

  Future<void> _dispatch(
    Future<void> Function(AnalyticsClient client) work,
  ) async {
    for (final client in clients) {
      await work(client);
    }
  }

  @override
  Future<void> setAnalyticsCollectionEnabled({required bool enabled}) =>
      _dispatch(
        (c) => c.setAnalyticsCollectionEnabled(enabled: enabled),
      );

  @override
  Future<void> identifyUser(String userId) => _dispatch(
        (c) => c.identifyUser(userId),
      );

  @override
  Future<void> resetUser() => _dispatch(
        (c) => c.resetUser(),
      );

  @override
  Future<void> trackScreenView(String routeName, String action) => _dispatch(
        (c) => c.trackScreenView(routeName, action),
      );

  @override
  Future<void> trackHomeView() => _dispatch(
        (c) => c.trackHomeView(),
      );

  @override
  Future<void> trackOpenApp() => _dispatch(
        (c) => c.trackOpenApp(),
      );

  @override
  Future<void> trackStartPlayback({
    required int pid,
    required int eid,
    required int? sid,
    required String title,
    required DateTime pubDate,
  }) =>
      _dispatch(
        (c) => c.trackStartPlayback(
          pid: pid,
          eid: eid,
          sid: sid,
          title: title,
          pubDate: pubDate,
        ),
      );
}
