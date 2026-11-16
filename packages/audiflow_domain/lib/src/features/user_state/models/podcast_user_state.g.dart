// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_user_state.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetPodcastUserStateCollection on Isar {
  IsarCollection<PodcastUserState> get podcastUserStates => this.collection();
}

const PodcastUserStateSchema = CollectionSchema(
  name: r'PodcastUserState',
  id: -8538216616646919909,
  properties: {
    r'autoPlayOrder': PropertySchema(
      id: 0,
      name: r'autoPlayOrder',
      type: IsarType.string,
    ),
    r'autoPlayOrderHlc': PropertySchema(
      id: 1,
      name: r'autoPlayOrderHlc',
      type: IsarType.long,
    ),
    r'episodeFilter': PropertySchema(
      id: 2,
      name: r'episodeFilter',
      type: IsarType.string,
    ),
    r'episodeFilterHlc': PropertySchema(
      id: 3,
      name: r'episodeFilterHlc',
      type: IsarType.long,
    ),
    r'episodeSortOrder': PropertySchema(
      id: 4,
      name: r'episodeSortOrder',
      type: IsarType.string,
    ),
    r'episodeSortOrderHlc': PropertySchema(
      id: 5,
      name: r'episodeSortOrderHlc',
      type: IsarType.long,
    ),
    r'hasAudio': PropertySchema(id: 6, name: r'hasAudio', type: IsarType.bool),
    r'hasAudioHlc': PropertySchema(
      id: 7,
      name: r'hasAudioHlc',
      type: IsarType.long,
    ),
    r'hasParental': PropertySchema(
      id: 8,
      name: r'hasParental',
      type: IsarType.bool,
    ),
    r'hasParentalHlc': PropertySchema(
      id: 9,
      name: r'hasParentalHlc',
      type: IsarType.long,
    ),
    r'hasView': PropertySchema(id: 10, name: r'hasView', type: IsarType.bool),
    r'hasViewHlc': PropertySchema(
      id: 11,
      name: r'hasViewHlc',
      type: IsarType.long,
    ),
    r'hideExplicitEpisodes': PropertySchema(
      id: 12,
      name: r'hideExplicitEpisodes',
      type: IsarType.bool,
    ),
    r'hideExplicitEpisodesHlc': PropertySchema(
      id: 13,
      name: r'hideExplicitEpisodesHlc',
      type: IsarType.long,
    ),
    r'playOrders': PropertySchema(
      id: 14,
      name: r'playOrders',
      type: IsarType.objectList,

      target: r'PlayOrderEntry',
    ),
    r'podcastKey': PropertySchema(
      id: 15,
      name: r'podcastKey',
      type: IsarType.string,
    ),
    r'seasonSortField': PropertySchema(
      id: 16,
      name: r'seasonSortField',
      type: IsarType.string,
    ),
    r'seasonSortFieldHlc': PropertySchema(
      id: 17,
      name: r'seasonSortFieldHlc',
      type: IsarType.long,
    ),
    r'seasonSortOrder': PropertySchema(
      id: 18,
      name: r'seasonSortOrder',
      type: IsarType.string,
    ),
    r'seasonSortOrderHlc': PropertySchema(
      id: 19,
      name: r'seasonSortOrderHlc',
      type: IsarType.long,
    ),
    r'selectedPlaylistId': PropertySchema(
      id: 20,
      name: r'selectedPlaylistId',
      type: IsarType.string,
    ),
    r'selectedPlaylistIdHlc': PropertySchema(
      id: 21,
      name: r'selectedPlaylistIdHlc',
      type: IsarType.long,
    ),
    r'skipSilence': PropertySchema(
      id: 22,
      name: r'skipSilence',
      type: IsarType.bool,
    ),
    r'skipSilenceHlc': PropertySchema(
      id: 23,
      name: r'skipSilenceHlc',
      type: IsarType.long,
    ),
    r'speed': PropertySchema(id: 24, name: r'speed', type: IsarType.double),
    r'speedHlc': PropertySchema(id: 25, name: r'speedHlc', type: IsarType.long),
    r'viewMode': PropertySchema(
      id: 26,
      name: r'viewMode',
      type: IsarType.string,
    ),
    r'viewModeHlc': PropertySchema(
      id: 27,
      name: r'viewModeHlc',
      type: IsarType.long,
    ),
    r'voiceBoost': PropertySchema(
      id: 28,
      name: r'voiceBoost',
      type: IsarType.bool,
    ),
    r'voiceBoostHlc': PropertySchema(
      id: 29,
      name: r'voiceBoostHlc',
      type: IsarType.long,
    ),
  },

  estimateSize: _podcastUserStateEstimateSize,
  serialize: _podcastUserStateSerialize,
  deserialize: _podcastUserStateDeserialize,
  deserializeProp: _podcastUserStateDeserializeProp,
  idName: r'id',
  indexes: {
    r'podcastKey': IndexSchema(
      id: -7454521677690852339,
      name: r'podcastKey',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'podcastKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {r'PlayOrderEntry': PlayOrderEntrySchema},

  getId: _podcastUserStateGetId,
  getLinks: _podcastUserStateGetLinks,
  attach: _podcastUserStateAttach,
  version: '3.3.2',
);

int _podcastUserStateEstimateSize(
  PodcastUserState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.autoPlayOrder;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.episodeFilter.length * 3;
  bytesCount += 3 + object.episodeSortOrder.length * 3;
  bytesCount += 3 + object.playOrders.length * 3;
  {
    final offsets = allOffsets[PlayOrderEntry]!;
    for (var i = 0; i < object.playOrders.length; i++) {
      final value = object.playOrders[i];
      bytesCount += PlayOrderEntrySchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  bytesCount += 3 + object.podcastKey.length * 3;
  bytesCount += 3 + object.seasonSortField.length * 3;
  bytesCount += 3 + object.seasonSortOrder.length * 3;
  {
    final value = object.selectedPlaylistId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.viewMode.length * 3;
  return bytesCount;
}

void _podcastUserStateSerialize(
  PodcastUserState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.autoPlayOrder);
  writer.writeLong(offsets[1], object.autoPlayOrderHlc);
  writer.writeString(offsets[2], object.episodeFilter);
  writer.writeLong(offsets[3], object.episodeFilterHlc);
  writer.writeString(offsets[4], object.episodeSortOrder);
  writer.writeLong(offsets[5], object.episodeSortOrderHlc);
  writer.writeBool(offsets[6], object.hasAudio);
  writer.writeLong(offsets[7], object.hasAudioHlc);
  writer.writeBool(offsets[8], object.hasParental);
  writer.writeLong(offsets[9], object.hasParentalHlc);
  writer.writeBool(offsets[10], object.hasView);
  writer.writeLong(offsets[11], object.hasViewHlc);
  writer.writeBool(offsets[12], object.hideExplicitEpisodes);
  writer.writeLong(offsets[13], object.hideExplicitEpisodesHlc);
  writer.writeObjectList<PlayOrderEntry>(
    offsets[14],
    allOffsets,
    PlayOrderEntrySchema.serialize,
    object.playOrders,
  );
  writer.writeString(offsets[15], object.podcastKey);
  writer.writeString(offsets[16], object.seasonSortField);
  writer.writeLong(offsets[17], object.seasonSortFieldHlc);
  writer.writeString(offsets[18], object.seasonSortOrder);
  writer.writeLong(offsets[19], object.seasonSortOrderHlc);
  writer.writeString(offsets[20], object.selectedPlaylistId);
  writer.writeLong(offsets[21], object.selectedPlaylistIdHlc);
  writer.writeBool(offsets[22], object.skipSilence);
  writer.writeLong(offsets[23], object.skipSilenceHlc);
  writer.writeDouble(offsets[24], object.speed);
  writer.writeLong(offsets[25], object.speedHlc);
  writer.writeString(offsets[26], object.viewMode);
  writer.writeLong(offsets[27], object.viewModeHlc);
  writer.writeBool(offsets[28], object.voiceBoost);
  writer.writeLong(offsets[29], object.voiceBoostHlc);
}

PodcastUserState _podcastUserStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PodcastUserState();
  object.autoPlayOrder = reader.readStringOrNull(offsets[0]);
  object.autoPlayOrderHlc = reader.readLong(offsets[1]);
  object.episodeFilter = reader.readString(offsets[2]);
  object.episodeFilterHlc = reader.readLong(offsets[3]);
  object.episodeSortOrder = reader.readString(offsets[4]);
  object.episodeSortOrderHlc = reader.readLong(offsets[5]);
  object.hasAudio = reader.readBool(offsets[6]);
  object.hasAudioHlc = reader.readLong(offsets[7]);
  object.hasParental = reader.readBool(offsets[8]);
  object.hasParentalHlc = reader.readLong(offsets[9]);
  object.hasView = reader.readBool(offsets[10]);
  object.hasViewHlc = reader.readLong(offsets[11]);
  object.hideExplicitEpisodes = reader.readBool(offsets[12]);
  object.hideExplicitEpisodesHlc = reader.readLong(offsets[13]);
  object.id = id;
  object.playOrders =
      reader.readObjectList<PlayOrderEntry>(
        offsets[14],
        PlayOrderEntrySchema.deserialize,
        allOffsets,
        PlayOrderEntry(),
      ) ??
      [];
  object.podcastKey = reader.readString(offsets[15]);
  object.seasonSortField = reader.readString(offsets[16]);
  object.seasonSortFieldHlc = reader.readLong(offsets[17]);
  object.seasonSortOrder = reader.readString(offsets[18]);
  object.seasonSortOrderHlc = reader.readLong(offsets[19]);
  object.selectedPlaylistId = reader.readStringOrNull(offsets[20]);
  object.selectedPlaylistIdHlc = reader.readLong(offsets[21]);
  object.skipSilence = reader.readBoolOrNull(offsets[22]);
  object.skipSilenceHlc = reader.readLong(offsets[23]);
  object.speed = reader.readDouble(offsets[24]);
  object.speedHlc = reader.readLong(offsets[25]);
  object.viewMode = reader.readString(offsets[26]);
  object.viewModeHlc = reader.readLong(offsets[27]);
  object.voiceBoost = reader.readBoolOrNull(offsets[28]);
  object.voiceBoostHlc = reader.readLong(offsets[29]);
  return object;
}

P _podcastUserStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readObjectList<PlayOrderEntry>(
                offset,
                PlayOrderEntrySchema.deserialize,
                allOffsets,
                PlayOrderEntry(),
              ) ??
              [])
          as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readLong(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (reader.readLong(offset)) as P;
    case 22:
      return (reader.readBoolOrNull(offset)) as P;
    case 23:
      return (reader.readLong(offset)) as P;
    case 24:
      return (reader.readDouble(offset)) as P;
    case 25:
      return (reader.readLong(offset)) as P;
    case 26:
      return (reader.readString(offset)) as P;
    case 27:
      return (reader.readLong(offset)) as P;
    case 28:
      return (reader.readBoolOrNull(offset)) as P;
    case 29:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _podcastUserStateGetId(PodcastUserState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _podcastUserStateGetLinks(PodcastUserState object) {
  return [];
}

void _podcastUserStateAttach(
  IsarCollection<dynamic> col,
  Id id,
  PodcastUserState object,
) {
  object.id = id;
}

extension PodcastUserStateByIndex on IsarCollection<PodcastUserState> {
  Future<PodcastUserState?> getByPodcastKey(String podcastKey) {
    return getByIndex(r'podcastKey', [podcastKey]);
  }

  PodcastUserState? getByPodcastKeySync(String podcastKey) {
    return getByIndexSync(r'podcastKey', [podcastKey]);
  }

  Future<bool> deleteByPodcastKey(String podcastKey) {
    return deleteByIndex(r'podcastKey', [podcastKey]);
  }

  bool deleteByPodcastKeySync(String podcastKey) {
    return deleteByIndexSync(r'podcastKey', [podcastKey]);
  }

  Future<List<PodcastUserState?>> getAllByPodcastKey(
    List<String> podcastKeyValues,
  ) {
    final values = podcastKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'podcastKey', values);
  }

  List<PodcastUserState?> getAllByPodcastKeySync(
    List<String> podcastKeyValues,
  ) {
    final values = podcastKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'podcastKey', values);
  }

  Future<int> deleteAllByPodcastKey(List<String> podcastKeyValues) {
    final values = podcastKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'podcastKey', values);
  }

  int deleteAllByPodcastKeySync(List<String> podcastKeyValues) {
    final values = podcastKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'podcastKey', values);
  }

  Future<Id> putByPodcastKey(PodcastUserState object) {
    return putByIndex(r'podcastKey', object);
  }

  Id putByPodcastKeySync(PodcastUserState object, {bool saveLinks = true}) {
    return putByIndexSync(r'podcastKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPodcastKey(List<PodcastUserState> objects) {
    return putAllByIndex(r'podcastKey', objects);
  }

  List<Id> putAllByPodcastKeySync(
    List<PodcastUserState> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'podcastKey', objects, saveLinks: saveLinks);
  }
}

extension PodcastUserStateQueryWhereSort
    on QueryBuilder<PodcastUserState, PodcastUserState, QWhere> {
  QueryBuilder<PodcastUserState, PodcastUserState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PodcastUserStateQueryWhere
    on QueryBuilder<PodcastUserState, PodcastUserState, QWhereClause> {
  QueryBuilder<PodcastUserState, PodcastUserState, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterWhereClause>
  podcastKeyEqualTo(String podcastKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'podcastKey', value: [podcastKey]),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterWhereClause>
  podcastKeyNotEqualTo(String podcastKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastKey',
                lower: [],
                upper: [podcastKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastKey',
                lower: [podcastKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastKey',
                lower: [podcastKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastKey',
                lower: [],
                upper: [podcastKey],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension PodcastUserStateQueryFilter
    on QueryBuilder<PodcastUserState, PodcastUserState, QFilterCondition> {
  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  autoPlayOrderIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'autoPlayOrder'),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  autoPlayOrderIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'autoPlayOrder'),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  autoPlayOrderEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'autoPlayOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  autoPlayOrderGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'autoPlayOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  autoPlayOrderLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'autoPlayOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  autoPlayOrderBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'autoPlayOrder',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  autoPlayOrderStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'autoPlayOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  autoPlayOrderEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'autoPlayOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  autoPlayOrderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'autoPlayOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  autoPlayOrderMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'autoPlayOrder',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  autoPlayOrderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'autoPlayOrder', value: ''),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  autoPlayOrderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'autoPlayOrder', value: ''),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  autoPlayOrderHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'autoPlayOrderHlc', value: value),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  autoPlayOrderHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'autoPlayOrderHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  autoPlayOrderHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'autoPlayOrderHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  autoPlayOrderHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'autoPlayOrderHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeFilterEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'episodeFilter',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeFilterGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'episodeFilter',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeFilterLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'episodeFilter',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeFilterBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'episodeFilter',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeFilterStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'episodeFilter',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeFilterEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'episodeFilter',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeFilterContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'episodeFilter',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeFilterMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'episodeFilter',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeFilterIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeFilter', value: ''),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeFilterIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'episodeFilter', value: ''),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeFilterHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeFilterHlc', value: value),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeFilterHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'episodeFilterHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeFilterHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'episodeFilterHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeFilterHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'episodeFilterHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeSortOrderEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'episodeSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeSortOrderGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'episodeSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeSortOrderLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'episodeSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeSortOrderBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'episodeSortOrder',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeSortOrderStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'episodeSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeSortOrderEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'episodeSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeSortOrderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'episodeSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeSortOrderMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'episodeSortOrder',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeSortOrderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeSortOrder', value: ''),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeSortOrderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'episodeSortOrder', value: ''),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeSortOrderHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeSortOrderHlc', value: value),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeSortOrderHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'episodeSortOrderHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeSortOrderHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'episodeSortOrderHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  episodeSortOrderHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'episodeSortOrderHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  hasAudioEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hasAudio', value: value),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  hasAudioHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hasAudioHlc', value: value),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  hasAudioHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hasAudioHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  hasAudioHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hasAudioHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  hasAudioHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hasAudioHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  hasParentalEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hasParental', value: value),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  hasParentalHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hasParentalHlc', value: value),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  hasParentalHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hasParentalHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  hasParentalHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hasParentalHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  hasParentalHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hasParentalHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  hasViewEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hasView', value: value),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  hasViewHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hasViewHlc', value: value),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  hasViewHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hasViewHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  hasViewHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hasViewHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  hasViewHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hasViewHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  hideExplicitEpisodesEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'hideExplicitEpisodes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  hideExplicitEpisodesHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'hideExplicitEpisodesHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  hideExplicitEpisodesHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hideExplicitEpisodesHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  hideExplicitEpisodesHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hideExplicitEpisodesHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  hideExplicitEpisodesHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hideExplicitEpisodesHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  playOrdersLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'playOrders', length, true, length, true);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  playOrdersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'playOrders', 0, true, 0, true);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  playOrdersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'playOrders', 0, false, 999999, true);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  playOrdersLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'playOrders', 0, true, length, include);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  playOrdersLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'playOrders', length, include, 999999, true);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  playOrdersLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'playOrders',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  podcastKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'podcastKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  podcastKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'podcastKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  podcastKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'podcastKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  podcastKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'podcastKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  podcastKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'podcastKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  podcastKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'podcastKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  podcastKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'podcastKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  podcastKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'podcastKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  podcastKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'podcastKey', value: ''),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  podcastKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'podcastKey', value: ''),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortFieldEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'seasonSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortFieldGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'seasonSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortFieldLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'seasonSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortFieldBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'seasonSortField',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortFieldStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'seasonSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortFieldEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'seasonSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortFieldContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'seasonSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortFieldMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'seasonSortField',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortFieldIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'seasonSortField', value: ''),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortFieldIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'seasonSortField', value: ''),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortFieldHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'seasonSortFieldHlc', value: value),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortFieldHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'seasonSortFieldHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortFieldHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'seasonSortFieldHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortFieldHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'seasonSortFieldHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortOrderEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'seasonSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortOrderGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'seasonSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortOrderLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'seasonSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortOrderBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'seasonSortOrder',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortOrderStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'seasonSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortOrderEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'seasonSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortOrderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'seasonSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortOrderMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'seasonSortOrder',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortOrderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'seasonSortOrder', value: ''),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortOrderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'seasonSortOrder', value: ''),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortOrderHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'seasonSortOrderHlc', value: value),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortOrderHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'seasonSortOrderHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortOrderHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'seasonSortOrderHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  seasonSortOrderHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'seasonSortOrderHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  selectedPlaylistIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'selectedPlaylistId'),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  selectedPlaylistIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'selectedPlaylistId'),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  selectedPlaylistIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'selectedPlaylistId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  selectedPlaylistIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'selectedPlaylistId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  selectedPlaylistIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'selectedPlaylistId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  selectedPlaylistIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'selectedPlaylistId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  selectedPlaylistIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'selectedPlaylistId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  selectedPlaylistIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'selectedPlaylistId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  selectedPlaylistIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'selectedPlaylistId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  selectedPlaylistIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'selectedPlaylistId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  selectedPlaylistIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'selectedPlaylistId', value: ''),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  selectedPlaylistIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'selectedPlaylistId', value: ''),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  selectedPlaylistIdHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'selectedPlaylistIdHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  selectedPlaylistIdHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'selectedPlaylistIdHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  selectedPlaylistIdHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'selectedPlaylistIdHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  selectedPlaylistIdHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'selectedPlaylistIdHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  skipSilenceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'skipSilence'),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  skipSilenceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'skipSilence'),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  skipSilenceEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'skipSilence', value: value),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  skipSilenceHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'skipSilenceHlc', value: value),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  skipSilenceHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'skipSilenceHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  skipSilenceHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'skipSilenceHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  skipSilenceHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'skipSilenceHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  speedEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'speed',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  speedGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'speed',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  speedLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'speed',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  speedBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'speed',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  speedHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'speedHlc', value: value),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  speedHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'speedHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  speedHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'speedHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  speedHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'speedHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  viewModeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'viewMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  viewModeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'viewMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  viewModeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'viewMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  viewModeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'viewMode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  viewModeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'viewMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  viewModeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'viewMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  viewModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'viewMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  viewModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'viewMode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  viewModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'viewMode', value: ''),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  viewModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'viewMode', value: ''),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  viewModeHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'viewModeHlc', value: value),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  viewModeHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'viewModeHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  viewModeHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'viewModeHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  viewModeHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'viewModeHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  voiceBoostIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'voiceBoost'),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  voiceBoostIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'voiceBoost'),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  voiceBoostEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'voiceBoost', value: value),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  voiceBoostHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'voiceBoostHlc', value: value),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  voiceBoostHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'voiceBoostHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  voiceBoostHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'voiceBoostHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  voiceBoostHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'voiceBoostHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension PodcastUserStateQueryObject
    on QueryBuilder<PodcastUserState, PodcastUserState, QFilterCondition> {
  QueryBuilder<PodcastUserState, PodcastUserState, QAfterFilterCondition>
  playOrdersElement(FilterQuery<PlayOrderEntry> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'playOrders');
    });
  }
}

extension PodcastUserStateQueryLinks
    on QueryBuilder<PodcastUserState, PodcastUserState, QFilterCondition> {}

extension PodcastUserStateQuerySortBy
    on QueryBuilder<PodcastUserState, PodcastUserState, QSortBy> {
  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByAutoPlayOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoPlayOrder', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByAutoPlayOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoPlayOrder', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByAutoPlayOrderHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoPlayOrderHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByAutoPlayOrderHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoPlayOrderHlc', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByEpisodeFilter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeFilter', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByEpisodeFilterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeFilter', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByEpisodeFilterHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeFilterHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByEpisodeFilterHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeFilterHlc', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByEpisodeSortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortOrder', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByEpisodeSortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortOrder', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByEpisodeSortOrderHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortOrderHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByEpisodeSortOrderHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortOrderHlc', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByHasAudio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasAudio', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByHasAudioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasAudio', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByHasAudioHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasAudioHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByHasAudioHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasAudioHlc', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByHasParental() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasParental', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByHasParentalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasParental', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByHasParentalHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasParentalHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByHasParentalHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasParentalHlc', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByHasView() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasView', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByHasViewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasView', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByHasViewHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasViewHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByHasViewHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasViewHlc', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByHideExplicitEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideExplicitEpisodes', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByHideExplicitEpisodesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideExplicitEpisodes', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByHideExplicitEpisodesHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideExplicitEpisodesHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByHideExplicitEpisodesHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideExplicitEpisodesHlc', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByPodcastKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastKey', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByPodcastKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastKey', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortBySeasonSortField() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonSortField', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortBySeasonSortFieldDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonSortField', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortBySeasonSortFieldHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonSortFieldHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortBySeasonSortFieldHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonSortFieldHlc', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortBySeasonSortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonSortOrder', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortBySeasonSortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonSortOrder', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortBySeasonSortOrderHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonSortOrderHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortBySeasonSortOrderHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonSortOrderHlc', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortBySelectedPlaylistId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedPlaylistId', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortBySelectedPlaylistIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedPlaylistId', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortBySelectedPlaylistIdHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedPlaylistIdHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortBySelectedPlaylistIdHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedPlaylistIdHlc', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortBySkipSilence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipSilence', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortBySkipSilenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipSilence', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortBySkipSilenceHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipSilenceHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortBySkipSilenceHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipSilenceHlc', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy> sortBySpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortBySpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortBySpeedHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortBySpeedHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedHlc', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByViewMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByViewModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByViewModeHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewModeHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByViewModeHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewModeHlc', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByVoiceBoost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceBoost', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByVoiceBoostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceBoost', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByVoiceBoostHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceBoostHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  sortByVoiceBoostHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceBoostHlc', Sort.desc);
    });
  }
}

extension PodcastUserStateQuerySortThenBy
    on QueryBuilder<PodcastUserState, PodcastUserState, QSortThenBy> {
  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByAutoPlayOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoPlayOrder', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByAutoPlayOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoPlayOrder', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByAutoPlayOrderHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoPlayOrderHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByAutoPlayOrderHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoPlayOrderHlc', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByEpisodeFilter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeFilter', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByEpisodeFilterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeFilter', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByEpisodeFilterHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeFilterHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByEpisodeFilterHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeFilterHlc', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByEpisodeSortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortOrder', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByEpisodeSortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortOrder', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByEpisodeSortOrderHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortOrderHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByEpisodeSortOrderHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortOrderHlc', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByHasAudio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasAudio', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByHasAudioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasAudio', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByHasAudioHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasAudioHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByHasAudioHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasAudioHlc', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByHasParental() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasParental', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByHasParentalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasParental', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByHasParentalHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasParentalHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByHasParentalHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasParentalHlc', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByHasView() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasView', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByHasViewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasView', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByHasViewHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasViewHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByHasViewHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasViewHlc', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByHideExplicitEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideExplicitEpisodes', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByHideExplicitEpisodesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideExplicitEpisodes', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByHideExplicitEpisodesHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideExplicitEpisodesHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByHideExplicitEpisodesHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideExplicitEpisodesHlc', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByPodcastKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastKey', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByPodcastKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastKey', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenBySeasonSortField() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonSortField', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenBySeasonSortFieldDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonSortField', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenBySeasonSortFieldHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonSortFieldHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenBySeasonSortFieldHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonSortFieldHlc', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenBySeasonSortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonSortOrder', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenBySeasonSortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonSortOrder', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenBySeasonSortOrderHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonSortOrderHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenBySeasonSortOrderHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonSortOrderHlc', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenBySelectedPlaylistId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedPlaylistId', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenBySelectedPlaylistIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedPlaylistId', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenBySelectedPlaylistIdHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedPlaylistIdHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenBySelectedPlaylistIdHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedPlaylistIdHlc', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenBySkipSilence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipSilence', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenBySkipSilenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipSilence', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenBySkipSilenceHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipSilenceHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenBySkipSilenceHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipSilenceHlc', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy> thenBySpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenBySpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenBySpeedHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenBySpeedHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedHlc', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByViewMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByViewModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByViewModeHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewModeHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByViewModeHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewModeHlc', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByVoiceBoost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceBoost', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByVoiceBoostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceBoost', Sort.desc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByVoiceBoostHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceBoostHlc', Sort.asc);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QAfterSortBy>
  thenByVoiceBoostHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceBoostHlc', Sort.desc);
    });
  }
}

extension PodcastUserStateQueryWhereDistinct
    on QueryBuilder<PodcastUserState, PodcastUserState, QDistinct> {
  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctByAutoPlayOrder({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'autoPlayOrder',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctByAutoPlayOrderHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoPlayOrderHlc');
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctByEpisodeFilter({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'episodeFilter',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctByEpisodeFilterHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'episodeFilterHlc');
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctByEpisodeSortOrder({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'episodeSortOrder',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctByEpisodeSortOrderHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'episodeSortOrderHlc');
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctByHasAudio() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasAudio');
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctByHasAudioHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasAudioHlc');
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctByHasParental() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasParental');
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctByHasParentalHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasParentalHlc');
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctByHasView() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasView');
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctByHasViewHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasViewHlc');
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctByHideExplicitEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hideExplicitEpisodes');
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctByHideExplicitEpisodesHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hideExplicitEpisodesHlc');
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctByPodcastKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'podcastKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctBySeasonSortField({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'seasonSortField',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctBySeasonSortFieldHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'seasonSortFieldHlc');
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctBySeasonSortOrder({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'seasonSortOrder',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctBySeasonSortOrderHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'seasonSortOrderHlc');
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctBySelectedPlaylistId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'selectedPlaylistId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctBySelectedPlaylistIdHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'selectedPlaylistIdHlc');
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctBySkipSilence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'skipSilence');
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctBySkipSilenceHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'skipSilenceHlc');
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctBySpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'speed');
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctBySpeedHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'speedHlc');
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctByViewMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'viewMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctByViewModeHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'viewModeHlc');
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctByVoiceBoost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'voiceBoost');
    });
  }

  QueryBuilder<PodcastUserState, PodcastUserState, QDistinct>
  distinctByVoiceBoostHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'voiceBoostHlc');
    });
  }
}

extension PodcastUserStateQueryProperty
    on QueryBuilder<PodcastUserState, PodcastUserState, QQueryProperty> {
  QueryBuilder<PodcastUserState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PodcastUserState, String?, QQueryOperations>
  autoPlayOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoPlayOrder');
    });
  }

  QueryBuilder<PodcastUserState, int, QQueryOperations>
  autoPlayOrderHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoPlayOrderHlc');
    });
  }

  QueryBuilder<PodcastUserState, String, QQueryOperations>
  episodeFilterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeFilter');
    });
  }

  QueryBuilder<PodcastUserState, int, QQueryOperations>
  episodeFilterHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeFilterHlc');
    });
  }

  QueryBuilder<PodcastUserState, String, QQueryOperations>
  episodeSortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeSortOrder');
    });
  }

  QueryBuilder<PodcastUserState, int, QQueryOperations>
  episodeSortOrderHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeSortOrderHlc');
    });
  }

  QueryBuilder<PodcastUserState, bool, QQueryOperations> hasAudioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasAudio');
    });
  }

  QueryBuilder<PodcastUserState, int, QQueryOperations> hasAudioHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasAudioHlc');
    });
  }

  QueryBuilder<PodcastUserState, bool, QQueryOperations> hasParentalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasParental');
    });
  }

  QueryBuilder<PodcastUserState, int, QQueryOperations>
  hasParentalHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasParentalHlc');
    });
  }

  QueryBuilder<PodcastUserState, bool, QQueryOperations> hasViewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasView');
    });
  }

  QueryBuilder<PodcastUserState, int, QQueryOperations> hasViewHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasViewHlc');
    });
  }

  QueryBuilder<PodcastUserState, bool, QQueryOperations>
  hideExplicitEpisodesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hideExplicitEpisodes');
    });
  }

  QueryBuilder<PodcastUserState, int, QQueryOperations>
  hideExplicitEpisodesHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hideExplicitEpisodesHlc');
    });
  }

  QueryBuilder<PodcastUserState, List<PlayOrderEntry>, QQueryOperations>
  playOrdersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playOrders');
    });
  }

  QueryBuilder<PodcastUserState, String, QQueryOperations>
  podcastKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'podcastKey');
    });
  }

  QueryBuilder<PodcastUserState, String, QQueryOperations>
  seasonSortFieldProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seasonSortField');
    });
  }

  QueryBuilder<PodcastUserState, int, QQueryOperations>
  seasonSortFieldHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seasonSortFieldHlc');
    });
  }

  QueryBuilder<PodcastUserState, String, QQueryOperations>
  seasonSortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seasonSortOrder');
    });
  }

  QueryBuilder<PodcastUserState, int, QQueryOperations>
  seasonSortOrderHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seasonSortOrderHlc');
    });
  }

  QueryBuilder<PodcastUserState, String?, QQueryOperations>
  selectedPlaylistIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'selectedPlaylistId');
    });
  }

  QueryBuilder<PodcastUserState, int, QQueryOperations>
  selectedPlaylistIdHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'selectedPlaylistIdHlc');
    });
  }

  QueryBuilder<PodcastUserState, bool?, QQueryOperations>
  skipSilenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'skipSilence');
    });
  }

  QueryBuilder<PodcastUserState, int, QQueryOperations>
  skipSilenceHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'skipSilenceHlc');
    });
  }

  QueryBuilder<PodcastUserState, double, QQueryOperations> speedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'speed');
    });
  }

  QueryBuilder<PodcastUserState, int, QQueryOperations> speedHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'speedHlc');
    });
  }

  QueryBuilder<PodcastUserState, String, QQueryOperations> viewModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'viewMode');
    });
  }

  QueryBuilder<PodcastUserState, int, QQueryOperations> viewModeHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'viewModeHlc');
    });
  }

  QueryBuilder<PodcastUserState, bool?, QQueryOperations> voiceBoostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'voiceBoost');
    });
  }

  QueryBuilder<PodcastUserState, int, QQueryOperations>
  voiceBoostHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'voiceBoostHlc');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

const PlayOrderEntrySchema = Schema(
  name: r'PlayOrderEntry',
  id: -1594682875048127273,
  properties: {
    r'groupId': PropertySchema(id: 0, name: r'groupId', type: IsarType.string),
    r'hlc': PropertySchema(id: 1, name: r'hlc', type: IsarType.long),
    r'order': PropertySchema(id: 2, name: r'order', type: IsarType.string),
    r'playlistId': PropertySchema(
      id: 3,
      name: r'playlistId',
      type: IsarType.string,
    ),
  },

  estimateSize: _playOrderEntryEstimateSize,
  serialize: _playOrderEntrySerialize,
  deserialize: _playOrderEntryDeserialize,
  deserializeProp: _playOrderEntryDeserializeProp,
);

int _playOrderEntryEstimateSize(
  PlayOrderEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.groupId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.order;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.playlistId.length * 3;
  return bytesCount;
}

void _playOrderEntrySerialize(
  PlayOrderEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.groupId);
  writer.writeLong(offsets[1], object.hlc);
  writer.writeString(offsets[2], object.order);
  writer.writeString(offsets[3], object.playlistId);
}

PlayOrderEntry _playOrderEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlayOrderEntry();
  object.groupId = reader.readStringOrNull(offsets[0]);
  object.hlc = reader.readLong(offsets[1]);
  object.order = reader.readStringOrNull(offsets[2]);
  object.playlistId = reader.readString(offsets[3]);
  return object;
}

P _playOrderEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension PlayOrderEntryQueryFilter
    on QueryBuilder<PlayOrderEntry, PlayOrderEntry, QFilterCondition> {
  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  groupIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'groupId'),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  groupIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'groupId'),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  groupIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  groupIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  groupIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  groupIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'groupId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  groupIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  groupIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  groupIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  groupIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'groupId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  groupIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'groupId', value: ''),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  groupIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'groupId', value: ''),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  hlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hlc', value: value),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  hlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  hlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  hlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  orderIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'order'),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  orderIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'order'),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  orderEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'order',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  orderGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'order',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  orderLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'order',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  orderBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'order',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  orderStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'order',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  orderEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'order',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  orderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'order',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  orderMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'order',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  orderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'order', value: ''),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  orderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'order', value: ''),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  playlistIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'playlistId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  playlistIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'playlistId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  playlistIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'playlistId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  playlistIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'playlistId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  playlistIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'playlistId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  playlistIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'playlistId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  playlistIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'playlistId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  playlistIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'playlistId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  playlistIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'playlistId', value: ''),
      );
    });
  }

  QueryBuilder<PlayOrderEntry, PlayOrderEntry, QAfterFilterCondition>
  playlistIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'playlistId', value: ''),
      );
    });
  }
}

extension PlayOrderEntryQueryObject
    on QueryBuilder<PlayOrderEntry, PlayOrderEntry, QFilterCondition> {}
