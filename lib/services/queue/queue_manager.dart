import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/entities.dart';

part 'queue_manager.g.dart';

@Riverpod(keepAlive: true)
class QueueManager extends _$QueueManager {
  @override
  Queue build() => const Queue();

  Future<void> setup() => throw UnimplementedError();

  Future<String?> pop() => throw UnimplementedError();

  Future<void> prepend(Episode episode) => throw UnimplementedError();

  Future<void> append(Episode episode) => throw UnimplementedError();

  Future<void> swap(int index1, int index2) => throw UnimplementedError();

  Future<void> addAll(List<Episode> episodes) => throw UnimplementedError();

  Future<void> replaceAll(List<Episode> episodes) => throw UnimplementedError();

  Future<void> replaceAllAdHoc(List<Episode> episode) =>
      throw UnimplementedError();

  Future<void> remove(int index) => throw UnimplementedError();

  Future<void> clear() => throw UnimplementedError();
}
