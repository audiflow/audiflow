import 'package:isar_community/isar.dart';

part 'sync_key_alias.g.dart';

/// Another device's key for a podcast or episode this device keys
/// differently (docs/architecture/user-data-sync.md, "Stable keys").
///
/// Two devices can key one show differently (one saw its `podcast:guid`
/// first, the other only its URL), and one episode differently (which of
/// two items sharing a guid holds the plain guid depends on fetch
/// history). Keys are never recomputed, so each device keeps its own and
/// translates the other's: rows arriving under [foreignKey] are stored
/// under [localKey]. Local only; never synced.
@collection
class SyncKeyAlias {
  Id id = Isar.autoIncrement;

  /// [SyncKeyAlias.podcast] or [SyncKeyAlias.episode].
  @Index(unique: true, composite: [CompositeIndex('foreignKey')])
  late String kind;

  late String foreignKey;

  late String localKey;

  static const podcast = 'podcast';
  static const episode = 'episode';
}
