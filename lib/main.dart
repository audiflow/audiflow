import 'package:audiflow/core/build_config/build_config_provider.dart';
import 'package:audiflow/initializer.dart';
import 'package:audiflow/ui/app/audiflow_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final (buildConfig: buildConfig) = await AppInitializer.initialize();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // NavigationHelper.setup();
  // await SettingsService.setup();

  runApp(
    ProviderScope(
      overrides: [
        ...await initializeProviders(),
        buildConfigProvider.overrideWithValue(buildConfig),
      ],
      child: const AudiflowApp(),
    ),
  );
}
