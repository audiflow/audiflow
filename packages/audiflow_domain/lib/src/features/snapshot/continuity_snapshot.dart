import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../subscription/models/subscriptions.dart';
import '../user_state/models/episode_user_state.dart';
import '../user_state/models/podcast_user_state.dart';
import '../user_state/models/queue_entry.dart';
import '../user_state/models/station_state.dart';
import 'backup_file.dart';

part 'continuity_snapshot.g.dart';

/// Name of the continuity snapshot: the copy of the user data the OS backup
/// and device transfer carry to a new phone, in place of the database
/// (docs/architecture/user-data-sync.md, "Device continuity").
const continuitySnapshotFileName = 'continuity.$backupFileExtension';

/// Resolves the absolute path of the continuity snapshot.
///
/// Injected as a function so the services stay free of `path_provider`,
/// which has no implementation in plain unit tests.
typedef ContinuitySnapshotPathResolver = Future<String> Function();

/// The snapshot lives in Application Support: backed up on iOS, and the
/// `file` domain the Android backup rules keep on Android.
@Riverpod(keepAlive: true)
ContinuitySnapshotPathResolver continuitySnapshotPath(Ref ref) =>
    () async => p.join(
      (await getApplicationSupportDirectory()).path,
      continuitySnapshotFileName,
    );

/// Whether the database holds none of the user state a snapshot carries.
///
/// Synced settings do not count: launch copies them in from preferences,
/// which the OS restores on its own.
Future<bool> hasNoUserState(Isar isar) async =>
    await isar.podcastUserStates.count() == 0 &&
    await isar.episodeUserStates.count() == 0 &&
    await isar.queueEntrys.count() == 0 &&
    await isar.stationStates.count() == 0;

/// Whether the database holds no user data at all: no user state, and no
/// subscription waiting for its first feed parse (which has no
/// `PodcastUserState` until that parse assigns its key).
Future<bool> hasNoUserData(Isar isar) async =>
    await hasNoUserState(isar) &&
    await isar.subscriptions.filter().isCachedEqualTo(false).isEmpty();
