class Env {
  Env._();

  static String get sentryDsn => const String.fromEnvironment('SENTRY_DSN');
}
