import 'package:audiflow/features/monitoring/analytics_client.dart';
import 'package:audiflow/utils/logger.dart';

class LoggerAnalyticsClient implements AnalyticsClient {
  LoggerAnalyticsClient();

  String? _userId;
  bool _enabled = false;

  @override
  Future<void> identifyUser(String userId) async {
    _userId = userId;
    if (_enabled) {
      logger.i('[analytics] Identifying user with id: $userId');
    }
  }

  @override
  Future<void> resetUser() async {
    _userId = '';
    if (_enabled) {
      logger.i('[analytics] Resetting user');
    }
  }

  @override
  Future<void> setAnalyticsCollectionEnabled({required bool enabled}) async {
    _enabled = enabled;
    logger.i('[analytics] Setting analytics collection enabled to: $enabled');
  }

  @override
  Future<void> trackScreenView(String routeName, String action) async {
    if (_enabled) {
      logger.i('[analytics] trackScreenView view: $routeName, action: $action');
    }
  }

  @override
  Future<void> trackHomeView() async {
    if (_enabled) {
      logger.i('[analytics] trackHomeView');
    }
  }

  @override
  Future<void> trackOpenApp() async {
    if (_enabled) {
      logger.i('[analytics] trackOpenApp');
    }
  }

  @override
  Future<void> trackStartPlayback({
    required int pid,
    required int eid,
    required int? sid,
    required String title,
    required DateTime pubDate,
  }) async {
    if (_enabled) {
      logger.i('[analytics] trackStartPlayback('
          'pid: $pid, eid: $eid, sid: $sid, '
          'title: $title, pubDate: $pubDate'
          ')');
    }
  }
}
