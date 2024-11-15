import 'package:audiflow/features/monitoring/analytics_client.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mixpanel_analytics_client.g.dart';

class MixpanelAnalyticsClient implements AnalyticsClient {
  const MixpanelAnalyticsClient(this._mixpanel);

  final Mixpanel _mixpanel;

  @override
  Future<void> setAnalyticsCollectionEnabled({required bool enabled}) async {
    if (enabled) {
      _mixpanel.optInTracking();
    } else {
      _mixpanel.optOutTracking();
    }
  }

  @override
  Future<void> identifyUser(String userId) async {
    await _mixpanel.identify(userId);
  }

  @override
  Future<void> resetUser() async {
    await _mixpanel.reset();
  }

  @override
  Future<void> trackScreenView(String routeName, String action) async {
    await _mixpanel.track(
      'Screen View',
      properties: {
        'name': routeName,
        'action': action,
      },
    );
  }

  @override
  Future<void> trackHomeView() async {
    await _mixpanel.track('homeView');
  }

  @override
  Future<void> trackOpenApp() async {
    await _mixpanel.track('openApp');
  }

  @override
  Future<void> trackStartPlayback({
    required int pid,
    required int eid,
    required int? sid,
    required String title,
    required DateTime pubDate,
  }) async {
    await _mixpanel.track(
      'playBack',
      properties: {
        'pid': pid,
        'eid': eid,
        'sid': sid,
        'title': title,
        'pubDate': pubDate,
      },
    );
  }
}

@Riverpod(keepAlive: true)
MixpanelAnalyticsClient mixpanelAnalyticsClient(
  MixpanelAnalyticsClientRef ref,
) {
  // * Override this in the main method
  throw UnimplementedError();
}
