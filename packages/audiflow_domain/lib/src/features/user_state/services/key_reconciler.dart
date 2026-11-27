import 'package:audiflow_podcast/audiflow_podcast.dart' show guidOfStorageKey;
import 'package:isar_community/isar.dart';

import '../../feed/models/episode.dart';
import '../../snapshot/snapshot_body.dart';
import '../../subscription/models/subscriptions.dart';
import '../models/episode_user_state.dart';
import '../models/outbox_op.dart';
import '../models/podcast_user_state.dart';
import '../models/queue_entry.dart';
import '../models/station_state.dart';
import '../models/stable_keys.dart';
import '../models/sync_key_alias.dart';
import '../sync/user_state_codec.dart';
import '../sync/user_state_fields.dart';

/// What [KeyReconciler.reconcile] joined.
class KeyReconcileResult {
  const KeyReconcileResult({
    this.episodeKeys = const {},
    this.podcastsJoined = false,
    this.queueChanged = false,
  });

  /// Local keys of episodes whose state took in another key's rows.
  final Set<String> episodeKeys;

  /// Whether a podcast took in another key's rows; the library and the
  /// stations then need projecting again.
  final bool podcastsJoined;

  /// Whether a queue entry now points at another episode key.
  final bool queueChanged;

  bool get isEmpty => episodeKeys.isEmpty && !podcastsJoined && !queueChanged;
}

/// Joins user state that arrived under another device's key for a podcast
/// or episode this device keys differently (design doc, "Stable keys").
///
/// Keys are never recomputed, so two devices can name one show by its
/// `podcast:guid` and by its URL, and one episode by two storage guids.
/// Each device keeps its own keys: a foreign podcast row is joined to the
/// subscription with the same feed URL or directory id, a foreign episode
/// row to the catalog episode its locator finds, the way a feed refresh
/// matches stored episodes. The joined rows merge field by field under the
/// sync rules, and a [SyncKeyAlias] sends later rows straight to the local
/// key ([translate]).
///
/// Nothing is queued to send: the other devices hold the foreign rows and
/// join them on their own.
class KeyReconciler {
  KeyReconciler(this._isar);

  final Isar _isar;

  /// [sections] with every row key this device knows under another name
  /// rewritten to it; run before merging received rows.
  ///
  /// Keys inside field values (an episode's podcastKey, a queue entry's
  /// episodeKey) are rewritten after the merge, by [reconcile].
  Future<Map<String, List<SnapshotRow>>> translate(
    Map<String, List<SnapshotRow>> sections,
  ) async {
    // A closed database crashes a query rather than throwing; the merge
    // that follows reports it.
    if (!_isar.isOpen) return sections;
    final aliases = await _isar.syncKeyAlias.where().findAll();
    if (aliases.isEmpty) return sections;
    final podcasts = {
      for (final a in aliases)
        if (a.kind == SyncKeyAlias.podcast) a.foreignKey: a.localKey,
    };
    final episodes = {
      for (final a in aliases)
        if (a.kind == SyncKeyAlias.episode) a.foreignKey: a.localKey,
    };
    String part(String key, int count, int index, Map<String, String> map) {
      final List<String?> parts;
      try {
        parts = splitCompositeKey(key, count);
      } on FormatException {
        // The merge reports a damaged key.
        return key;
      }
      final local = map[parts[index]];
      if (local == null) return key;
      parts[index] = local;
      return compositeKey(parts);
    }

    String rename(String entity, String key) => switch (entity) {
      'podcast' || 'podcastInfo' => podcasts[key] ?? key,
      'playOrder' => part(key, 3, 0, podcasts),
      'stationMember' => part(key, 2, 1, podcasts),
      'episode' => episodes[key] ?? key,
      'episodeCounter' => part(key, 2, 0, episodes),
      _ => key,
    };

    return {
      for (final MapEntry(key: entity, value: rows) in sections.entries)
        entity: [
          for (final row in rows)
            SnapshotRow(rename(entity, row.key), row.fields),
        ],
    };
  }

  /// Joins rows under foreign keys to the local ones, in one transaction.
  ///
  /// Looks at the podcasts [podcastKeys] and the podcasts of the episodes
  /// [episodeKeys]; with both null, at every podcast.
  Future<KeyReconcileResult> reconcile({
    Set<String>? podcastKeys,
    Set<String>? episodeKeys,
  }) async {
    Future<_Run> go(_Run run) async {
      await run.applyAliases();
      final everything = podcastKeys == null && episodeKeys == null;
      final keys = everything
          ? null
          : {
              ...?podcastKeys,
              ...await run.podcastKeysOf(episodeKeys ?? const {}),
            };
      await run.joinPodcasts(keys);
      await run.joinEpisodes(keys);
      return run;
    }

    // Work that outlives its caller (after a restore) may find the
    // database closed; a query would crash rather than throw.
    if (!_isar.isOpen) return const KeyReconcileResult();
    // Looked for under a read lock first: this runs after every received
    // frame, and almost always finds nothing.
    final dry = await _isar.txn(() async {
      final run = _Run(_isar, dry: true);
      try {
        await go(run);
      } on _Found {
        // needsWrite is set.
      }
      return run;
    });
    if (!dry.needsWrite) return const KeyReconcileResult();
    final run = await _isar.writeTxn(() => go(_Run(_isar)));
    return run.result;
  }
}

/// Stops a dry run at the first change it would make.
class _Found implements Exception {
  const _Found();
}

class _Run {
  _Run(this._isar, {this.dry = false});

  final Isar _isar;

  /// Only finds whether anything would change; writes nothing.
  final bool dry;
  var needsWrite = false;

  /// In a dry run, records that a write is due and stops the run.
  void _write() {
    if (!dry) return;
    needsWrite = true;
    throw const _Found();
  }

  final _episodeKeys = <String>{};
  final _joinedPodcastKeys = <String>{};
  var _queueChanged = false;

  KeyReconcileResult get result => KeyReconcileResult(
    episodeKeys: _episodeKeys,
    podcastsJoined: _joinedPodcastKeys.isNotEmpty,
    queueChanged: _queueChanged,
  );

  Future<Set<String>> podcastKeysOf(Set<String> episodeKeys) async {
    if (episodeKeys.isEmpty) return {};
    final states = await _isar.episodeUserStates.getAllByEpisodeKey(
      episodeKeys.toList(),
    );
    return {for (final s in states) ?s?.podcastKey};
  }

  /// Rewrites foreign keys that arrived inside field values: the podcast
  /// of a new episode row, the episode of a new queue entry.
  Future<void> applyAliases() async {
    final aliases = await _isar.syncKeyAlias.where().findAll();
    for (final alias in aliases) {
      if (alias.kind == SyncKeyAlias.podcast) {
        await _movePodcastOfEpisodes(alias.foreignKey, alias.localKey);
      } else {
        await _moveQueueEntries(alias.foreignKey, alias.localKey);
      }
    }
  }

  // -- Podcasts --

  Future<void> joinPodcasts(Set<String>? keys) async {
    final states = keys == null
        ? await _isar.podcastUserStates.where().findAll()
        : [
            for (final s in await _isar.podcastUserStates.getAllByPodcastKey(
              keys.toList(),
            ))
              ?s,
          ];
    List<Subscription>? subs;
    for (final state in states) {
      final hasOwn = await _isar.subscriptions
          .filter()
          .podcastKeyEqualTo(state.podcastKey)
          .isNotEmpty();
      if (hasOwn) continue;
      subs ??= await _isar.subscriptions
          .filter()
          .podcastKeyIsNotNull()
          .findAll();
      final local = _samePodcast(subs, state);
      if (local == null) continue;
      await _joinPodcast(state, local);
    }
  }

  /// The keyed subscription that is [state]'s show under another key: the
  /// same feed, or the same directory id.
  static String? _samePodcast(List<Subscription> subs, PodcastUserState state) {
    final feedUrl = state.feedUrl;
    if (feedUrl != null) {
      final normalized = normalizeFeedUrlForKey(feedUrl);
      for (final sub in subs) {
        if (normalizeFeedUrlForKey(sub.feedUrl) == normalized) {
          return sub.podcastKey;
        }
      }
    }
    final itunesId = state.itunesId;
    if (itunesId == null) return null;
    for (final sub in subs) {
      if (sub.itunesId == itunesId) return sub.podcastKey;
    }
    return null;
  }

  Future<void> _joinPodcast(PodcastUserState from, String toKey) async {
    _write();
    final fromKey = from.podcastKey;
    await _alias(SyncKeyAlias.podcast, fromKey, toKey);
    final into = await _isar.podcastUserStates.getByPodcastKey(toKey);
    if (into == null) {
      await _isar.podcastUserStates.put(from..podcastKey = toKey);
    } else {
      await _isar.podcastUserStates.delete(from.id);
      _fold(UserStateEntities.podcast, from, into);
      into.playOrders = _foldPlayOrders(from.playOrders, into.playOrders);
      await _isar.podcastUserStates.put(into);
    }
    await _moveOpaque(UserStateEntities.podcast.name, fromKey, toKey);
    await _moveMembers(fromKey, toKey);
    await _movePodcastOfEpisodes(fromKey, toKey);
    _joinedPodcastKeys.add(toKey);
  }

  Future<void> _moveMembers(String fromKey, String toKey) async {
    final members = await _isar.stationMembers
        .filter()
        .podcastKeyEqualTo(fromKey)
        .findAll();
    for (final member in members) {
      final into = await _isar.stationMembers.getByStationIdPodcastKey(
        member.stationId,
        toKey,
      );
      if (into == null) {
        await _isar.stationMembers.put(member..podcastKey = toKey);
      } else {
        await _isar.stationMembers.delete(member.id);
        _fold(UserStateEntities.stationMember, member, into);
        await _isar.stationMembers.put(into);
      }
    }
  }

  Future<void> _movePodcastOfEpisodes(String fromKey, String toKey) async {
    final states = await _isar.episodeUserStates
        .where()
        .podcastKeyEqualTo(fromKey)
        .findAll();
    if (states.isEmpty) return;
    _write();
    for (final state in states) {
      state.podcastKey = toKey;
    }
    await _isar.episodeUserStates.putAll(states);
    // Their episode keys still come from the other key; the locator joins
    // them below.
    _joinedPodcastKeys.add(toKey);
  }

  // -- Episodes --

  Future<void> joinEpisodes(Set<String>? podcastKeys) async {
    final all = podcastKeys == null
        ? await _isar.subscriptions
              .filter()
              .podcastKeyIsNotNull()
              .podcastKeyProperty()
              .findAll()
        : const <String?>[];
    final keys = {
      ...?podcastKeys,
      ..._joinedPodcastKeys,
      ...all.whereType<String>(),
    };
    for (final podcastKey in keys) {
      await _joinEpisodesOf(podcastKey);
    }
  }

  Future<void> _joinEpisodesOf(String podcastKey) async {
    final states = await _isar.episodeUserStates
        .where()
        .podcastKeyEqualTo(podcastKey)
        .findAll();
    if (states.isEmpty) return;
    final known = {
      for (final e
          in await _isar.episodes
              .where()
              .anyOf(states, (q, s) => q.episodeKeyEqualTo(s.episodeKey))
              .findAll())
        ?e.episodeKey,
    };
    final unknown = [
      for (final s in states)
        if (!known.contains(s.episodeKey) && _hasLocator(s)) s,
    ];
    if (unknown.isEmpty) return;
    final podcastIds = await _isar.subscriptions
        .filter()
        .podcastKeyEqualTo(podcastKey)
        .idProperty()
        .findAll();
    if (podcastIds.isEmpty) return;
    final episodes = await _isar.episodes
        .filter()
        .anyOf(podcastIds, (q, id) => q.podcastIdEqualTo(id))
        .episodeKeyIsNotNull()
        .findAll();
    for (final state in unknown) {
      final match = locateEpisode(episodes, state);
      final toKey = match?.episodeKey;
      if (toKey == null || toKey == state.episodeKey) continue;
      await _joinEpisode(state, toKey);
    }
  }

  static bool _hasLocator(EpisodeUserState s) =>
      s.locatorAudioUrl != null || s.locatorGuid != null;

  Future<void> _joinEpisode(EpisodeUserState from, String toKey) async {
    _write();
    final fromKey = from.episodeKey;
    await _alias(SyncKeyAlias.episode, fromKey, toKey);
    final into = await _isar.episodeUserStates.getByEpisodeKey(toKey);
    if (into == null) {
      await _isar.episodeUserStates.put(from..episodeKey = toKey);
    } else {
      await _isar.episodeUserStates.delete(from.id);
      _fold(UserStateEntities.episode, from, into);
      into.counters = _foldCounters(from.counters, into.counters);
      await _isar.episodeUserStates.put(into);
    }
    await _moveOpaque(UserStateEntities.episode.name, fromKey, toKey);
    await _moveQueueEntries(fromKey, toKey);
    _episodeKeys.add(toKey);
  }

  Future<void> _moveQueueEntries(String fromKey, String toKey) async {
    final entries = await _isar.queueEntrys
        .where()
        .episodeKeyEqualTo(fromKey)
        .findAll();
    if (entries.isEmpty) return;
    _write();
    for (final entry in entries) {
      entry.episodeKey = toKey;
    }
    await _isar.queueEntrys.putAll(entries);
    _queueChanged = true;
  }

  // -- Shared --

  /// Records that [fromKey] means [toKey] here, also for aliases that
  /// pointed at [fromKey].
  Future<void> _alias(String kind, String fromKey, String toKey) async {
    final pointing = await _isar.syncKeyAlias
        .filter()
        .kindEqualTo(kind)
        .localKeyEqualTo(fromKey)
        .findAll();
    for (final alias in pointing) {
      alias.localKey = toKey;
    }
    await _isar.syncKeyAlias.putAll(pointing);
    final existing = await _isar.syncKeyAlias.getByKindForeignKey(
      kind,
      fromKey,
    );
    await _isar.syncKeyAlias.put(
      (existing ?? SyncKeyAlias())
        ..kind = kind
        ..foreignKey = fromKey
        ..localKey = toKey,
    );
  }

  /// Moves fields a newer app stored for [fromKey] to [toKey], unless the
  /// local row already has its own.
  Future<void> _moveOpaque(String entity, String fromKey, String toKey) async {
    final fields = await _isar.opaqueFields
        .filter()
        .entityEqualTo(entity)
        .keyEqualTo(fromKey)
        .findAll();
    for (final field in fields) {
      await _isar.opaqueFields.delete(field.id);
      final taken = await _isar.opaqueFields.getByEntityKeyFieldId(
        entity,
        toKey,
        field.fieldId,
      );
      if (taken != null && field.hlc <= taken.hlc) continue;
      await _isar.opaqueFields.put(
        field
          ..id = taken?.id ?? Isar.autoIncrement
          ..key = toKey,
      );
    }
  }

  /// Merges [from] into [into] under the sync rules: the newer clock wins
  /// per field, counters take the maximum, set-once fields are filled in.
  static void _fold<T>(EntitySpec<T> spec, T from, T into) {
    // Fields sharing one clock each decide against it as it was.
    final before = {
      for (final f in spec.fields)
        if (f.hlc != null) f.id: f.hlc!(into),
    };
    for (final field in spec.fields) {
      final value = field.value(from);
      final current = field.value(into);
      if (field.growOnly) {
        if ((current! as int) < (value! as int)) field.set(into, value);
        continue;
      }
      final hlc = field.hlc?.call(from);
      if (hlc == null) {
        if (current == null && value != null) field.set(into, value);
        continue;
      }
      if (!_newer(hlc, value, before[field.id]!, current)) continue;
      field.set(into, value);
      field.setHlc!(into, hlc);
    }
  }

  /// The merge's rule: a newer clock wins; equal clocks pick the larger
  /// encoded value, so every device settles on the same one.
  static bool _newer(int hlc, Object? value, int localHlc, Object? local) {
    if (hlc != localHlc) return localHlc < hlc;
    return sortsAbove(encodeValue(value), encodeValue(local));
  }

  static List<EpisodePlayCounters> _foldCounters(
    List<EpisodePlayCounters> from,
    List<EpisodePlayCounters> into,
  ) {
    final result = [...into];
    for (final counters in from) {
      final i = result.indexWhere((c) => c.deviceId == counters.deviceId);
      if (i < 0) {
        result.add(counters);
        continue;
      }
      final row = (episodeKey: '', counters: result[i]);
      _fold(UserStateEntities.episodeCounter, (
        episodeKey: '',
        counters: counters,
      ), row);
    }
    return result;
  }

  static List<PlayOrderEntry> _foldPlayOrders(
    List<PlayOrderEntry> from,
    List<PlayOrderEntry> into,
  ) {
    final result = [...into];
    for (final entry in from) {
      final i = result.indexWhere(
        (e) => e.playlistId == entry.playlistId && e.groupId == entry.groupId,
      );
      if (i < 0) {
        result.add(entry);
        continue;
      }
      _fold(
        UserStateEntities.playOrder,
        (podcastKey: '', entry: entry),
        (podcastKey: '', entry: result[i]),
      );
    }
    return result;
  }
}

/// The catalog episode in [episodes] that [state]'s locator names, found
/// the way a feed refresh matches stored rows: the same enclosure URL
/// first; then, among items with the same guid, the same publish date;
/// then, when a date is missing, the same storage guid before any other.
Episode? locateEpisode(Iterable<Episode> episodes, EpisodeUserState state) {
  final audioUrl = state.locatorAudioUrl;
  if (audioUrl != null) {
    final byAudio = episodes.where((e) => e.audioUrl == audioUrl).firstOrNull;
    if (byAudio != null) return byAudio;
  }
  final storageGuid = state.locatorGuid;
  if (storageGuid == null) return null;
  final guid = guidOfStorageKey(storageGuid);
  final sameGuid = episodes
      .where((e) => guidOfStorageKey(e.guid) == guid)
      .toList();
  final date = state.locatorPublishedAt;
  if (date != null) {
    // Isar reads dates back in local time; compare the instant.
    final dated = sameGuid
        .where((e) => e.publishedAt?.isAtSameMomentAs(date) ?? false)
        .firstOrNull;
    if (dated != null) return dated;
  }
  final undated = sameGuid.where((e) => e.publishedAt == null || date == null);
  return undated.where((e) => e.guid == storageGuid).firstOrNull ??
      undated.firstOrNull;
}
