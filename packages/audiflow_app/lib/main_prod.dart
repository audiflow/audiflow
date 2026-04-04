import 'package:audiflow_core/audiflow_core.dart';

import 'main.dart' as app;

Future<void> main() => app.appMain(
  flavor: Flavor.prod,
  smartPlaylistConfigBaseUrl:
      'https://audiflow.github.io/audiflow-smartplaylist/assets/v3',
);
