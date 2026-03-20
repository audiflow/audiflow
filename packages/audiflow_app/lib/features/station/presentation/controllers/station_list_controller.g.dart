// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(stationList)
final stationListProvider = StationListProvider._();

final class StationListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Station>>,
          List<Station>,
          Stream<List<Station>>
        >
    with $FutureModifier<List<Station>>, $StreamProvider<List<Station>> {
  StationListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stationListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stationListHash();

  @$internal
  @override
  $StreamProviderElement<List<Station>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Station>> create(Ref ref) {
    return stationList(ref);
  }
}

String _$stationListHash() => r'549846bffd5ce27f280a35b93f2c04299209f4f1';
