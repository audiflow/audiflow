import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/providers/settings_provider.dart';
import 'package:seasoning/ui/themes.dart';

export 'package:seasoning/ui/themes.dart';

part 'theme_provider.g.dart';

@riverpod
ThemeData theme(ThemeRef ref) {
  final settings = ref.watch(settingsControllerProvider);
  return settings.theme == 'dark'
      ? Themes.darkTheme().themeData
      : Themes.lightTheme().themeData;
}
