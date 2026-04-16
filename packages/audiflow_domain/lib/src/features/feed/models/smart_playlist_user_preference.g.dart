// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smart_playlist_user_preference.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSmartPlaylistUserPreferenceCollection on Isar {
  IsarCollection<SmartPlaylistUserPreference>
  get smartPlaylistUserPreferences => this.collection();
}

const SmartPlaylistUserPreferenceSchema = CollectionSchema(
  name: r'SmartPlaylistUserPreference',
  id: -3334988972846870472,
  properties: {
    r'autoPlayOrder': PropertySchema(
      id: 0,
      name: r'autoPlayOrder',
      type: IsarType.string,
    ),
    r'playlistId': PropertySchema(
      id: 1,
      name: r'playlistId',
      type: IsarType.string,
    ),
    r'podcastId': PropertySchema(
      id: 2,
      name: r'podcastId',
      type: IsarType.long,
    ),
  },

  estimateSize: _smartPlaylistUserPreferenceEstimateSize,
  serialize: _smartPlaylistUserPreferenceSerialize,
  deserialize: _smartPlaylistUserPreferenceDeserialize,
  deserializeProp: _smartPlaylistUserPreferenceDeserializeProp,
  idName: r'id',
  indexes: {
    r'podcastId_playlistId': IndexSchema(
      id: -860587556954498692,
      name: r'podcastId_playlistId',
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
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _smartPlaylistUserPreferenceGetId,
  getLinks: _smartPlaylistUserPreferenceGetLinks,
  attach: _smartPlaylistUserPreferenceAttach,
  version: '3.3.2',
);

int _smartPlaylistUserPreferenceEstimateSize(
  SmartPlaylistUserPreference object,
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
  bytesCount += 3 + object.playlistId.length * 3;
  return bytesCount;
}

void _smartPlaylistUserPreferenceSerialize(
  SmartPlaylistUserPreference object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.autoPlayOrder);
  writer.writeString(offsets[1], object.playlistId);
  writer.writeLong(offsets[2], object.podcastId);
}

SmartPlaylistUserPreference _smartPlaylistUserPreferenceDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SmartPlaylistUserPreference();
  object.autoPlayOrder = reader.readStringOrNull(offsets[0]);
  object.id = id;
  object.playlistId = reader.readString(offsets[1]);
  object.podcastId = reader.readLong(offsets[2]);
  return object;
}

P _smartPlaylistUserPreferenceDeserializeProp<P>(
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
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _smartPlaylistUserPreferenceGetId(SmartPlaylistUserPreference object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _smartPlaylistUserPreferenceGetLinks(
  SmartPlaylistUserPreference object,
) {
  return [];
}

void _smartPlaylistUserPreferenceAttach(
  IsarCollection<dynamic> col,
  Id id,
  SmartPlaylistUserPreference object,
) {
  object.id = id;
}

extension SmartPlaylistUserPreferenceByIndex
    on IsarCollection<SmartPlaylistUserPreference> {
  Future<SmartPlaylistUserPreference?> getByPodcastIdPlaylistId(
    int podcastId,
    String playlistId,
  ) {
    return getByIndex(r'podcastId_playlistId', [podcastId, playlistId]);
  }

  SmartPlaylistUserPreference? getByPodcastIdPlaylistIdSync(
    int podcastId,
    String playlistId,
  ) {
    return getByIndexSync(r'podcastId_playlistId', [podcastId, playlistId]);
  }

  Future<bool> deleteByPodcastIdPlaylistId(int podcastId, String playlistId) {
    return deleteByIndex(r'podcastId_playlistId', [podcastId, playlistId]);
  }

  bool deleteByPodcastIdPlaylistIdSync(int podcastId, String playlistId) {
    return deleteByIndexSync(r'podcastId_playlistId', [podcastId, playlistId]);
  }

  Future<List<SmartPlaylistUserPreference?>> getAllByPodcastIdPlaylistId(
    List<int> podcastIdValues,
    List<String> playlistIdValues,
  ) {
    final len = podcastIdValues.length;
    assert(
      playlistIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([podcastIdValues[i], playlistIdValues[i]]);
    }

    return getAllByIndex(r'podcastId_playlistId', values);
  }

  List<SmartPlaylistUserPreference?> getAllByPodcastIdPlaylistIdSync(
    List<int> podcastIdValues,
    List<String> playlistIdValues,
  ) {
    final len = podcastIdValues.length;
    assert(
      playlistIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([podcastIdValues[i], playlistIdValues[i]]);
    }

    return getAllByIndexSync(r'podcastId_playlistId', values);
  }

  Future<int> deleteAllByPodcastIdPlaylistId(
    List<int> podcastIdValues,
    List<String> playlistIdValues,
  ) {
    final len = podcastIdValues.length;
    assert(
      playlistIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([podcastIdValues[i], playlistIdValues[i]]);
    }

    return deleteAllByIndex(r'podcastId_playlistId', values);
  }

  int deleteAllByPodcastIdPlaylistIdSync(
    List<int> podcastIdValues,
    List<String> playlistIdValues,
  ) {
    final len = podcastIdValues.length;
    assert(
      playlistIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([podcastIdValues[i], playlistIdValues[i]]);
    }

    return deleteAllByIndexSync(r'podcastId_playlistId', values);
  }

  Future<Id> putByPodcastIdPlaylistId(SmartPlaylistUserPreference object) {
    return putByIndex(r'podcastId_playlistId', object);
  }

  Id putByPodcastIdPlaylistIdSync(
    SmartPlaylistUserPreference object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(
      r'podcastId_playlistId',
      object,
      saveLinks: saveLinks,
    );
  }

  Future<List<Id>> putAllByPodcastIdPlaylistId(
    List<SmartPlaylistUserPreference> objects,
  ) {
    return putAllByIndex(r'podcastId_playlistId', objects);
  }

  List<Id> putAllByPodcastIdPlaylistIdSync(
    List<SmartPlaylistUserPreference> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(
      r'podcastId_playlistId',
      objects,
      saveLinks: saveLinks,
    );
  }
}

extension SmartPlaylistUserPreferenceQueryWhereSort
    on
        QueryBuilder<
          SmartPlaylistUserPreference,
          SmartPlaylistUserPreference,
          QWhere
        > {
  QueryBuilder<
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
    QAfterWhere
  >
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SmartPlaylistUserPreferenceQueryWhere
    on
        QueryBuilder<
          SmartPlaylistUserPreference,
          SmartPlaylistUserPreference,
          QWhereClause
        > {
  QueryBuilder<
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
    QAfterWhereClause
  >
  podcastIdEqualToAnyPlaylistId(int podcastId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'podcastId_playlistId',
          value: [podcastId],
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
    QAfterWhereClause
  >
  podcastIdNotEqualToAnyPlaylistId(int podcastId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId',
                lower: [],
                upper: [podcastId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId',
                lower: [podcastId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId',
                lower: [podcastId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId',
                lower: [],
                upper: [podcastId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
    QAfterWhereClause
  >
  podcastIdGreaterThanAnyPlaylistId(int podcastId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'podcastId_playlistId',
          lower: [podcastId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
    QAfterWhereClause
  >
  podcastIdLessThanAnyPlaylistId(int podcastId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'podcastId_playlistId',
          lower: [],
          upper: [podcastId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
    QAfterWhereClause
  >
  podcastIdBetweenAnyPlaylistId(
    int lowerPodcastId,
    int upperPodcastId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'podcastId_playlistId',
          lower: [lowerPodcastId],
          includeLower: includeLower,
          upper: [upperPodcastId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
    QAfterWhereClause
  >
  podcastIdPlaylistIdEqualTo(int podcastId, String playlistId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'podcastId_playlistId',
          value: [podcastId, playlistId],
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
    QAfterWhereClause
  >
  podcastIdEqualToPlaylistIdNotEqualTo(int podcastId, String playlistId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId',
                lower: [podcastId],
                upper: [podcastId, playlistId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId',
                lower: [podcastId, playlistId],
                includeLower: false,
                upper: [podcastId],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId',
                lower: [podcastId, playlistId],
                includeLower: false,
                upper: [podcastId],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId',
                lower: [podcastId],
                upper: [podcastId, playlistId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension SmartPlaylistUserPreferenceQueryFilter
    on
        QueryBuilder<
          SmartPlaylistUserPreference,
          SmartPlaylistUserPreference,
          QFilterCondition
        > {
  QueryBuilder<
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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

extension SmartPlaylistUserPreferenceQueryObject
    on
        QueryBuilder<
          SmartPlaylistUserPreference,
          SmartPlaylistUserPreference,
          QFilterCondition
        > {}

extension SmartPlaylistUserPreferenceQueryLinks
    on
        QueryBuilder<
          SmartPlaylistUserPreference,
          SmartPlaylistUserPreference,
          QFilterCondition
        > {}

extension SmartPlaylistUserPreferenceQuerySortBy
    on
        QueryBuilder<
          SmartPlaylistUserPreference,
          SmartPlaylistUserPreference,
          QSortBy
        > {
  QueryBuilder<
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
    QAfterSortBy
  >
  sortByAutoPlayOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoPlayOrder', Sort.asc);
    });
  }

  QueryBuilder<
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
    QAfterSortBy
  >
  sortByAutoPlayOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoPlayOrder', Sort.desc);
    });
  }

  QueryBuilder<
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
    QAfterSortBy
  >
  sortByPlaylistId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.asc);
    });
  }

  QueryBuilder<
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
    QAfterSortBy
  >
  sortByPlaylistIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.desc);
    });
  }

  QueryBuilder<
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
    QAfterSortBy
  >
  sortByPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.asc);
    });
  }

  QueryBuilder<
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
    QAfterSortBy
  >
  sortByPodcastIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.desc);
    });
  }
}

extension SmartPlaylistUserPreferenceQuerySortThenBy
    on
        QueryBuilder<
          SmartPlaylistUserPreference,
          SmartPlaylistUserPreference,
          QSortThenBy
        > {
  QueryBuilder<
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
    QAfterSortBy
  >
  thenByAutoPlayOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoPlayOrder', Sort.asc);
    });
  }

  QueryBuilder<
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
    QAfterSortBy
  >
  thenByAutoPlayOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoPlayOrder', Sort.desc);
    });
  }

  QueryBuilder<
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
    QAfterSortBy
  >
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
    QAfterSortBy
  >
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
    QAfterSortBy
  >
  thenByPlaylistId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.asc);
    });
  }

  QueryBuilder<
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
    QAfterSortBy
  >
  thenByPlaylistIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.desc);
    });
  }

  QueryBuilder<
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
    QAfterSortBy
  >
  thenByPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.asc);
    });
  }

  QueryBuilder<
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
    QAfterSortBy
  >
  thenByPodcastIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.desc);
    });
  }
}

extension SmartPlaylistUserPreferenceQueryWhereDistinct
    on
        QueryBuilder<
          SmartPlaylistUserPreference,
          SmartPlaylistUserPreference,
          QDistinct
        > {
  QueryBuilder<
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
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
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
    QDistinct
  >
  distinctByPlaylistId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playlistId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    SmartPlaylistUserPreference,
    SmartPlaylistUserPreference,
    QDistinct
  >
  distinctByPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'podcastId');
    });
  }
}

extension SmartPlaylistUserPreferenceQueryProperty
    on
        QueryBuilder<
          SmartPlaylistUserPreference,
          SmartPlaylistUserPreference,
          QQueryProperty
        > {
  QueryBuilder<SmartPlaylistUserPreference, int, QQueryOperations>
  idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SmartPlaylistUserPreference, String?, QQueryOperations>
  autoPlayOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoPlayOrder');
    });
  }

  QueryBuilder<SmartPlaylistUserPreference, String, QQueryOperations>
  playlistIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playlistId');
    });
  }

  QueryBuilder<SmartPlaylistUserPreference, int, QQueryOperations>
  podcastIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'podcastId');
    });
  }
}
