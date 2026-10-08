// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_edit_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Edits a station and saves every change as it happens; there is no save
/// button to forget.
///
/// A new station is created once its first podcast is selected (leaving
/// before that discards it) and is saved in place from then on. An existing
/// station may be left with no podcasts; only an explicit delete removes
/// it. A blank name never reaches the database: a new station falls back to
/// its default name and an existing one keeps its saved name.
///
/// Settings are written immediately, one write at a time. The episode
/// reconcile is costlier, so it waits for the edits to settle and runs at
/// the latest when the editor closes.

@ProviderFor(StationEditController)
final stationEditControllerProvider = StationEditControllerFamily._();

/// Edits a station and saves every change as it happens; there is no save
/// button to forget.
///
/// A new station is created once its first podcast is selected (leaving
/// before that discards it) and is saved in place from then on. An existing
/// station may be left with no podcasts; only an explicit delete removes
/// it. A blank name never reaches the database: a new station falls back to
/// its default name and an existing one keeps its saved name.
///
/// Settings are written immediately, one write at a time. The episode
/// reconcile is costlier, so it waits for the edits to settle and runs at
/// the latest when the editor closes.
final class StationEditControllerProvider
    extends $NotifierProvider<StationEditController, StationEditState> {
  /// Edits a station and saves every change as it happens; there is no save
  /// button to forget.
  ///
  /// A new station is created once its first podcast is selected (leaving
  /// before that discards it) and is saved in place from then on. An existing
  /// station may be left with no podcasts; only an explicit delete removes
  /// it. A blank name never reaches the database: a new station falls back to
  /// its default name and an existing one keeps its saved name.
  ///
  /// Settings are written immediately, one write at a time. The episode
  /// reconcile is costlier, so it waits for the edits to settle and runs at
  /// the latest when the editor closes.
  StationEditControllerProvider._({
    required StationEditControllerFamily super.from,
    required int? super.argument,
  }) : super(
         retry: null,
         name: r'stationEditControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$stationEditControllerHash();

  @override
  String toString() {
    return r'stationEditControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  StationEditController create() => StationEditController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StationEditState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StationEditState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StationEditControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$stationEditControllerHash() =>
    r'14cfe3ed9d711de6a600c8ff3c2da2f7e3de327b';

/// Edits a station and saves every change as it happens; there is no save
/// button to forget.
///
/// A new station is created once its first podcast is selected (leaving
/// before that discards it) and is saved in place from then on. An existing
/// station may be left with no podcasts; only an explicit delete removes
/// it. A blank name never reaches the database: a new station falls back to
/// its default name and an existing one keeps its saved name.
///
/// Settings are written immediately, one write at a time. The episode
/// reconcile is costlier, so it waits for the edits to settle and runs at
/// the latest when the editor closes.

final class StationEditControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          StationEditController,
          StationEditState,
          StationEditState,
          StationEditState,
          int?
        > {
  StationEditControllerFamily._()
    : super(
        retry: null,
        name: r'stationEditControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Edits a station and saves every change as it happens; there is no save
  /// button to forget.
  ///
  /// A new station is created once its first podcast is selected (leaving
  /// before that discards it) and is saved in place from then on. An existing
  /// station may be left with no podcasts; only an explicit delete removes
  /// it. A blank name never reaches the database: a new station falls back to
  /// its default name and an existing one keeps its saved name.
  ///
  /// Settings are written immediately, one write at a time. The episode
  /// reconcile is costlier, so it waits for the edits to settle and runs at
  /// the latest when the editor closes.

  StationEditControllerProvider call(int? stationId) =>
      StationEditControllerProvider._(argument: stationId, from: this);

  @override
  String toString() => r'stationEditControllerProvider';
}

/// Edits a station and saves every change as it happens; there is no save
/// button to forget.
///
/// A new station is created once its first podcast is selected (leaving
/// before that discards it) and is saved in place from then on. An existing
/// station may be left with no podcasts; only an explicit delete removes
/// it. A blank name never reaches the database: a new station falls back to
/// its default name and an existing one keeps its saved name.
///
/// Settings are written immediately, one write at a time. The episode
/// reconcile is costlier, so it waits for the edits to settle and runs at
/// the latest when the editor closes.

abstract class _$StationEditController extends $Notifier<StationEditState> {
  late final _$args = ref.$arg as int?;
  int? get stationId => _$args;

  StationEditState build(int? stationId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<StationEditState, StationEditState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StationEditState, StationEditState>,
              StationEditState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
