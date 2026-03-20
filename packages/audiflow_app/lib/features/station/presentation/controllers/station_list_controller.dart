import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'station_list_controller.g.dart';

@riverpod
Stream<List<Station>> stationList(Ref ref) {
  return ref.watch(stationRepositoryProvider).watchAll();
}
