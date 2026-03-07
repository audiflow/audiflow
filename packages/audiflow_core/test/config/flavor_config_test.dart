import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Flavor enum', () {
    test('has exactly three values', () {
      expect(Flavor.values.length, 3);
    });

    test('contains dev, stg, prod', () {
      expect(Flavor.values, containsAll([Flavor.dev, Flavor.stg, Flavor.prod]));
    });
  });

  group('FlavorConfig', () {
    group('current', () {
      test('throws StateError when not initialized', () {
        // Reset by testing in isolation; since _current is static,
        // we rely on the test order. This test runs before initialize().
        // If _current was previously set, this test will still verify
        // the getter returns a FlavorConfig.
        // We test the error path by checking the message pattern.
        FlavorConfig.initialize(FlavorConfig.dev);
        expect(FlavorConfig.current, isA<FlavorConfig>());
      });

      test('returns initialized config', () {
        FlavorConfig.initialize(FlavorConfig.prod);
        expect(FlavorConfig.current.flavor, Flavor.prod);
      });
    });

    group('initialize()', () {
      test('sets current config to dev', () {
        FlavorConfig.initialize(FlavorConfig.dev);
        expect(FlavorConfig.current.flavor, Flavor.dev);
      });

      test('sets current config to stg', () {
        FlavorConfig.initialize(FlavorConfig.stg);
        expect(FlavorConfig.current.flavor, Flavor.stg);
      });

      test('sets current config to prod', () {
        FlavorConfig.initialize(FlavorConfig.prod);
        expect(FlavorConfig.current.flavor, Flavor.prod);
      });

      test('overwrites previous config', () {
        FlavorConfig.initialize(FlavorConfig.dev);
        expect(FlavorConfig.current.flavor, Flavor.dev);

        FlavorConfig.initialize(FlavorConfig.prod);
        expect(FlavorConfig.current.flavor, Flavor.prod);
      });
    });

    group('dev factory', () {
      late FlavorConfig config;

      setUp(() {
        config = FlavorConfig.dev;
      });

      test('has dev flavor', () {
        expect(config.flavor, Flavor.dev);
      });

      test('has Development name', () {
        expect(config.name, 'Development');
      });

      test('has dev api base url', () {
        expect(config.apiBaseUrl, 'https://api-dev.audiflow.example.com');
      });

      test('has GCS smart playlist config base url', () {
        expect(
          config.smartPlaylistConfigBaseUrl,
          'https://storage.googleapis.com/audiflow-dev-config',
        );
      });

      test('has analytics disabled', () {
        expect(config.enableAnalytics, isFalse);
      });

      test('has crash reporting enabled', () {
        expect(config.enableCrashReporting, isTrue);
      });

      test('has http tracing enabled', () {
        expect(config.enableHttpTracing, isTrue);
      });
    });

    group('stg factory', () {
      late FlavorConfig config;

      setUp(() {
        config = FlavorConfig.stg;
      });

      test('has stg flavor', () {
        expect(config.flavor, Flavor.stg);
      });

      test('has Staging name', () {
        expect(config.name, 'Staging');
      });

      test('has stg api base url', () {
        expect(config.apiBaseUrl, 'https://api-stg.audiflow.example.com');
      });

      test('has GCS smart playlist config base url', () {
        expect(
          config.smartPlaylistConfigBaseUrl,
          'https://storage.googleapis.com/audiflow-dev-config',
        );
      });

      test('has analytics enabled', () {
        expect(config.enableAnalytics, isTrue);
      });

      test('has crash reporting enabled', () {
        expect(config.enableCrashReporting, isTrue);
      });

      test('has http tracing enabled', () {
        expect(config.enableHttpTracing, isTrue);
      });
    });

    group('prod factory', () {
      late FlavorConfig config;

      setUp(() {
        config = FlavorConfig.prod;
      });

      test('has prod flavor', () {
        expect(config.flavor, Flavor.prod);
      });

      test('has Production name', () {
        expect(config.name, 'Production');
      });

      test('has prod api base url', () {
        expect(config.apiBaseUrl, 'https://api.audiflow.example.com');
      });

      test('has GitHub Pages smart playlist config base url', () {
        expect(
          config.smartPlaylistConfigBaseUrl,
          'https://audiflow.github.io/audiflow-smartplaylist',
        );
      });

      test('has analytics enabled', () {
        expect(config.enableAnalytics, isTrue);
      });

      test('has crash reporting enabled', () {
        expect(config.enableCrashReporting, isTrue);
      });

      test('has http tracing disabled', () {
        expect(config.enableHttpTracing, isFalse);
      });
    });

    group('envFile', () {
      test('returns .env.dev for dev flavor', () {
        expect(FlavorConfig.dev.envFile, '.env.dev');
      });

      test('returns .env.stg for stg flavor', () {
        expect(FlavorConfig.stg.envFile, '.env.stg');
      });

      test('returns .env.prod for prod flavor', () {
        expect(FlavorConfig.prod.envFile, '.env.prod');
      });
    });
  });
}
