// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background_task_canceller_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the canceller for scheduled background tasks (feed refresh and
/// download).
///
/// "Reset All Data" awaits it before clearing storage so a Workmanager
/// task cannot start after the clear. Workmanager lives in the app package,
/// so the app overrides this at startup; the default is a no-op for hosts
/// without background tasks.

@ProviderFor(backgroundTaskCanceller)
final backgroundTaskCancellerProvider = BackgroundTaskCancellerProvider._();

/// Provides the canceller for scheduled background tasks (feed refresh and
/// download).
///
/// "Reset All Data" awaits it before clearing storage so a Workmanager
/// task cannot start after the clear. Workmanager lives in the app package,
/// so the app overrides this at startup; the default is a no-op for hosts
/// without background tasks.

final class BackgroundTaskCancellerProvider
    extends
        $FunctionalProvider<WriterCanceller, WriterCanceller, WriterCanceller>
    with $Provider<WriterCanceller> {
  /// Provides the canceller for scheduled background tasks (feed refresh and
  /// download).
  ///
  /// "Reset All Data" awaits it before clearing storage so a Workmanager
  /// task cannot start after the clear. Workmanager lives in the app package,
  /// so the app overrides this at startup; the default is a no-op for hosts
  /// without background tasks.
  BackgroundTaskCancellerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backgroundTaskCancellerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backgroundTaskCancellerHash();

  @$internal
  @override
  $ProviderElement<WriterCanceller> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WriterCanceller create(Ref ref) {
    return backgroundTaskCanceller(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WriterCanceller value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WriterCanceller>(value),
    );
  }
}

String _$backgroundTaskCancellerHash() =>
    r'eda738ebb80bb7fbffad6a1ee05fa1f409ed083e';
