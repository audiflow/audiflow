// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_edit_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Saves and feed rebuilds still running per station, shared by every
/// editor instance: an editor keeps saving after it closes, so one opened
/// again for the same station must wait for them before loading.

@ProviderFor(StationEditActivity)
final stationEditActivityProvider = StationEditActivityProvider._();

/// Saves and feed rebuilds still running per station, shared by every
/// editor instance: an editor keeps saving after it closes, so one opened
/// again for the same station must wait for them before loading.
final class StationEditActivityProvider
    extends $NotifierProvider<StationEditActivity, void> {
  /// Saves and feed rebuilds still running per station, shared by every
  /// editor instance: an editor keeps saving after it closes, so one opened
  /// again for the same station must wait for them before loading.
  StationEditActivityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stationEditActivityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stationEditActivityHash();

  @$internal
  @override
  StationEditActivity create() => StationEditActivity();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$stationEditActivityHash() =>
    r'd8c3103f9390f36c558394fd27dcfb096cd1bea3';

/// Saves and feed rebuilds still running per station, shared by every
/// editor instance: an editor keeps saving after it closes, so one opened
/// again for the same station must wait for them before loading.

abstract class _$StationEditActivity extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
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
    r'21cb2ed7c21f4ef662022484f49b4848ac6f3c62';

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
