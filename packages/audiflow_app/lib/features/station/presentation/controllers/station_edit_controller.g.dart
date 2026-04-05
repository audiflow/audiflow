// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_edit_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StationEditController)
final stationEditControllerProvider = StationEditControllerFamily._();

final class StationEditControllerProvider
    extends $NotifierProvider<StationEditController, StationEditState> {
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
    r'3d00cfbddd793f6e020be2d9dd4ba2c43e4c99f9';

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

  StationEditControllerProvider call(int? stationId) =>
      StationEditControllerProvider._(argument: stationId, from: this);

  @override
  String toString() => r'stationEditControllerProvider';
}

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
