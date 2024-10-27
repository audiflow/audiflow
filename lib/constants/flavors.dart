import 'package:flutter/services.dart';

enum Flavor { dev, stg, prod }

/// Global function to return the current flavor
Flavor getFlavor() {
  return switch (appFlavor) {
    'prod' => Flavor.prod,
    'stg' => Flavor.stg,
    'dev' => Flavor.dev,
    null => Flavor.dev, // * if not specified, default to dev
    _ => throw UnsupportedError('Invalid flavor: $appFlavor'),
  };
}
