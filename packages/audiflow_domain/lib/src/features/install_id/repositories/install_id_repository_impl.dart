import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'install_id_repository.dart';

class InstallIdRepositoryImpl implements InstallIdRepository {
  InstallIdRepositoryImpl(this._prefs, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  static const _key = 'analytics.install_id';

  final SharedPreferences _prefs;
  final Uuid _uuid;

  @override
  Future<String> getOrCreate() async {
    final existing = _prefs.getString(_key);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final generated = _uuid.v4();
    await _prefs.setString(_key, generated);
    return generated;
  }
}
