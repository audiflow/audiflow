import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/services/settings/settings_service.dart';
import 'package:audiflow/ui/themes.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:audiflow/ui/themes.dart';

part 'theme_provider.g.dart';

@Riverpod(keepAlive: true)
ThemeData theme(ThemeRef ref) {
  final settings = ref.watch(settingsServiceProvider);
  switch (settings.theme) {
    case BrightnessMode.dark:
      return Themes.darkTheme().themeData;
    case BrightnessMode.light:
      return Themes.lightTheme().themeData;
    case BrightnessMode.system:
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? Themes.darkTheme().themeData
          : Themes.lightTheme().themeData;
  }
}
