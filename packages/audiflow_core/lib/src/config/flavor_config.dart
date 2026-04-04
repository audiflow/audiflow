/// Flavor configuration for different build environments
enum Flavor { dev, stg, prod }

/// Configuration for different flavors
class FlavorConfig {
  FlavorConfig._({
    required this.flavor,
    required this.name,
    required this.apiBaseUrl,
    required this.smartPlaylistConfigBaseUrl,
    required this.enableAnalytics,
    required this.enableCrashReporting,
    required this.enableHttpTracing,
  });

  final Flavor flavor;
  final String name;
  final String apiBaseUrl;
  final String smartPlaylistConfigBaseUrl;
  final bool enableAnalytics;
  final bool enableCrashReporting;
  final bool enableHttpTracing;

  static FlavorConfig? _current;

  /// Get current flavor configuration
  static FlavorConfig get current {
    if (_current == null) {
      throw StateError(
        'FlavorConfig not initialized. Call initialize() first.',
      );
    }
    return _current!;
  }

  /// Development flavor
  static FlavorConfig get dev => FlavorConfig._(
    flavor: Flavor.dev,
    name: 'Development',
    apiBaseUrl: 'https://api-dev.audiflow.example.com',
    smartPlaylistConfigBaseUrl:
        'https://audiflow.github.io/audiflow-smartplaylist/assets-dev/v3',
    enableAnalytics: false,
    enableCrashReporting: true,
    enableHttpTracing: true,
  );

  /// Staging flavor
  static FlavorConfig get stg => FlavorConfig._(
    flavor: Flavor.stg,
    name: 'Staging',
    apiBaseUrl: 'https://api-stg.audiflow.example.com',
    smartPlaylistConfigBaseUrl:
        'https://audiflow.github.io/audiflow-smartplaylist/assets-stg/v3',
    enableAnalytics: true,
    enableCrashReporting: true,
    enableHttpTracing: true,
  );

  /// Production flavor
  static FlavorConfig get prod => FlavorConfig._(
    flavor: Flavor.prod,
    name: 'Production',
    apiBaseUrl: 'https://api.audiflow.example.com',
    smartPlaylistConfigBaseUrl:
        'https://audiflow.github.io/audiflow-smartplaylist/assets/v3',
    enableAnalytics: true,
    enableCrashReporting: true,
    enableHttpTracing: false,
  );

  /// Initialize with a flavor
  static void initialize(FlavorConfig config) {
    _current = config;
  }

  /// Get environment file name for this flavor
  String get envFile => '.env.${flavor.name}';
}
