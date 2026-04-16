// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smart_playlist_group_user_preference.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSmartPlaylistGroupUserPreferenceCollection on Isar {
  IsarCollection<SmartPlaylistGroupUserPreference>
  get smartPlaylistGroupUserPreferences => this.collection();
}

const SmartPlaylistGroupUserPreferenceSchema = CollectionSchema(
  name: r'SmartPlaylistGroupUserPreference',
  id: -8888867929676018064,
  properties: {
    r'autoPlayOrder': PropertySchema(
      id: 0,
      name: r'autoPlayOrder',
      type: IsarType.string,
    ),
    r'groupId': PropertySchema(id: 1, name: r'groupId', type: IsarType.string),
    r'playlistId': PropertySchema(
      id: 2,
      name: r'playlistId',
      type: IsarType.string,
    ),
    r'podcastId': PropertySchema(
      id: 3,
      name: r'podcastId',
      type: IsarType.long,
    ),
  },

  estimateSize: _smartPlaylistGroupUserPreferenceEstimateSize,
  serialize: _smartPlaylistGroupUserPreferenceSerialize,
  deserialize: _smartPlaylistGroupUserPreferenceDeserialize,
  deserializeProp: _smartPlaylistGroupUserPreferenceDeserializeProp,
  idName: r'id',
  indexes: {
    r'podcastId_playlistId_groupId': IndexSchema(
      id: 4783415948935367414,
      name: r'podcastId_playlistId_groupId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'podcastId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'playlistId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'groupId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _smartPlaylistGroupUserPreferenceGetId,
  getLinks: _smartPlaylistGroupUserPreferenceGetLinks,
  attach: _smartPlaylistGroupUserPreferenceAttach,
  version: '3.3.2',
);

int _smartPlaylistGroupUserPreferenceEstimateSize(
  SmartPlaylistGroupUserPreference object,
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
  bytesCount += 3 + object.groupId.length * 3;
  bytesCount += 3 + object.playlistId.length * 3;
  return bytesCount;
}

void _smartPlaylistGroupUserPreferenceSerialize(
  SmartPlaylistGroupUserPreference object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.autoPlayOrder);
  writer.writeString(offsets[1], object.groupId);
  writer.writeString(offsets[2], object.playlistId);
  writer.writeLong(offsets[3], object.podcastId);
}

SmartPlaylistGroupUserPreference _smartPlaylistGroupUserPreferenceDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SmartPlaylistGroupUserPreference();
  object.autoPlayOrder = reader.readStringOrNull(offsets[0]);
  object.groupId = reader.readString(offsets[1]);
  object.id = id;
  object.playlistId = reader.readString(offsets[2]);
  object.podcastId = reader.readLong(offsets[3]);
  return object;
}

P _smartPlaylistGroupUserPreferenceDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _smartPlaylistGroupUserPreferenceGetId(
  SmartPlaylistGroupUserPreference object,
) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _smartPlaylistGroupUserPreferenceGetLinks(
  SmartPlaylistGroupUserPreference object,
) {
  return [];
}

void _smartPlaylistGroupUserPreferenceAttach(
  IsarCollection<dynamic> col,
  Id id,
  SmartPlaylistGroupUserPreference object,
) {
  object.id = id;
}

extension SmartPlaylistGroupUserPreferenceByIndex
    on IsarCollection<SmartPlaylistGroupUserPreference> {
  Future<SmartPlaylistGroupUserPreference?> getByPodcastIdPlaylistIdGroupId(
    int podcastId,
    String playlistId,
    String groupId,
  ) {
    return getByIndex(r'podcastId_playlistId_groupId', [
      podcastId,
      playlistId,
      groupId,
    ]);
  }

  SmartPlaylistGroupUserPreference? getByPodcastIdPlaylistIdGroupIdSync(
    int podcastId,
    String playlistId,
    String groupId,
  ) {
    return getByIndexSync(r'podcastId_playlistId_groupId', [
      podcastId,
      playlistId,
      groupId,
    ]);
  }

  Future<bool> deleteByPodcastIdPlaylistIdGroupId(
    int podcastId,
    String playlistId,
    String groupId,
  ) {
    return deleteByIndex(r'podcastId_playlistId_groupId', [
      podcastId,
      playlistId,
      groupId,
    ]);
  }

  bool deleteByPodcastIdPlaylistIdGroupIdSync(
    int podcastId,
    String playlistId,
    String groupId,
  ) {
    return deleteByIndexSync(r'podcastId_playlistId_groupId', [
      podcastId,
      playlistId,
      groupId,
    ]);
  }

  Future<List<SmartPlaylistGroupUserPreference?>>
  getAllByPodcastIdPlaylistIdGroupId(
    List<int> podcastIdValues,
    List<String> playlistIdValues,
    List<String> groupIdValues,
  ) {
    final len = podcastIdValues.length;
    assert(
      playlistIdValues.length == len && groupIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([podcastIdValues[i], playlistIdValues[i], groupIdValues[i]]);
    }

    return getAllByIndex(r'podcastId_playlistId_groupId', values);
  }

  List<SmartPlaylistGroupUserPreference?>
  getAllByPodcastIdPlaylistIdGroupIdSync(
    List<int> podcastIdValues,
    List<String> playlistIdValues,
    List<String> groupIdValues,
  ) {
    final len = podcastIdValues.length;
    assert(
      playlistIdValues.length == len && groupIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([podcastIdValues[i], playlistIdValues[i], groupIdValues[i]]);
    }

    return getAllByIndexSync(r'podcastId_playlistId_groupId', values);
  }

  Future<int> deleteAllByPodcastIdPlaylistIdGroupId(
    List<int> podcastIdValues,
    List<String> playlistIdValues,
    List<String> groupIdValues,
  ) {
    final len = podcastIdValues.length;
    assert(
      playlistIdValues.length == len && groupIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([podcastIdValues[i], playlistIdValues[i], groupIdValues[i]]);
    }

    return deleteAllByIndex(r'podcastId_playlistId_groupId', values);
  }

  int deleteAllByPodcastIdPlaylistIdGroupIdSync(
    List<int> podcastIdValues,
    List<String> playlistIdValues,
    List<String> groupIdValues,
  ) {
    final len = podcastIdValues.length;
    assert(
      playlistIdValues.length == len && groupIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([podcastIdValues[i], playlistIdValues[i], groupIdValues[i]]);
    }

    return deleteAllByIndexSync(r'podcastId_playlistId_groupId', values);
  }

  Future<Id> putByPodcastIdPlaylistIdGroupId(
    SmartPlaylistGroupUserPreference object,
  ) {
    return putByIndex(r'podcastId_playlistId_groupId', object);
  }

  Id putByPodcastIdPlaylistIdGroupIdSync(
    SmartPlaylistGroupUserPreference object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(
      r'podcastId_playlistId_groupId',
      object,
      saveLinks: saveLinks,
    );
  }

  Future<List<Id>> putAllByPodcastIdPlaylistIdGroupId(
    List<SmartPlaylistGroupUserPreference> objects,
  ) {
    return putAllByIndex(r'podcastId_playlistId_groupId', objects);
  }

  List<Id> putAllByPodcastIdPlaylistIdGroupIdSync(
    List<SmartPlaylistGroupUserPreference> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(
      r'podcastId_playlistId_groupId',
      objects,
      saveLinks: saveLinks,
    );
  }
}

extension SmartPlaylistGroupUserPreferenceQueryWhereSort
    on
        QueryBuilder<
          SmartPlaylistGroupUserPreference,
          SmartPlaylistGroupUserPreference,
          QWhere
        > {
  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterWhere
  >
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SmartPlaylistGroupUserPreferenceQueryWhere
    on
        QueryBuilder<
          SmartPlaylistGroupUserPreference,
          SmartPlaylistGroupUserPreference,
          QWhereClause
        > {
  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterWhereClause
  >
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterWhereClause
  >
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterWhereClause
  >
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterWhereClause
  >
  idBetween(
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterWhereClause
  >
  podcastIdEqualToAnyPlaylistIdGroupId(int podcastId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'podcastId_playlistId_groupId',
          value: [podcastId],
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterWhereClause
  >
  podcastIdNotEqualToAnyPlaylistIdGroupId(int podcastId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId_groupId',
                lower: [],
                upper: [podcastId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId_groupId',
                lower: [podcastId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId_groupId',
                lower: [podcastId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId_groupId',
                lower: [],
                upper: [podcastId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterWhereClause
  >
  podcastIdGreaterThanAnyPlaylistIdGroupId(
    int podcastId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'podcastId_playlistId_groupId',
          lower: [podcastId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterWhereClause
  >
  podcastIdLessThanAnyPlaylistIdGroupId(int podcastId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'podcastId_playlistId_groupId',
          lower: [],
          upper: [podcastId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterWhereClause
  >
  podcastIdBetweenAnyPlaylistIdGroupId(
    int lowerPodcastId,
    int upperPodcastId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'podcastId_playlistId_groupId',
          lower: [lowerPodcastId],
          includeLower: includeLower,
          upper: [upperPodcastId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterWhereClause
  >
  podcastIdPlaylistIdEqualToAnyGroupId(int podcastId, String playlistId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'podcastId_playlistId_groupId',
          value: [podcastId, playlistId],
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterWhereClause
  >
  podcastIdEqualToPlaylistIdNotEqualToAnyGroupId(
    int podcastId,
    String playlistId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId_groupId',
                lower: [podcastId],
                upper: [podcastId, playlistId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId_groupId',
                lower: [podcastId, playlistId],
                includeLower: false,
                upper: [podcastId],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId_groupId',
                lower: [podcastId, playlistId],
                includeLower: false,
                upper: [podcastId],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId_groupId',
                lower: [podcastId],
                upper: [podcastId, playlistId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterWhereClause
  >
  podcastIdPlaylistIdGroupIdEqualTo(
    int podcastId,
    String playlistId,
    String groupId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'podcastId_playlistId_groupId',
          value: [podcastId, playlistId, groupId],
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterWhereClause
  >
  podcastIdPlaylistIdEqualToGroupIdNotEqualTo(
    int podcastId,
    String playlistId,
    String groupId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId_groupId',
                lower: [podcastId, playlistId],
                upper: [podcastId, playlistId, groupId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId_groupId',
                lower: [podcastId, playlistId, groupId],
                includeLower: false,
                upper: [podcastId, playlistId],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId_groupId',
                lower: [podcastId, playlistId, groupId],
                includeLower: false,
                upper: [podcastId, playlistId],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId_groupId',
                lower: [podcastId, playlistId],
                upper: [podcastId, playlistId, groupId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension SmartPlaylistGroupUserPreferenceQueryFilter
    on
        QueryBuilder<
          SmartPlaylistGroupUserPreference,
          SmartPlaylistGroupUserPreference,
          QFilterCondition
        > {
  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
  autoPlayOrderIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'autoPlayOrder'),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
  autoPlayOrderIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'autoPlayOrder'),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
  autoPlayOrderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'autoPlayOrder', value: ''),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
  autoPlayOrderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'autoPlayOrder', value: ''),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
  groupIdEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
  groupIdGreaterThan(
    String value, {
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
  groupIdLessThan(
    String value, {
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
  groupIdBetween(
    String lower,
    String upper, {
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
  groupIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'groupId', value: ''),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
  groupIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'groupId', value: ''),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
  playlistIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'playlistId', value: ''),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
  playlistIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'playlistId', value: ''),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
  podcastIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'podcastId', value: value),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
  podcastIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'podcastId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
  podcastIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'podcastId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterFilterCondition
  >
  podcastIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'podcastId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension SmartPlaylistGroupUserPreferenceQueryObject
    on
        QueryBuilder<
          SmartPlaylistGroupUserPreference,
          SmartPlaylistGroupUserPreference,
          QFilterCondition
        > {}

extension SmartPlaylistGroupUserPreferenceQueryLinks
    on
        QueryBuilder<
          SmartPlaylistGroupUserPreference,
          SmartPlaylistGroupUserPreference,
          QFilterCondition
        > {}

extension SmartPlaylistGroupUserPreferenceQuerySortBy
    on
        QueryBuilder<
          SmartPlaylistGroupUserPreference,
          SmartPlaylistGroupUserPreference,
          QSortBy
        > {
  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterSortBy
  >
  sortByAutoPlayOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoPlayOrder', Sort.asc);
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterSortBy
  >
  sortByAutoPlayOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoPlayOrder', Sort.desc);
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterSortBy
  >
  sortByGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.asc);
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterSortBy
  >
  sortByGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.desc);
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterSortBy
  >
  sortByPlaylistId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.asc);
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterSortBy
  >
  sortByPlaylistIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.desc);
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterSortBy
  >
  sortByPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.asc);
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterSortBy
  >
  sortByPodcastIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.desc);
    });
  }
}

extension SmartPlaylistGroupUserPreferenceQuerySortThenBy
    on
        QueryBuilder<
          SmartPlaylistGroupUserPreference,
          SmartPlaylistGroupUserPreference,
          QSortThenBy
        > {
  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterSortBy
  >
  thenByAutoPlayOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoPlayOrder', Sort.asc);
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterSortBy
  >
  thenByAutoPlayOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoPlayOrder', Sort.desc);
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterSortBy
  >
  thenByGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.asc);
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterSortBy
  >
  thenByGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.desc);
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterSortBy
  >
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterSortBy
  >
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterSortBy
  >
  thenByPlaylistId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.asc);
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterSortBy
  >
  thenByPlaylistIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.desc);
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterSortBy
  >
  thenByPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.asc);
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QAfterSortBy
  >
  thenByPodcastIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.desc);
    });
  }
}

extension SmartPlaylistGroupUserPreferenceQueryWhereDistinct
    on
        QueryBuilder<
          SmartPlaylistGroupUserPreference,
          SmartPlaylistGroupUserPreference,
          QDistinct
        > {
  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QDistinct
  >
  distinctByAutoPlayOrder({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'autoPlayOrder',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QDistinct
  >
  distinctByGroupId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'groupId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QDistinct
  >
  distinctByPlaylistId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playlistId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    SmartPlaylistGroupUserPreference,
    SmartPlaylistGroupUserPreference,
    QDistinct
  >
  distinctByPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'podcastId');
    });
  }
}

extension SmartPlaylistGroupUserPreferenceQueryProperty
    on
        QueryBuilder<
          SmartPlaylistGroupUserPreference,
          SmartPlaylistGroupUserPreference,
          QQueryProperty
        > {
  QueryBuilder<SmartPlaylistGroupUserPreference, int, QQueryOperations>
  idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SmartPlaylistGroupUserPreference, String?, QQueryOperations>
  autoPlayOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoPlayOrder');
    });
  }

  QueryBuilder<SmartPlaylistGroupUserPreference, String, QQueryOperations>
  groupIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'groupId');
    });
  }

  QueryBuilder<SmartPlaylistGroupUserPreference, String, QQueryOperations>
  playlistIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playlistId');
    });
  }

  QueryBuilder<SmartPlaylistGroupUserPreference, int, QQueryOperations>
  podcastIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'podcastId');
    });
  }
}
