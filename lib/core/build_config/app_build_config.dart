/// Product Flavor
enum Flavor {
  dev,
  stg,
  prd,
}

final class BuildConfig {
  BuildConfig({
    required String appFlavor,
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    required this.buildSignature,
    this.installerStore,
  }) : flavor = switch (appFlavor) {
          'dev' => Flavor.dev,
          'stg' => Flavor.stg,
          'prod' => Flavor.prd,
          // default flavor
          _ => Flavor.dev,
        };

  String appName;

  String packageName;

  String version;

  String buildNumber;

  String buildSignature;

  Flavor flavor;

  String? installerStore;

  @override
  String toString() => 'AppBuildConfig('
      'appName: $appName, '
      'buildNumber: $buildNumber, '
      'packageName: $packageName, '
      'version: $version, '
      'buildSignature: $buildSignature, '
      'flavor: $flavor, '
      'installerStore: $installerStore)';
}
