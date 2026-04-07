// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'developer_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controls visibility of developer info in episode detail screens.
///
/// Backed by SharedPreferences. Defaults to false.

@ProviderFor(DevShowDeveloperInfo)
final devShowDeveloperInfoProvider = DevShowDeveloperInfoProvider._();

/// Controls visibility of developer info in episode detail screens.
///
/// Backed by SharedPreferences. Defaults to false.
final class DevShowDeveloperInfoProvider
    extends $NotifierProvider<DevShowDeveloperInfo, bool> {
  /// Controls visibility of developer info in episode detail screens.
  ///
  /// Backed by SharedPreferences. Defaults to false.
  DevShowDeveloperInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'devShowDeveloperInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$devShowDeveloperInfoHash();

  @$internal
  @override
  DevShowDeveloperInfo create() => DevShowDeveloperInfo();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$devShowDeveloperInfoHash() =>
    r'2900671d0a6be47f40b3c25552b298181dc97476';

/// Controls visibility of developer info in episode detail screens.
///
/// Backed by SharedPreferences. Defaults to false.

abstract class _$DevShowDeveloperInfo extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
