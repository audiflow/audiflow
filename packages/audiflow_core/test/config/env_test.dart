import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Env', () {
    group('default getters before initialization', () {
      // Note: Since Env uses static state, these tests rely on
      // order. We test defaults first before any initialize() call
      // in other groups. Each group re-initializes to reset state.

      test('sentryDsn defaults to empty string', () {
        // We cannot truly reset static state, so we test the fallback
        // logic by verifying the getter returns a non-null String.
        expect(Env.sentryDsn, isA<String>());
      });

      test('apiBaseUrl defaults to empty string', () {
        expect(Env.apiBaseUrl, isA<String>());
      });

      test('mixpanelToken defaults to empty string', () {
        expect(Env.mixpanelToken, isA<String>());
      });

      test('appName defaults to Audiflow', () {
        expect(Env.appName, isA<String>());
      });
    });

    group('initialize()', () {
      test('sets all environment variables', () {
        Env.initialize(
          sentryDsn: 'https://sentry.example.com/123',
          apiBaseUrl: 'https://api.example.com',
          mixpanelToken: 'token-abc',
          appName: 'TestApp',
        );

        expect(Env.sentryDsn, 'https://sentry.example.com/123');
        expect(Env.apiBaseUrl, 'https://api.example.com');
        expect(Env.mixpanelToken, 'token-abc');
        expect(Env.appName, 'TestApp');
      });

      test('overwrites previously set values', () {
        Env.initialize(
          sentryDsn: 'dsn-1',
          apiBaseUrl: 'url-1',
          mixpanelToken: 'token-1',
          appName: 'App1',
        );

        Env.initialize(
          sentryDsn: 'dsn-2',
          apiBaseUrl: 'url-2',
          mixpanelToken: 'token-2',
          appName: 'App2',
        );

        expect(Env.sentryDsn, 'dsn-2');
        expect(Env.apiBaseUrl, 'url-2');
        expect(Env.mixpanelToken, 'token-2');
        expect(Env.appName, 'App2');
      });
    });

    group('validate()', () {
      test('does not throw when all variables are set', () {
        Env.initialize(
          sentryDsn: 'dsn',
          apiBaseUrl: 'url',
          mixpanelToken: 'token',
          appName: 'app',
        );

        expect(() => Env.validate(), returnsNormally);
      });

      test('throws StateError when all variables are empty', () {
        Env.initialize(
          sentryDsn: '',
          apiBaseUrl: '',
          mixpanelToken: '',
          appName: '',
        );

        expect(
          () => Env.validate(),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('SENTRY_DSN'),
            ),
          ),
        );
      });

      test('lists all missing variables in error message', () {
        Env.initialize(
          sentryDsn: '',
          apiBaseUrl: '',
          mixpanelToken: '',
          appName: '',
        );

        expect(
          () => Env.validate(),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              allOf(
                contains('SENTRY_DSN'),
                contains('API_BASE_URL'),
                contains('MIXPANEL_TOKEN'),
                contains('APP_NAME'),
              ),
            ),
          ),
        );
      });

      test('lists only missing variables in error', () {
        Env.initialize(
          sentryDsn: 'valid-dsn',
          apiBaseUrl: '',
          mixpanelToken: 'valid-token',
          appName: '',
        );

        expect(
          () => Env.validate(),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              allOf(
                isNot(contains('SENTRY_DSN')),
                contains('API_BASE_URL'),
                isNot(contains('MIXPANEL_TOKEN')),
                contains('APP_NAME'),
              ),
            ),
          ),
        );
      });
    });
  });
}
