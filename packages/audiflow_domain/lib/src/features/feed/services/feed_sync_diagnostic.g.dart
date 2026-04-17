// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_sync_diagnostic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod-scoped diagnostic sink for [FeedSyncService]. Override in
/// `audiflow_app` to emit Sentry breadcrumbs / messages.

@ProviderFor(feedSyncDiagnosticSink)
final feedSyncDiagnosticSinkProvider = FeedSyncDiagnosticSinkProvider._();

/// Riverpod-scoped diagnostic sink for [FeedSyncService]. Override in
/// `audiflow_app` to emit Sentry breadcrumbs / messages.

final class FeedSyncDiagnosticSinkProvider
    extends
        $FunctionalProvider<
          FeedSyncDiagnosticSink,
          FeedSyncDiagnosticSink,
          FeedSyncDiagnosticSink
        >
    with $Provider<FeedSyncDiagnosticSink> {
  /// Riverpod-scoped diagnostic sink for [FeedSyncService]. Override in
  /// `audiflow_app` to emit Sentry breadcrumbs / messages.
  FeedSyncDiagnosticSinkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedSyncDiagnosticSinkProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedSyncDiagnosticSinkHash();

  @$internal
  @override
  $ProviderElement<FeedSyncDiagnosticSink> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FeedSyncDiagnosticSink create(Ref ref) {
    return feedSyncDiagnosticSink(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedSyncDiagnosticSink value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedSyncDiagnosticSink>(value),
    );
  }
}

String _$feedSyncDiagnosticSinkHash() =>
    r'b946507e282ce72c6b21230231e7aee23d2c6619';
