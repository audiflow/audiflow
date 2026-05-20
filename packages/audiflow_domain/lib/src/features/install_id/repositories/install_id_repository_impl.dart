import 'package:uuid/uuid.dart';

import '../../../common/datasources/shared_preferences_datasource.dart';
import 'install_id_repository.dart';

class InstallIdRepositoryImpl implements InstallIdRepository {
  InstallIdRepositoryImpl(this._ds, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  static const _key = 'analytics.install_id';

  final SharedPreferencesDataSource _ds;
  final Uuid _uuid;

  @override
  Future<String> getOrCreate() async {
    final existing = _ds.getString(_key);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final generated = _uuid.v4();
    await _ds.setString(_key, generated);
    return generated;
  }
}
