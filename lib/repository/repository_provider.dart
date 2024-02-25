import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/repository/repository.dart';
import 'package:seasoning/repository/sembast/sembast_repository.dart';

export 'package:seasoning/repository/repository.dart';

part 'repository_provider.g.dart';

@Riverpod(keepAlive: true)
Repository repository(RepositoryRef ref) => SembastRepository(ref);
