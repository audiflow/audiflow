import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seasoning/entities/entities.dart';

abstract class QueueManager implements Notifier<Queue> {
  Future<void> setup();

  Future<String?> pop();

  Future<void> prepend(Episode episode);

  Future<void> append(Episode episode);

  Future<void> swap(int index1, int index2);

  Future<void> addAll(List<Episode> episodes);

  Future<void> replaceAll(List<Episode> episodes);

  Future<void> replaceAllAdHoc(List<Episode> episode);

  Future<void> remove(int index);

  Future<void> clear();
}
