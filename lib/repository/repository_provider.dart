import 'package:audiflow/repository/repository.dart';
import 'package:audiflow/repository/sembast/sembast_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:audiflow/repository/repository.dart';

part 'repository_provider.g.dart';

@Riverpod(keepAlive: true)
Repository repository(RepositoryRef ref) => SembastRepository(ref);
