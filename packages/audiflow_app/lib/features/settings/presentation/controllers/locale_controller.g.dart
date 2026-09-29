// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controls the app-wide UI language.
///
/// `null` means "follow the device locale". The root [MaterialApp] watches
/// this so a change applies immediately, without a restart.

@ProviderFor(LocaleController)
final localeControllerProvider = LocaleControllerProvider._();

/// Controls the app-wide UI language.
///
/// `null` means "follow the device locale". The root [MaterialApp] watches
/// this so a change applies immediately, without a restart.
final class LocaleControllerProvider
    extends $NotifierProvider<LocaleController, Locale?> {
  /// Controls the app-wide UI language.
  ///
  /// `null` means "follow the device locale". The root [MaterialApp] watches
  /// this so a change applies immediately, without a restart.
  LocaleControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeControllerHash();

  @$internal
  @override
  LocaleController create() => LocaleController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale?>(value),
    );
  }
}

String _$localeControllerHash() => r'9bca26067633093a337e4091ff1623234d519b1c';

/// Controls the app-wide UI language.
///
/// `null` means "follow the device locale". The root [MaterialApp] watches
/// this so a change applies immediately, without a restart.

abstract class _$LocaleController extends $Notifier<Locale?> {
  Locale? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Locale?, Locale?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Locale?, Locale?>,
              Locale?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
