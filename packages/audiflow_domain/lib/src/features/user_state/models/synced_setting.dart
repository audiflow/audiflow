import 'package:isar_community/isar.dart';

part 'synced_setting.g.dart';

/// One app setting that follows the user to other devices
/// (docs/architecture/user-data-sync.md, "Local storage").
///
/// Kept in Isar rather than SharedPreferences so a setting change and its
/// sync op can share one transaction. Which keys sync is
/// `SyncedSettingsStore.syncedKeys`.
@collection
class SyncedSetting {
  Id id = Isar.autoIncrement;

  /// The `SettingsKeys` key.
  @Index(unique: true)
  late String key;

  /// The value, JSON-encoded; meaningless while [present] is false.
  String value = 'null';

  /// False once the setting was removed (back to its default), kept so the
  /// removal can win a merge.
  bool present = true;

  /// [Hlc] of the last change, packed.
  int hlc = 0;
}
