// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'force_update_reporter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Injection seam: the controller reads this provider so tests can
/// swap in a recording fake. Defaults to the real Sentry implementation.

@ProviderFor(forceUpdateReporter)
final forceUpdateReporterProvider = ForceUpdateReporterProvider._();

/// Injection seam: the controller reads this provider so tests can
/// swap in a recording fake. Defaults to the real Sentry implementation.

final class ForceUpdateReporterProvider
    extends
        $FunctionalProvider<
          ForceUpdateReporter,
          ForceUpdateReporter,
          ForceUpdateReporter
        >
    with $Provider<ForceUpdateReporter> {
  /// Injection seam: the controller reads this provider so tests can
  /// swap in a recording fake. Defaults to the real Sentry implementation.
  ForceUpdateReporterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forceUpdateReporterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forceUpdateReporterHash();

  @$internal
  @override
  $ProviderElement<ForceUpdateReporter> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ForceUpdateReporter create(Ref ref) {
    return forceUpdateReporter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ForceUpdateReporter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ForceUpdateReporter>(value),
    );
  }
}

String _$forceUpdateReporterHash() =>
    r'30cf86536f256f60b07a0c9f0b6707da7b7dc9be';
