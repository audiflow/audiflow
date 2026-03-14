// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smart_playlists.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSmartPlaylistEntityCollection on Isar {
  IsarCollection<SmartPlaylistEntity> get smartPlaylistEntitys =>
      this.collection();
}

const SmartPlaylistEntitySchema = CollectionSchema(
  name: r'SmartPlaylist',
  id: 1323148959236398571,
  properties: {
    r'displayName': PropertySchema(
      id: 0,
      name: r'displayName',
      type: IsarType.string,
    ),
    r'playlistNumber': PropertySchema(
      id: 1,
      name: r'playlistNumber',
      type: IsarType.long,
    ),
    r'playlistStructure': PropertySchema(
      id: 2,
      name: r'playlistStructure',
      type: IsarType.string,
    ),
    r'podcastId': PropertySchema(
      id: 3,
      name: r'podcastId',
      type: IsarType.long,
    ),
    r'resolverType': PropertySchema(
      id: 4,
      name: r'resolverType',
      type: IsarType.string,
    ),
    r'sortKey': PropertySchema(id: 5, name: r'sortKey', type: IsarType.long),
    r'thumbnailUrl': PropertySchema(
      id: 6,
      name: r'thumbnailUrl',
      type: IsarType.string,
    ),
    r'yearGrouped': PropertySchema(
      id: 7,
      name: r'yearGrouped',
      type: IsarType.bool,
    ),
    r'yearHeaderMode': PropertySchema(
      id: 8,
      name: r'yearHeaderMode',
      type: IsarType.string,
    ),
  },

  estimateSize: _smartPlaylistEntityEstimateSize,
  serialize: _smartPlaylistEntitySerialize,
  deserialize: _smartPlaylistEntityDeserialize,
  deserializeProp: _smartPlaylistEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'podcastId_playlistNumber': IndexSchema(
      id: -6079703636915472658,
      name: r'podcastId_playlistNumber',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'podcastId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'playlistNumber',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _smartPlaylistEntityGetId,
  getLinks: _smartPlaylistEntityGetLinks,
  attach: _smartPlaylistEntityAttach,
  version: '3.3.0',
);

int _smartPlaylistEntityEstimateSize(
  SmartPlaylistEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.displayName.length * 3;
  bytesCount += 3 + object.playlistStructure.length * 3;
  bytesCount += 3 + object.resolverType.length * 3;
  {
    final value = object.thumbnailUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.yearHeaderMode.length * 3;
  return bytesCount;
}

void _smartPlaylistEntitySerialize(
  SmartPlaylistEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.displayName);
  writer.writeLong(offsets[1], object.playlistNumber);
  writer.writeString(offsets[2], object.playlistStructure);
  writer.writeLong(offsets[3], object.podcastId);
  writer.writeString(offsets[4], object.resolverType);
  writer.writeLong(offsets[5], object.sortKey);
  writer.writeString(offsets[6], object.thumbnailUrl);
  writer.writeBool(offsets[7], object.yearGrouped);
  writer.writeString(offsets[8], object.yearHeaderMode);
}

SmartPlaylistEntity _smartPlaylistEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SmartPlaylistEntity();
  object.displayName = reader.readString(offsets[0]);
  object.id = id;
  object.playlistNumber = reader.readLong(offsets[1]);
  object.playlistStructure = reader.readString(offsets[2]);
  object.podcastId = reader.readLong(offsets[3]);
  object.resolverType = reader.readString(offsets[4]);
  object.sortKey = reader.readLong(offsets[5]);
  object.thumbnailUrl = reader.readStringOrNull(offsets[6]);
  object.yearGrouped = reader.readBool(offsets[7]);
  object.yearHeaderMode = reader.readString(offsets[8]);
  return object;
}

P _smartPlaylistEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
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
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _smartPlaylistEntityGetId(SmartPlaylistEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _smartPlaylistEntityGetLinks(
  SmartPlaylistEntity object,
) {
  return [];
}

void _smartPlaylistEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  SmartPlaylistEntity object,
) {
  object.id = id;
}

extension SmartPlaylistEntityByIndex on IsarCollection<SmartPlaylistEntity> {
  Future<SmartPlaylistEntity?> getByPodcastIdPlaylistNumber(
    int podcastId,
    int playlistNumber,
  ) {
    return getByIndex(r'podcastId_playlistNumber', [podcastId, playlistNumber]);
  }

  SmartPlaylistEntity? getByPodcastIdPlaylistNumberSync(
    int podcastId,
    int playlistNumber,
  ) {
    return getByIndexSync(r'podcastId_playlistNumber', [
      podcastId,
      playlistNumber,
    ]);
  }

  Future<bool> deleteByPodcastIdPlaylistNumber(
    int podcastId,
    int playlistNumber,
  ) {
    return deleteByIndex(r'podcastId_playlistNumber', [
      podcastId,
      playlistNumber,
    ]);
  }

  bool deleteByPodcastIdPlaylistNumberSync(int podcastId, int playlistNumber) {
    return deleteByIndexSync(r'podcastId_playlistNumber', [
      podcastId,
      playlistNumber,
    ]);
  }

  Future<List<SmartPlaylistEntity?>> getAllByPodcastIdPlaylistNumber(
    List<int> podcastIdValues,
    List<int> playlistNumberValues,
  ) {
    final len = podcastIdValues.length;
    assert(
      playlistNumberValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([podcastIdValues[i], playlistNumberValues[i]]);
    }

    return getAllByIndex(r'podcastId_playlistNumber', values);
  }

  List<SmartPlaylistEntity?> getAllByPodcastIdPlaylistNumberSync(
    List<int> podcastIdValues,
    List<int> playlistNumberValues,
  ) {
    final len = podcastIdValues.length;
    assert(
      playlistNumberValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([podcastIdValues[i], playlistNumberValues[i]]);
    }

    return getAllByIndexSync(r'podcastId_playlistNumber', values);
  }

  Future<int> deleteAllByPodcastIdPlaylistNumber(
    List<int> podcastIdValues,
    List<int> playlistNumberValues,
  ) {
    final len = podcastIdValues.length;
    assert(
      playlistNumberValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([podcastIdValues[i], playlistNumberValues[i]]);
    }

    return deleteAllByIndex(r'podcastId_playlistNumber', values);
  }

  int deleteAllByPodcastIdPlaylistNumberSync(
    List<int> podcastIdValues,
    List<int> playlistNumberValues,
  ) {
    final len = podcastIdValues.length;
    assert(
      playlistNumberValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([podcastIdValues[i], playlistNumberValues[i]]);
    }

    return deleteAllByIndexSync(r'podcastId_playlistNumber', values);
  }

  Future<Id> putByPodcastIdPlaylistNumber(SmartPlaylistEntity object) {
    return putByIndex(r'podcastId_playlistNumber', object);
  }

  Id putByPodcastIdPlaylistNumberSync(
    SmartPlaylistEntity object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(
      r'podcastId_playlistNumber',
      object,
      saveLinks: saveLinks,
    );
  }

  Future<List<Id>> putAllByPodcastIdPlaylistNumber(
    List<SmartPlaylistEntity> objects,
  ) {
    return putAllByIndex(r'podcastId_playlistNumber', objects);
  }

  List<Id> putAllByPodcastIdPlaylistNumberSync(
    List<SmartPlaylistEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(
      r'podcastId_playlistNumber',
      objects,
      saveLinks: saveLinks,
    );
  }
}

extension SmartPlaylistEntityQueryWhereSort
    on QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QWhere> {
  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterWhere>
  anyPodcastIdPlaylistNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'podcastId_playlistNumber'),
      );
    });
  }
}

extension SmartPlaylistEntityQueryWhere
    on QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QWhereClause> {
  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterWhereClause>
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterWhereClause>
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterWhereClause>
  podcastIdEqualToAnyPlaylistNumber(int podcastId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'podcastId_playlistNumber',
          value: [podcastId],
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterWhereClause>
  podcastIdNotEqualToAnyPlaylistNumber(int podcastId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistNumber',
                lower: [],
                upper: [podcastId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistNumber',
                lower: [podcastId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistNumber',
                lower: [podcastId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistNumber',
                lower: [],
                upper: [podcastId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterWhereClause>
  podcastIdGreaterThanAnyPlaylistNumber(int podcastId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'podcastId_playlistNumber',
          lower: [podcastId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterWhereClause>
  podcastIdLessThanAnyPlaylistNumber(int podcastId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'podcastId_playlistNumber',
          lower: [],
          upper: [podcastId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterWhereClause>
  podcastIdBetweenAnyPlaylistNumber(
    int lowerPodcastId,
    int upperPodcastId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'podcastId_playlistNumber',
          lower: [lowerPodcastId],
          includeLower: includeLower,
          upper: [upperPodcastId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterWhereClause>
  podcastIdPlaylistNumberEqualTo(int podcastId, int playlistNumber) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'podcastId_playlistNumber',
          value: [podcastId, playlistNumber],
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterWhereClause>
  podcastIdEqualToPlaylistNumberNotEqualTo(int podcastId, int playlistNumber) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistNumber',
                lower: [podcastId],
                upper: [podcastId, playlistNumber],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistNumber',
                lower: [podcastId, playlistNumber],
                includeLower: false,
                upper: [podcastId],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistNumber',
                lower: [podcastId, playlistNumber],
                includeLower: false,
                upper: [podcastId],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistNumber',
                lower: [podcastId],
                upper: [podcastId, playlistNumber],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterWhereClause>
  podcastIdEqualToPlaylistNumberGreaterThan(
    int podcastId,
    int playlistNumber, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'podcastId_playlistNumber',
          lower: [podcastId, playlistNumber],
          includeLower: include,
          upper: [podcastId],
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterWhereClause>
  podcastIdEqualToPlaylistNumberLessThan(
    int podcastId,
    int playlistNumber, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'podcastId_playlistNumber',
          lower: [podcastId],
          upper: [podcastId, playlistNumber],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterWhereClause>
  podcastIdEqualToPlaylistNumberBetween(
    int podcastId,
    int lowerPlaylistNumber,
    int upperPlaylistNumber, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'podcastId_playlistNumber',
          lower: [podcastId, lowerPlaylistNumber],
          includeLower: includeLower,
          upper: [podcastId, upperPlaylistNumber],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension SmartPlaylistEntityQueryFilter
    on
        QueryBuilder<
          SmartPlaylistEntity,
          SmartPlaylistEntity,
          QFilterCondition
        > {
  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  displayNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  displayNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  displayNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  displayNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'displayName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  displayNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  displayNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  displayNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  displayNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'displayName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  displayNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'displayName', value: ''),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  displayNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'displayName', value: ''),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  playlistNumberEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'playlistNumber', value: value),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  playlistNumberGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'playlistNumber',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  playlistNumberLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'playlistNumber',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  playlistNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'playlistNumber',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  playlistStructureEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'playlistStructure',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  playlistStructureGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'playlistStructure',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  playlistStructureLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'playlistStructure',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  playlistStructureBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'playlistStructure',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  playlistStructureStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'playlistStructure',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  playlistStructureEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'playlistStructure',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  playlistStructureContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'playlistStructure',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  playlistStructureMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'playlistStructure',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  playlistStructureIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'playlistStructure', value: ''),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  playlistStructureIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'playlistStructure', value: ''),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  podcastIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'podcastId', value: value),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  resolverTypeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'resolverType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  resolverTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'resolverType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  resolverTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'resolverType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  resolverTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'resolverType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  resolverTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'resolverType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  resolverTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'resolverType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  resolverTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'resolverType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  resolverTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'resolverType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  resolverTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'resolverType', value: ''),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  resolverTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'resolverType', value: ''),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  sortKeyEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sortKey', value: value),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  sortKeyGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sortKey',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  sortKeyLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sortKey',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  sortKeyBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sortKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  thumbnailUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'thumbnailUrl'),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  thumbnailUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'thumbnailUrl'),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  thumbnailUrlEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'thumbnailUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  thumbnailUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'thumbnailUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  thumbnailUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'thumbnailUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  thumbnailUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'thumbnailUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  thumbnailUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'thumbnailUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  thumbnailUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'thumbnailUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  thumbnailUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'thumbnailUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  thumbnailUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'thumbnailUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  thumbnailUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'thumbnailUrl', value: ''),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  thumbnailUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'thumbnailUrl', value: ''),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  yearGroupedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'yearGrouped', value: value),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  yearHeaderModeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'yearHeaderMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  yearHeaderModeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'yearHeaderMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  yearHeaderModeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'yearHeaderMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  yearHeaderModeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'yearHeaderMode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  yearHeaderModeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'yearHeaderMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  yearHeaderModeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'yearHeaderMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  yearHeaderModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'yearHeaderMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  yearHeaderModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'yearHeaderMode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  yearHeaderModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'yearHeaderMode', value: ''),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  yearHeaderModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'yearHeaderMode', value: ''),
      );
    });
  }
}

extension SmartPlaylistEntityQueryObject
    on
        QueryBuilder<
          SmartPlaylistEntity,
          SmartPlaylistEntity,
          QFilterCondition
        > {}

extension SmartPlaylistEntityQueryLinks
    on
        QueryBuilder<
          SmartPlaylistEntity,
          SmartPlaylistEntity,
          QFilterCondition
        > {}

extension SmartPlaylistEntityQuerySortBy
    on QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QSortBy> {
  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByPlaylistNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistNumber', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByPlaylistNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistNumber', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByPlaylistStructure() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistStructure', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByPlaylistStructureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistStructure', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByPodcastIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByResolverType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resolverType', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByResolverTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resolverType', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortBySortKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortKey', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortBySortKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortKey', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByThumbnailUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByThumbnailUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByYearGrouped() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearGrouped', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByYearGroupedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearGrouped', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByYearHeaderMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearHeaderMode', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByYearHeaderModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearHeaderMode', Sort.desc);
    });
  }
}

extension SmartPlaylistEntityQuerySortThenBy
    on QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QSortThenBy> {
  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByPlaylistNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistNumber', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByPlaylistNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistNumber', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByPlaylistStructure() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistStructure', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByPlaylistStructureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistStructure', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByPodcastIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByResolverType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resolverType', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByResolverTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resolverType', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenBySortKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortKey', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenBySortKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortKey', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByThumbnailUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByThumbnailUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByYearGrouped() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearGrouped', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByYearGroupedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearGrouped', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByYearHeaderMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearHeaderMode', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByYearHeaderModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearHeaderMode', Sort.desc);
    });
  }
}

extension SmartPlaylistEntityQueryWhereDistinct
    on QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QDistinct> {
  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QDistinct>
  distinctByDisplayName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QDistinct>
  distinctByPlaylistNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playlistNumber');
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QDistinct>
  distinctByPlaylistStructure({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'playlistStructure',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QDistinct>
  distinctByPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'podcastId');
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QDistinct>
  distinctByResolverType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'resolverType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QDistinct>
  distinctBySortKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortKey');
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QDistinct>
  distinctByThumbnailUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'thumbnailUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QDistinct>
  distinctByYearGrouped() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'yearGrouped');
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QDistinct>
  distinctByYearHeaderMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'yearHeaderMode',
        caseSensitive: caseSensitive,
      );
    });
  }
}

extension SmartPlaylistEntityQueryProperty
    on QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QQueryProperty> {
  QueryBuilder<SmartPlaylistEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SmartPlaylistEntity, String, QQueryOperations>
  displayNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayName');
    });
  }

  QueryBuilder<SmartPlaylistEntity, int, QQueryOperations>
  playlistNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playlistNumber');
    });
  }

  QueryBuilder<SmartPlaylistEntity, String, QQueryOperations>
  playlistStructureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playlistStructure');
    });
  }

  QueryBuilder<SmartPlaylistEntity, int, QQueryOperations> podcastIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'podcastId');
    });
  }

  QueryBuilder<SmartPlaylistEntity, String, QQueryOperations>
  resolverTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resolverType');
    });
  }

  QueryBuilder<SmartPlaylistEntity, int, QQueryOperations> sortKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortKey');
    });
  }

  QueryBuilder<SmartPlaylistEntity, String?, QQueryOperations>
  thumbnailUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'thumbnailUrl');
    });
  }

  QueryBuilder<SmartPlaylistEntity, bool, QQueryOperations>
  yearGroupedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'yearGrouped');
    });
  }

  QueryBuilder<SmartPlaylistEntity, String, QQueryOperations>
  yearHeaderModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'yearHeaderMode');
    });
  }
}
