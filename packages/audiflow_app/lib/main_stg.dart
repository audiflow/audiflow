import 'package:audiflow_core/audiflow_core.dart';

import 'main.dart' as app;

Future<void> main() => app.appMain(
  flavor: Flavor.stg,
  presetConfigBaseUrl:
      'https://audiflow.github.io/audiflow-preset/assets-stg/v7',
);
