import 'dart:async';

import 'package:audiflow/core/api_cache_dir.dart';
import 'package:audiflow/core/build_config/app_build_config.dart';
import 'package:audiflow/core/logger.dart';
import 'package:audiflow/core/shared_preferences.dart';
import 'package:audiflow/services/audio/audio_player_service.dart';
import 'package:audiflow/services/audio/mobile_audio_player_service.dart';
import 'package:audiflow/services/queue/default_queue_manager.dart';
import 'package:audiflow/services/queue/queue_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef InitializedValues = ({
  BuildConfig buildConfig,
});

final class AppInitializer {
  AppInitializer._();

  static Future<InitializedValues> initialize() async {
    final buildConfig = await _initializeBuildConfig();
    logger.t(buildConfig);
    return (buildConfig: buildConfig);
  }

  static Future<BuildConfig> _initializeBuildConfig() async {
    final packageInfo = await PackageInfo.fromPlatform();

    return BuildConfig(
      // ignore: do_not_use_environment
      appFlavor: const String.fromEnvironment('flavor'),
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      buildSignature: packageInfo.buildSignature,
      installerStore: packageInfo.installerStore,
    );
  }
}

Future<List<Override>> initializeProviders() async {
  final overrides = <Override>[];

  final preferences = await SharedPreferences.getInstance();
  final tempDir = await getTemporaryDirectory();
  final appDocDir = await getApplicationDocumentsDirectory();
  overrides.addAll(
    [
      sharedPreferencesProvider.overrideWithValue(preferences),
      apiCacheDirProvider.overrideWithValue(tempDir.path),
      appDocDirProvider.overrideWithValue(appDocDir.path),
      audioPlayerServiceProvider.overrideWith(MobileAudioPlayerService.new),
      queueManagerProvider.overrideWith(DefaultQueueManager.new),
    ],
  );
  return overrides;
}
