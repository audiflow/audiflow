import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'isar_repository.g.dart';

@Riverpod(keepAlive: true)
Isar isarRepository(IsarRepositoryRef ref) {
  // * Override this in the main method
  throw UnimplementedError();
}
