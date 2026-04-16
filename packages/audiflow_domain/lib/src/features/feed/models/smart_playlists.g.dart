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
    r'configVersion': PropertySchema(
      id: 0,
      name: r'configVersion',
      type: IsarType.long,
    ),
    r'displayName': PropertySchema(
      id: 1,
      name: r'displayName',
      type: IsarType.string,
    ),
    r'episodeSortField': PropertySchema(
      id: 2,
      name: r'episodeSortField',
      type: IsarType.string,
    ),
    r'episodeSortOrder': PropertySchema(
      id: 3,
      name: r'episodeSortOrder',
      type: IsarType.string,
    ),
    r'groupSortField': PropertySchema(
      id: 4,
      name: r'groupSortField',
      type: IsarType.string,
    ),
    r'groupSortOrder': PropertySchema(
      id: 5,
      name: r'groupSortOrder',
      type: IsarType.string,
    ),
    r'playlistId': PropertySchema(
      id: 6,
      name: r'playlistId',
      type: IsarType.string,
    ),
    r'playlistNumber': PropertySchema(
      id: 7,
      name: r'playlistNumber',
      type: IsarType.long,
    ),
    r'playlistStructure': PropertySchema(
      id: 8,
      name: r'playlistStructure',
      type: IsarType.string,
    ),
    r'podcastId': PropertySchema(
      id: 9,
      name: r'podcastId',
      type: IsarType.long,
    ),
    r'prependSeasonNumber': PropertySchema(
      id: 10,
      name: r'prependSeasonNumber',
      type: IsarType.bool,
    ),
    r'resolverType': PropertySchema(
      id: 11,
      name: r'resolverType',
      type: IsarType.string,
    ),
    r'showDateRange': PropertySchema(
      id: 12,
      name: r'showDateRange',
      type: IsarType.bool,
    ),
    r'showYearHeaders': PropertySchema(
      id: 13,
      name: r'showYearHeaders',
      type: IsarType.bool,
    ),
    r'sortKey': PropertySchema(id: 14, name: r'sortKey', type: IsarType.long),
    r'thumbnailUrl': PropertySchema(
      id: 15,
      name: r'thumbnailUrl',
      type: IsarType.string,
    ),
    r'userSortable': PropertySchema(
      id: 16,
      name: r'userSortable',
      type: IsarType.bool,
    ),
    r'yearGrouped': PropertySchema(
      id: 17,
      name: r'yearGrouped',
      type: IsarType.bool,
    ),
    r'yearHeaderMode': PropertySchema(
      id: 18,
      name: r'yearHeaderMode',
      type: IsarType.string,
    ),
    r'zHeuristicVersion': PropertySchema(
      id: 19,
      name: r'zHeuristicVersion',
      type: IsarType.long,
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
  version: '3.3.2',
);

int _smartPlaylistEntityEstimateSize(
  SmartPlaylistEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.displayName.length * 3;
  {
    final value = object.episodeSortField;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.episodeSortOrder;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.groupSortField;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.groupSortOrder;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.playlistId.length * 3;
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
  writer.writeLong(offsets[0], object.configVersion);
  writer.writeString(offsets[1], object.displayName);
  writer.writeString(offsets[2], object.episodeSortField);
  writer.writeString(offsets[3], object.episodeSortOrder);
  writer.writeString(offsets[4], object.groupSortField);
  writer.writeString(offsets[5], object.groupSortOrder);
  writer.writeString(offsets[6], object.playlistId);
  writer.writeLong(offsets[7], object.playlistNumber);
  writer.writeString(offsets[8], object.playlistStructure);
  writer.writeLong(offsets[9], object.podcastId);
  writer.writeBool(offsets[10], object.prependSeasonNumber);
  writer.writeString(offsets[11], object.resolverType);
  writer.writeBool(offsets[12], object.showDateRange);
  writer.writeBool(offsets[13], object.showYearHeaders);
  writer.writeLong(offsets[14], object.sortKey);
  writer.writeString(offsets[15], object.thumbnailUrl);
  writer.writeBool(offsets[16], object.userSortable);
  writer.writeBool(offsets[17], object.yearGrouped);
  writer.writeString(offsets[18], object.yearHeaderMode);
  writer.writeLong(offsets[19], object.heuristicVersion);
}

SmartPlaylistEntity _smartPlaylistEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SmartPlaylistEntity();
  object.configVersion = reader.readLongOrNull(offsets[0]);
  object.displayName = reader.readString(offsets[1]);
  object.episodeSortField = reader.readStringOrNull(offsets[2]);
  object.episodeSortOrder = reader.readStringOrNull(offsets[3]);
  object.groupSortField = reader.readStringOrNull(offsets[4]);
  object.groupSortOrder = reader.readStringOrNull(offsets[5]);
  object.id = id;
  object.playlistId = reader.readString(offsets[6]);
  object.playlistNumber = reader.readLong(offsets[7]);
  object.playlistStructure = reader.readString(offsets[8]);
  object.podcastId = reader.readLong(offsets[9]);
  object.prependSeasonNumber = reader.readBool(offsets[10]);
  object.resolverType = reader.readString(offsets[11]);
  object.showDateRange = reader.readBool(offsets[12]);
  object.showYearHeaders = reader.readBool(offsets[13]);
  object.sortKey = reader.readLong(offsets[14]);
  object.thumbnailUrl = reader.readStringOrNull(offsets[15]);
  object.userSortable = reader.readBool(offsets[16]);
  object.yearGrouped = reader.readBool(offsets[17]);
  object.yearHeaderMode = reader.readString(offsets[18]);
  object.heuristicVersion = reader.readLongOrNull(offsets[19]);
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
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readBool(offset)) as P;
    case 17:
      return (reader.readBool(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readLongOrNull(offset)) as P;
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
  configVersionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'configVersion'),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  configVersionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'configVersion'),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  configVersionEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'configVersion', value: value),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  configVersionGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'configVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  configVersionLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'configVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  configVersionBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'configVersion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

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
  episodeSortFieldIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'episodeSortField'),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  episodeSortFieldIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'episodeSortField'),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  episodeSortFieldEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'episodeSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  episodeSortFieldGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'episodeSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  episodeSortFieldLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'episodeSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  episodeSortFieldBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'episodeSortField',
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
  episodeSortFieldStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'episodeSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  episodeSortFieldEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'episodeSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  episodeSortFieldContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'episodeSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  episodeSortFieldMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'episodeSortField',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  episodeSortFieldIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeSortField', value: ''),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  episodeSortFieldIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'episodeSortField', value: ''),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  episodeSortOrderIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'episodeSortOrder'),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  episodeSortOrderIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'episodeSortOrder'),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  episodeSortOrderEqualTo(String? value, {bool caseSensitive = true}) {
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  episodeSortOrderGreaterThan(
    String? value, {
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  episodeSortOrderLessThan(
    String? value, {
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  episodeSortOrderBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  episodeSortOrderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeSortOrder', value: ''),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  episodeSortOrderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'episodeSortOrder', value: ''),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  groupSortFieldIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'groupSortField'),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  groupSortFieldIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'groupSortField'),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  groupSortFieldEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'groupSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  groupSortFieldGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'groupSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  groupSortFieldLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'groupSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  groupSortFieldBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'groupSortField',
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
  groupSortFieldStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'groupSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  groupSortFieldEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'groupSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  groupSortFieldContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'groupSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  groupSortFieldMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'groupSortField',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  groupSortFieldIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'groupSortField', value: ''),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  groupSortFieldIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'groupSortField', value: ''),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  groupSortOrderIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'groupSortOrder'),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  groupSortOrderIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'groupSortOrder'),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  groupSortOrderEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'groupSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  groupSortOrderGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'groupSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  groupSortOrderLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'groupSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  groupSortOrderBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'groupSortOrder',
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
  groupSortOrderStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'groupSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  groupSortOrderEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'groupSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  groupSortOrderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'groupSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  groupSortOrderMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'groupSortOrder',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  groupSortOrderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'groupSortOrder', value: ''),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  groupSortOrderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'groupSortOrder', value: ''),
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  playlistIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'playlistId', value: ''),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  playlistIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'playlistId', value: ''),
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
  prependSeasonNumberEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'prependSeasonNumber', value: value),
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
  showDateRangeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'showDateRange', value: value),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  showYearHeadersEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'showYearHeaders', value: value),
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
  userSortableEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'userSortable', value: value),
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  heuristicVersionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'zHeuristicVersion'),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  heuristicVersionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'zHeuristicVersion'),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  heuristicVersionEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'zHeuristicVersion', value: value),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  heuristicVersionGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'zHeuristicVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  heuristicVersionLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'zHeuristicVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterFilterCondition>
  heuristicVersionBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'zHeuristicVersion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
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
  sortByConfigVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configVersion', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByConfigVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configVersion', Sort.desc);
    });
  }

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
  sortByEpisodeSortField() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortField', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByEpisodeSortFieldDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortField', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByEpisodeSortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortOrder', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByEpisodeSortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortOrder', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByGroupSortField() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupSortField', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByGroupSortFieldDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupSortField', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByGroupSortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupSortOrder', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByGroupSortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupSortOrder', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByPlaylistId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByPlaylistIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.desc);
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
  sortByPrependSeasonNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prependSeasonNumber', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByPrependSeasonNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prependSeasonNumber', Sort.desc);
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
  sortByShowDateRange() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showDateRange', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByShowDateRangeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showDateRange', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByShowYearHeaders() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showYearHeaders', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByShowYearHeadersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showYearHeaders', Sort.desc);
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
  sortByUserSortable() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userSortable', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByUserSortableDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userSortable', Sort.desc);
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByHeuristicVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zHeuristicVersion', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  sortByHeuristicVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zHeuristicVersion', Sort.desc);
    });
  }
}

extension SmartPlaylistEntityQuerySortThenBy
    on QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QSortThenBy> {
  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByConfigVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configVersion', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByConfigVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configVersion', Sort.desc);
    });
  }

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
  thenByEpisodeSortField() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortField', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByEpisodeSortFieldDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortField', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByEpisodeSortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortOrder', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByEpisodeSortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortOrder', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByGroupSortField() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupSortField', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByGroupSortFieldDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupSortField', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByGroupSortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupSortOrder', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByGroupSortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupSortOrder', Sort.desc);
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
  thenByPlaylistId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByPlaylistIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.desc);
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
  thenByPrependSeasonNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prependSeasonNumber', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByPrependSeasonNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prependSeasonNumber', Sort.desc);
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
  thenByShowDateRange() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showDateRange', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByShowDateRangeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showDateRange', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByShowYearHeaders() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showYearHeaders', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByShowYearHeadersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showYearHeaders', Sort.desc);
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
  thenByUserSortable() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userSortable', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByUserSortableDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userSortable', Sort.desc);
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByHeuristicVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zHeuristicVersion', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QAfterSortBy>
  thenByHeuristicVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zHeuristicVersion', Sort.desc);
    });
  }
}

extension SmartPlaylistEntityQueryWhereDistinct
    on QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QDistinct> {
  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QDistinct>
  distinctByConfigVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'configVersion');
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QDistinct>
  distinctByDisplayName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QDistinct>
  distinctByEpisodeSortField({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'episodeSortField',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QDistinct>
  distinctByEpisodeSortOrder({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'episodeSortOrder',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QDistinct>
  distinctByGroupSortField({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'groupSortField',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QDistinct>
  distinctByGroupSortOrder({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'groupSortOrder',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QDistinct>
  distinctByPlaylistId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playlistId', caseSensitive: caseSensitive);
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
  distinctByPrependSeasonNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'prependSeasonNumber');
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QDistinct>
  distinctByResolverType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'resolverType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QDistinct>
  distinctByShowDateRange() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showDateRange');
    });
  }

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QDistinct>
  distinctByShowYearHeaders() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showYearHeaders');
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
  distinctByUserSortable() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userSortable');
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

  QueryBuilder<SmartPlaylistEntity, SmartPlaylistEntity, QDistinct>
  distinctByHeuristicVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'zHeuristicVersion');
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

  QueryBuilder<SmartPlaylistEntity, int?, QQueryOperations>
  configVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'configVersion');
    });
  }

  QueryBuilder<SmartPlaylistEntity, String, QQueryOperations>
  displayNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayName');
    });
  }

  QueryBuilder<SmartPlaylistEntity, String?, QQueryOperations>
  episodeSortFieldProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeSortField');
    });
  }

  QueryBuilder<SmartPlaylistEntity, String?, QQueryOperations>
  episodeSortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeSortOrder');
    });
  }

  QueryBuilder<SmartPlaylistEntity, String?, QQueryOperations>
  groupSortFieldProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'groupSortField');
    });
  }

  QueryBuilder<SmartPlaylistEntity, String?, QQueryOperations>
  groupSortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'groupSortOrder');
    });
  }

  QueryBuilder<SmartPlaylistEntity, String, QQueryOperations>
  playlistIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playlistId');
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

  QueryBuilder<SmartPlaylistEntity, bool, QQueryOperations>
  prependSeasonNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'prependSeasonNumber');
    });
  }

  QueryBuilder<SmartPlaylistEntity, String, QQueryOperations>
  resolverTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resolverType');
    });
  }

  QueryBuilder<SmartPlaylistEntity, bool, QQueryOperations>
  showDateRangeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showDateRange');
    });
  }

  QueryBuilder<SmartPlaylistEntity, bool, QQueryOperations>
  showYearHeadersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showYearHeaders');
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
  userSortableProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userSortable');
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

  QueryBuilder<SmartPlaylistEntity, int?, QQueryOperations>
  heuristicVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'zHeuristicVersion');
    });
  }
}
