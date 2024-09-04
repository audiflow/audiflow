// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSeasonCollection on Isar {
  IsarCollection<Season> get seasons => this.collection();
}

const SeasonSchema = CollectionSchema(
  name: r'Season',
  id: 7798637676833157862,
  properties: {
    r'episodeIds': PropertySchema(
      id: 0,
      name: r'episodeIds',
      type: IsarType.longList,
    ),
    r'firstPublicationDate': PropertySchema(
      id: 1,
      name: r'firstPublicationDate',
      type: IsarType.dateTime,
    ),
    r'guid': PropertySchema(
      id: 2,
      name: r'guid',
      type: IsarType.string,
    ),
    r'imageUrl': PropertySchema(
      id: 3,
      name: r'imageUrl',
      type: IsarType.string,
    ),
    r'latestPublicationDate': PropertySchema(
      id: 4,
      name: r'latestPublicationDate',
      type: IsarType.dateTime,
    ),
    r'pid': PropertySchema(
      id: 5,
      name: r'pid',
      type: IsarType.long,
    ),
    r'seasonNum': PropertySchema(
      id: 6,
      name: r'seasonNum',
      type: IsarType.long,
    ),
    r'title': PropertySchema(
      id: 7,
      name: r'title',
      type: IsarType.string,
    ),
    r'totalDurationMS': PropertySchema(
      id: 8,
      name: r'totalDurationMS',
      type: IsarType.long,
    )
  },
  estimateSize: _seasonEstimateSize,
  serialize: _seasonSerialize,
  deserialize: _seasonDeserialize,
  deserializeProp: _seasonDeserializeProp,
  idName: r'id',
  indexes: {
    r'pid': IndexSchema(
      id: 2970402811525951487,
      name: r'pid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'pid',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'seasonNum': IndexSchema(
      id: -1172615417979280991,
      name: r'seasonNum',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'seasonNum',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'firstPublicationDate': IndexSchema(
      id: 1198948471628739562,
      name: r'firstPublicationDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'firstPublicationDate',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'latestPublicationDate': IndexSchema(
      id: -8044242539089769840,
      name: r'latestPublicationDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'latestPublicationDate',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _seasonGetId,
  getLinks: _seasonGetLinks,
  attach: _seasonAttach,
  version: '3.1.7',
);

int _seasonEstimateSize(
  Season object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.episodeIds.length * 8;
  bytesCount += 3 + object.guid.length * 3;
  {
    final value = object.imageUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.title;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _seasonSerialize(
  Season object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLongList(offsets[0], object.episodeIds);
  writer.writeDateTime(offsets[1], object.firstPublicationDate);
  writer.writeString(offsets[2], object.guid);
  writer.writeString(offsets[3], object.imageUrl);
  writer.writeDateTime(offsets[4], object.latestPublicationDate);
  writer.writeLong(offsets[5], object.pid);
  writer.writeLong(offsets[6], object.seasonNum);
  writer.writeString(offsets[7], object.title);
  writer.writeLong(offsets[8], object.totalDurationMS);
}

Season _seasonDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Season(
    episodeIds: reader.readLongList(offsets[0]) ?? [],
    firstPublicationDate: reader.readDateTimeOrNull(offsets[1]),
    guid: reader.readString(offsets[2]),
    imageUrl: reader.readStringOrNull(offsets[3]),
    latestPublicationDate: reader.readDateTimeOrNull(offsets[4]),
    pid: reader.readLong(offsets[5]),
    seasonNum: reader.readLongOrNull(offsets[6]),
    title: reader.readStringOrNull(offsets[7]),
    totalDurationMS: reader.readLong(offsets[8]),
  );
  return object;
}

P _seasonDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongList(offset) ?? []) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _seasonGetId(Season object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _seasonGetLinks(Season object) {
  return [];
}

void _seasonAttach(IsarCollection<dynamic> col, Id id, Season object) {}

extension SeasonQueryWhereSort on QueryBuilder<Season, Season, QWhere> {
  QueryBuilder<Season, Season, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Season, Season, QAfterWhere> anyPid() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'pid'),
      );
    });
  }

  QueryBuilder<Season, Season, QAfterWhere> anySeasonNum() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'seasonNum'),
      );
    });
  }

  QueryBuilder<Season, Season, QAfterWhere> anyFirstPublicationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'firstPublicationDate'),
      );
    });
  }

  QueryBuilder<Season, Season, QAfterWhere> anyLatestPublicationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'latestPublicationDate'),
      );
    });
  }
}

extension SeasonQueryWhere on QueryBuilder<Season, Season, QWhereClause> {
  QueryBuilder<Season, Season, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Season, Season, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause> pidEqualTo(int pid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pid',
        value: [pid],
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause> pidNotEqualTo(int pid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pid',
              lower: [],
              upper: [pid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pid',
              lower: [pid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pid',
              lower: [pid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pid',
              lower: [],
              upper: [pid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause> pidGreaterThan(
    int pid, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'pid',
        lower: [pid],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause> pidLessThan(
    int pid, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'pid',
        lower: [],
        upper: [pid],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause> pidBetween(
    int lowerPid,
    int upperPid, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'pid',
        lower: [lowerPid],
        includeLower: includeLower,
        upper: [upperPid],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause> seasonNumIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'seasonNum',
        value: [null],
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause> seasonNumIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'seasonNum',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause> seasonNumEqualTo(
      int? seasonNum) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'seasonNum',
        value: [seasonNum],
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause> seasonNumNotEqualTo(
      int? seasonNum) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'seasonNum',
              lower: [],
              upper: [seasonNum],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'seasonNum',
              lower: [seasonNum],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'seasonNum',
              lower: [seasonNum],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'seasonNum',
              lower: [],
              upper: [seasonNum],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause> seasonNumGreaterThan(
    int? seasonNum, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'seasonNum',
        lower: [seasonNum],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause> seasonNumLessThan(
    int? seasonNum, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'seasonNum',
        lower: [],
        upper: [seasonNum],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause> seasonNumBetween(
    int? lowerSeasonNum,
    int? upperSeasonNum, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'seasonNum',
        lower: [lowerSeasonNum],
        includeLower: includeLower,
        upper: [upperSeasonNum],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause> firstPublicationDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'firstPublicationDate',
        value: [null],
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause>
      firstPublicationDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'firstPublicationDate',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause> firstPublicationDateEqualTo(
      DateTime? firstPublicationDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'firstPublicationDate',
        value: [firstPublicationDate],
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause>
      firstPublicationDateNotEqualTo(DateTime? firstPublicationDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'firstPublicationDate',
              lower: [],
              upper: [firstPublicationDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'firstPublicationDate',
              lower: [firstPublicationDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'firstPublicationDate',
              lower: [firstPublicationDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'firstPublicationDate',
              lower: [],
              upper: [firstPublicationDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause>
      firstPublicationDateGreaterThan(
    DateTime? firstPublicationDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'firstPublicationDate',
        lower: [firstPublicationDate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause> firstPublicationDateLessThan(
    DateTime? firstPublicationDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'firstPublicationDate',
        lower: [],
        upper: [firstPublicationDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause> firstPublicationDateBetween(
    DateTime? lowerFirstPublicationDate,
    DateTime? upperFirstPublicationDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'firstPublicationDate',
        lower: [lowerFirstPublicationDate],
        includeLower: includeLower,
        upper: [upperFirstPublicationDate],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause>
      latestPublicationDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'latestPublicationDate',
        value: [null],
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause>
      latestPublicationDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'latestPublicationDate',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause> latestPublicationDateEqualTo(
      DateTime? latestPublicationDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'latestPublicationDate',
        value: [latestPublicationDate],
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause>
      latestPublicationDateNotEqualTo(DateTime? latestPublicationDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'latestPublicationDate',
              lower: [],
              upper: [latestPublicationDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'latestPublicationDate',
              lower: [latestPublicationDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'latestPublicationDate',
              lower: [latestPublicationDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'latestPublicationDate',
              lower: [],
              upper: [latestPublicationDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause>
      latestPublicationDateGreaterThan(
    DateTime? latestPublicationDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'latestPublicationDate',
        lower: [latestPublicationDate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause> latestPublicationDateLessThan(
    DateTime? latestPublicationDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'latestPublicationDate',
        lower: [],
        upper: [latestPublicationDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterWhereClause> latestPublicationDateBetween(
    DateTime? lowerLatestPublicationDate,
    DateTime? upperLatestPublicationDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'latestPublicationDate',
        lower: [lowerLatestPublicationDate],
        includeLower: includeLower,
        upper: [upperLatestPublicationDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SeasonQueryFilter on QueryBuilder<Season, Season, QFilterCondition> {
  QueryBuilder<Season, Season, QAfterFilterCondition> episodeIdsElementEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'episodeIds',
        value: value,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition>
      episodeIdsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'episodeIds',
        value: value,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> episodeIdsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'episodeIds',
        value: value,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> episodeIdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'episodeIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> episodeIdsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'episodeIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> episodeIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'episodeIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> episodeIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'episodeIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> episodeIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'episodeIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition>
      episodeIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'episodeIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> episodeIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'episodeIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition>
      firstPublicationDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'firstPublicationDate',
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition>
      firstPublicationDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'firstPublicationDate',
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition>
      firstPublicationDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'firstPublicationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition>
      firstPublicationDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'firstPublicationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition>
      firstPublicationDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'firstPublicationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition>
      firstPublicationDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'firstPublicationDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> guidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> guidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> guidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> guidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'guid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> guidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> guidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> guidContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> guidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'guid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> guidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'guid',
        value: '',
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> guidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'guid',
        value: '',
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> imageUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imageUrl',
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> imageUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imageUrl',
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> imageUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> imageUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> imageUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> imageUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imageUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> imageUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> imageUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> imageUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> imageUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imageUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> imageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> imageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition>
      latestPublicationDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'latestPublicationDate',
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition>
      latestPublicationDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'latestPublicationDate',
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition>
      latestPublicationDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'latestPublicationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition>
      latestPublicationDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'latestPublicationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition>
      latestPublicationDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'latestPublicationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition>
      latestPublicationDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'latestPublicationDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> pidEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pid',
        value: value,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> pidGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pid',
        value: value,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> pidLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pid',
        value: value,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> pidBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> seasonNumIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'seasonNum',
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> seasonNumIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'seasonNum',
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> seasonNumEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'seasonNum',
        value: value,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> seasonNumGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'seasonNum',
        value: value,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> seasonNumLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'seasonNum',
        value: value,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> seasonNumBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'seasonNum',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> titleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> titleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> titleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> titleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> totalDurationMSEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalDurationMS',
        value: value,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition>
      totalDurationMSGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalDurationMS',
        value: value,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> totalDurationMSLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalDurationMS',
        value: value,
      ));
    });
  }

  QueryBuilder<Season, Season, QAfterFilterCondition> totalDurationMSBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalDurationMS',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SeasonQueryObject on QueryBuilder<Season, Season, QFilterCondition> {}

extension SeasonQueryLinks on QueryBuilder<Season, Season, QFilterCondition> {}

extension SeasonQuerySortBy on QueryBuilder<Season, Season, QSortBy> {
  QueryBuilder<Season, Season, QAfterSortBy> sortByFirstPublicationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstPublicationDate', Sort.asc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> sortByFirstPublicationDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstPublicationDate', Sort.desc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> sortByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.asc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> sortByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.desc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> sortByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> sortByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> sortByLatestPublicationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latestPublicationDate', Sort.asc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> sortByLatestPublicationDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latestPublicationDate', Sort.desc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> sortByPid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pid', Sort.asc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> sortByPidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pid', Sort.desc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> sortBySeasonNum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonNum', Sort.asc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> sortBySeasonNumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonNum', Sort.desc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> sortByTotalDurationMS() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDurationMS', Sort.asc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> sortByTotalDurationMSDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDurationMS', Sort.desc);
    });
  }
}

extension SeasonQuerySortThenBy on QueryBuilder<Season, Season, QSortThenBy> {
  QueryBuilder<Season, Season, QAfterSortBy> thenByFirstPublicationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstPublicationDate', Sort.asc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> thenByFirstPublicationDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstPublicationDate', Sort.desc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> thenByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.asc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> thenByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.desc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> thenByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> thenByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> thenByLatestPublicationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latestPublicationDate', Sort.asc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> thenByLatestPublicationDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latestPublicationDate', Sort.desc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> thenByPid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pid', Sort.asc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> thenByPidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pid', Sort.desc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> thenBySeasonNum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonNum', Sort.asc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> thenBySeasonNumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonNum', Sort.desc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> thenByTotalDurationMS() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDurationMS', Sort.asc);
    });
  }

  QueryBuilder<Season, Season, QAfterSortBy> thenByTotalDurationMSDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDurationMS', Sort.desc);
    });
  }
}

extension SeasonQueryWhereDistinct on QueryBuilder<Season, Season, QDistinct> {
  QueryBuilder<Season, Season, QDistinct> distinctByEpisodeIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'episodeIds');
    });
  }

  QueryBuilder<Season, Season, QDistinct> distinctByFirstPublicationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'firstPublicationDate');
    });
  }

  QueryBuilder<Season, Season, QDistinct> distinctByGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'guid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Season, Season, QDistinct> distinctByImageUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imageUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Season, Season, QDistinct> distinctByLatestPublicationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latestPublicationDate');
    });
  }

  QueryBuilder<Season, Season, QDistinct> distinctByPid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pid');
    });
  }

  QueryBuilder<Season, Season, QDistinct> distinctBySeasonNum() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'seasonNum');
    });
  }

  QueryBuilder<Season, Season, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Season, Season, QDistinct> distinctByTotalDurationMS() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalDurationMS');
    });
  }
}

extension SeasonQueryProperty on QueryBuilder<Season, Season, QQueryProperty> {
  QueryBuilder<Season, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Season, List<int>, QQueryOperations> episodeIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeIds');
    });
  }

  QueryBuilder<Season, DateTime?, QQueryOperations>
      firstPublicationDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firstPublicationDate');
    });
  }

  QueryBuilder<Season, String, QQueryOperations> guidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'guid');
    });
  }

  QueryBuilder<Season, String?, QQueryOperations> imageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imageUrl');
    });
  }

  QueryBuilder<Season, DateTime?, QQueryOperations>
      latestPublicationDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latestPublicationDate');
    });
  }

  QueryBuilder<Season, int, QQueryOperations> pidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pid');
    });
  }

  QueryBuilder<Season, int?, QQueryOperations> seasonNumProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seasonNum');
    });
  }

  QueryBuilder<Season, String?, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<Season, int, QQueryOperations> totalDurationMSProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalDurationMS');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSeasonStatsCollection on Isar {
  IsarCollection<SeasonStats> get seasonStats => this.collection();
}

const SeasonStatsSchema = CollectionSchema(
  name: r'SeasonStats',
  id: -355638763968639406,
  properties: {
    r'completedEpisodeIds': PropertySchema(
      id: 0,
      name: r'completedEpisodeIds',
      type: IsarType.longList,
    )
  },
  estimateSize: _seasonStatsEstimateSize,
  serialize: _seasonStatsSerialize,
  deserialize: _seasonStatsDeserialize,
  deserializeProp: _seasonStatsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _seasonStatsGetId,
  getLinks: _seasonStatsGetLinks,
  attach: _seasonStatsAttach,
  version: '3.1.7',
);

int _seasonStatsEstimateSize(
  SeasonStats object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.completedEpisodeIds.length * 8;
  return bytesCount;
}

void _seasonStatsSerialize(
  SeasonStats object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLongList(offsets[0], object.completedEpisodeIds);
}

SeasonStats _seasonStatsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SeasonStats(
    completedEpisodeIds: reader.readLongList(offsets[0]) ?? [],
    id: id,
  );
  return object;
}

P _seasonStatsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _seasonStatsGetId(SeasonStats object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _seasonStatsGetLinks(SeasonStats object) {
  return [];
}

void _seasonStatsAttach(
    IsarCollection<dynamic> col, Id id, SeasonStats object) {}

extension SeasonStatsQueryWhereSort
    on QueryBuilder<SeasonStats, SeasonStats, QWhere> {
  QueryBuilder<SeasonStats, SeasonStats, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SeasonStatsQueryWhere
    on QueryBuilder<SeasonStats, SeasonStats, QWhereClause> {
  QueryBuilder<SeasonStats, SeasonStats, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SeasonStats, SeasonStats, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<SeasonStats, SeasonStats, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SeasonStats, SeasonStats, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SeasonStats, SeasonStats, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SeasonStatsQueryFilter
    on QueryBuilder<SeasonStats, SeasonStats, QFilterCondition> {
  QueryBuilder<SeasonStats, SeasonStats, QAfterFilterCondition>
      completedEpisodeIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedEpisodeIds',
        value: value,
      ));
    });
  }

  QueryBuilder<SeasonStats, SeasonStats, QAfterFilterCondition>
      completedEpisodeIdsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedEpisodeIds',
        value: value,
      ));
    });
  }

  QueryBuilder<SeasonStats, SeasonStats, QAfterFilterCondition>
      completedEpisodeIdsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedEpisodeIds',
        value: value,
      ));
    });
  }

  QueryBuilder<SeasonStats, SeasonStats, QAfterFilterCondition>
      completedEpisodeIdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedEpisodeIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SeasonStats, SeasonStats, QAfterFilterCondition>
      completedEpisodeIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedEpisodeIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SeasonStats, SeasonStats, QAfterFilterCondition>
      completedEpisodeIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedEpisodeIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SeasonStats, SeasonStats, QAfterFilterCondition>
      completedEpisodeIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedEpisodeIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SeasonStats, SeasonStats, QAfterFilterCondition>
      completedEpisodeIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedEpisodeIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SeasonStats, SeasonStats, QAfterFilterCondition>
      completedEpisodeIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedEpisodeIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SeasonStats, SeasonStats, QAfterFilterCondition>
      completedEpisodeIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedEpisodeIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SeasonStats, SeasonStats, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SeasonStats, SeasonStats, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SeasonStats, SeasonStats, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SeasonStats, SeasonStats, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SeasonStatsQueryObject
    on QueryBuilder<SeasonStats, SeasonStats, QFilterCondition> {}

extension SeasonStatsQueryLinks
    on QueryBuilder<SeasonStats, SeasonStats, QFilterCondition> {}

extension SeasonStatsQuerySortBy
    on QueryBuilder<SeasonStats, SeasonStats, QSortBy> {}

extension SeasonStatsQuerySortThenBy
    on QueryBuilder<SeasonStats, SeasonStats, QSortThenBy> {
  QueryBuilder<SeasonStats, SeasonStats, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SeasonStats, SeasonStats, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension SeasonStatsQueryWhereDistinct
    on QueryBuilder<SeasonStats, SeasonStats, QDistinct> {
  QueryBuilder<SeasonStats, SeasonStats, QDistinct>
      distinctByCompletedEpisodeIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedEpisodeIds');
    });
  }
}

extension SeasonStatsQueryProperty
    on QueryBuilder<SeasonStats, SeasonStats, QQueryProperty> {
  QueryBuilder<SeasonStats, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SeasonStats, List<int>, QQueryOperations>
      completedEpisodeIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedEpisodeIds');
    });
  }
}
