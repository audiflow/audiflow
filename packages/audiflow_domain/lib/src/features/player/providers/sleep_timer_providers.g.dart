// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_timer_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Backs [SleepTimerController]'s persistence of remembered
/// minutes/episodes values.

@ProviderFor(sleepTimerPreferencesDatasource)
final sleepTimerPreferencesDatasourceProvider =
    SleepTimerPreferencesDatasourceProvider._();

/// Backs [SleepTimerController]'s persistence of remembered
/// minutes/episodes values.

final class SleepTimerPreferencesDatasourceProvider
    extends
        $FunctionalProvider<
          SleepTimerPreferencesDatasource,
          SleepTimerPreferencesDatasource,
          SleepTimerPreferencesDatasource
        >
    with $Provider<SleepTimerPreferencesDatasource> {
  /// Backs [SleepTimerController]'s persistence of remembered
  /// minutes/episodes values.
  SleepTimerPreferencesDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sleepTimerPreferencesDatasourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sleepTimerPreferencesDatasourceHash();

  @$internal
  @override
  $ProviderElement<SleepTimerPreferencesDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SleepTimerPreferencesDatasource create(Ref ref) {
    return sleepTimerPreferencesDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SleepTimerPreferencesDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SleepTimerPreferencesDatasource>(
        value,
      ),
    );
  }
}

String _$sleepTimerPreferencesDatasourceHash() =>
    r'48a43781bd7da9817213e2470cf6dd901f70e652';
