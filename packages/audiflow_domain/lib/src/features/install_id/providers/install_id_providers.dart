import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/platform_providers.dart';
import '../repositories/install_id_repository.dart';
import '../repositories/install_id_repository_impl.dart';

part 'install_id_providers.g.dart';

@Riverpod(keepAlive: true)
InstallIdRepository installIdRepository(Ref ref) =>
    InstallIdRepositoryImpl(ref.watch(sharedPreferencesProvider));
