/// Environment variables configuration
class Env {
  Env._();

  static String? _sentryDsn;
  static String? _apiBaseUrl;
  static String? _mixpanelToken;
  static String? _appName;

  /// Sentry DSN for error tracking
  static String get sentryDsn => _sentryDsn ?? '';

  /// API base URL
  static String get apiBaseUrl => _apiBaseUrl ?? '';

  /// Mixpanel token for analytics
  static String get mixpanelToken => _mixpanelToken ?? '';

  /// Application name
  static String get appName => _appName ?? 'Audiflow';

  /// Initialize environment variables
  static void initialize({
    required String sentryDsn,
    required String apiBaseUrl,
    required String mixpanelToken,
    required String appName,
  }) {
    _sentryDsn = sentryDsn;
    _apiBaseUrl = apiBaseUrl;
    _mixpanelToken = mixpanelToken;
    _appName = appName;
  }

  /// Validate required environment variables
  static void validate() {
    final missing = <String>[];

    if (_sentryDsn == null || _sentryDsn!.isEmpty) {
      missing.add('SENTRY_DSN');
    }
    if (_apiBaseUrl == null || _apiBaseUrl!.isEmpty) {
      missing.add('API_BASE_URL');
    }
    if (_mixpanelToken == null || _mixpanelToken!.isEmpty) {
      missing.add('MIXPANEL_TOKEN');
    }
    if (_appName == null || _appName!.isEmpty) {
      missing.add('APP_NAME');
    }

    if (missing.isNotEmpty) {
      throw StateError(
        'Missing required environment variables: ${missing.join(", ")}',
      );
    }
  }
}
