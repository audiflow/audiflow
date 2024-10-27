enum Flavor {
  dev,
  stg,
  prod,
}

class F {
  F._();

  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'audiflow dev';
      case Flavor.stg:
        return 'audiflow stg';
      case Flavor.prod:
        return 'audiflow';
      case null:
        return 'title';
    }
  }
}
