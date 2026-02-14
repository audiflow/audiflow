// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controls the app-wide theme mode.
///
/// Reads the initial value from [AppSettingsRepository] and
/// propagates changes to both the repository and the reactive
/// state so [MaterialApp] rebuilds immediately.

@ProviderFor(ThemeModeController)
final themeModeControllerProvider = ThemeModeControllerProvider._();

/// Controls the app-wide theme mode.
///
/// Reads the initial value from [AppSettingsRepository] and
/// propagates changes to both the repository and the reactive
/// state so [MaterialApp] rebuilds immediately.
final class ThemeModeControllerProvider
    extends $NotifierProvider<ThemeModeController, ThemeMode> {
  /// Controls the app-wide theme mode.
  ///
  /// Reads the initial value from [AppSettingsRepository] and
  /// propagates changes to both the repository and the reactive
  /// state so [MaterialApp] rebuilds immediately.
  ThemeModeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeControllerHash();

  @$internal
  @override
  ThemeModeController create() => ThemeModeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeModeControllerHash() =>
    r'a326c09bc80c247ead11263aacde4569372eb51c';

/// Controls the app-wide theme mode.
///
/// Reads the initial value from [AppSettingsRepository] and
/// propagates changes to both the repository and the reactive
/// state so [MaterialApp] rebuilds immediately.

abstract class _$ThemeModeController extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Controls the app-wide text scale factor.
///
/// Reads the initial value from [AppSettingsRepository] and
/// propagates changes so [MediaQuery] wrapping [MaterialApp]
/// updates immediately.

@ProviderFor(TextScaleController)
final textScaleControllerProvider = TextScaleControllerProvider._();

/// Controls the app-wide text scale factor.
///
/// Reads the initial value from [AppSettingsRepository] and
/// propagates changes so [MediaQuery] wrapping [MaterialApp]
/// updates immediately.
final class TextScaleControllerProvider
    extends $NotifierProvider<TextScaleController, double> {
  /// Controls the app-wide text scale factor.
  ///
  /// Reads the initial value from [AppSettingsRepository] and
  /// propagates changes so [MediaQuery] wrapping [MaterialApp]
  /// updates immediately.
  TextScaleControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'textScaleControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$textScaleControllerHash();

  @$internal
  @override
  TextScaleController create() => TextScaleController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$textScaleControllerHash() =>
    r'4f29606524f6d41c807d7a91e32fe45ec8f05f6c';

/// Controls the app-wide text scale factor.
///
/// Reads the initial value from [AppSettingsRepository] and
/// propagates changes so [MediaQuery] wrapping [MaterialApp]
/// updates immediately.

abstract class _$TextScaleController extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
