import 'package:package_info_plus/package_info_plus.dart';

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

  BuildConfig.fromPackageInfo({
    required PackageInfo packageInfo,
    required String appFlavor,
  }) : this(
          appFlavor: appFlavor,
          appName: packageInfo.appName,
          packageName: packageInfo.packageName,
          version: packageInfo.version,
          buildNumber: packageInfo.buildNumber,
          buildSignature: packageInfo.buildSignature,
          installerStore: packageInfo.installerStore,
        );

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
