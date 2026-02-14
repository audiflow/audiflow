import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_controller.g.dart';

/// Controls the app-wide theme mode.
///
/// Reads the initial value from [AppSettingsRepository] and
/// propagates changes to both the repository and the reactive
/// state so [MaterialApp] rebuilds immediately.
@Riverpod(keepAlive: true)
class ThemeModeController extends _$ThemeModeController {
  @override
  ThemeMode build() {
    final repo = ref.watch(appSettingsRepositoryProvider);
    return repo.getThemeMode();
  }

  /// Persists [mode] and updates the reactive state.
  Future<void> setThemeMode(ThemeMode mode) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    await repo.setThemeMode(mode);
    state = mode;
  }
}

/// Controls the app-wide text scale factor.
///
/// Reads the initial value from [AppSettingsRepository] and
/// propagates changes so [MediaQuery] wrapping [MaterialApp]
/// updates immediately.
@Riverpod(keepAlive: true)
class TextScaleController extends _$TextScaleController {
  @override
  double build() {
    final repo = ref.watch(appSettingsRepositoryProvider);
    return repo.getTextScale();
  }

  /// Persists [scale] and updates the reactive state.
  Future<void> setTextScale(double scale) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    await repo.setTextScale(scale);
    state = scale;
  }
}
