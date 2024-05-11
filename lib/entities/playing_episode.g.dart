// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, duplicate_ignore

part of 'playing_episode.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlayingEpisodeCollection on Isar {
  IsarCollection<PlayingEpisode> get playingEpisodes => this.collection();
}

const PlayingEpisodeSchema = CollectionSchema(
  name: r'PlayingEpisode',
  id: -2689448002255430747,
  properties: {
    r'eid': PropertySchema(
      id: 0,
      name: r'eid',
      type: IsarType.long,
    )
  },
  estimateSize: _playingEpisodeEstimateSize,
  serialize: _playingEpisodeSerialize,
  deserialize: _playingEpisodeDeserialize,
  deserializeProp: _playingEpisodeDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _playingEpisodeGetId,
  getLinks: _playingEpisodeGetLinks,
  attach: _playingEpisodeAttach,
  version: '3.1.0+1',
);

int _playingEpisodeEstimateSize(
  PlayingEpisode object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _playingEpisodeSerialize(
  PlayingEpisode object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.eid);
}

PlayingEpisode _playingEpisodeDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlayingEpisode(
    eid: reader.readLongOrNull(offsets[0]),
  );
  return object;
}

P _playingEpisodeDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _playingEpisodeGetId(PlayingEpisode object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _playingEpisodeGetLinks(PlayingEpisode object) {
  return [];
}

void _playingEpisodeAttach(
    IsarCollection<dynamic> col, Id id, PlayingEpisode object) {}

extension PlayingEpisodeQueryWhereSort
    on QueryBuilder<PlayingEpisode, PlayingEpisode, QWhere> {
  QueryBuilder<PlayingEpisode, PlayingEpisode, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PlayingEpisodeQueryWhere
    on QueryBuilder<PlayingEpisode, PlayingEpisode, QWhereClause> {
  QueryBuilder<PlayingEpisode, PlayingEpisode, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PlayingEpisode, PlayingEpisode, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<PlayingEpisode, PlayingEpisode, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PlayingEpisode, PlayingEpisode, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PlayingEpisode, PlayingEpisode, QAfterWhereClause> idBetween(
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

extension PlayingEpisodeQueryFilter
    on QueryBuilder<PlayingEpisode, PlayingEpisode, QFilterCondition> {
  QueryBuilder<PlayingEpisode, PlayingEpisode, QAfterFilterCondition>
      eidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'eid',
      ));
    });
  }

  QueryBuilder<PlayingEpisode, PlayingEpisode, QAfterFilterCondition>
      eidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'eid',
      ));
    });
  }

  QueryBuilder<PlayingEpisode, PlayingEpisode, QAfterFilterCondition>
      eidEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eid',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayingEpisode, PlayingEpisode, QAfterFilterCondition>
      eidGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'eid',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayingEpisode, PlayingEpisode, QAfterFilterCondition>
      eidLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'eid',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayingEpisode, PlayingEpisode, QAfterFilterCondition>
      eidBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'eid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlayingEpisode, PlayingEpisode, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayingEpisode, PlayingEpisode, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<PlayingEpisode, PlayingEpisode, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<PlayingEpisode, PlayingEpisode, QAfterFilterCondition> idBetween(
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

extension PlayingEpisodeQueryObject
    on QueryBuilder<PlayingEpisode, PlayingEpisode, QFilterCondition> {}

extension PlayingEpisodeQueryLinks
    on QueryBuilder<PlayingEpisode, PlayingEpisode, QFilterCondition> {}

extension PlayingEpisodeQuerySortBy
    on QueryBuilder<PlayingEpisode, PlayingEpisode, QSortBy> {
  QueryBuilder<PlayingEpisode, PlayingEpisode, QAfterSortBy> sortByEid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eid', Sort.asc);
    });
  }

  QueryBuilder<PlayingEpisode, PlayingEpisode, QAfterSortBy> sortByEidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eid', Sort.desc);
    });
  }
}

extension PlayingEpisodeQuerySortThenBy
    on QueryBuilder<PlayingEpisode, PlayingEpisode, QSortThenBy> {
  QueryBuilder<PlayingEpisode, PlayingEpisode, QAfterSortBy> thenByEid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eid', Sort.asc);
    });
  }

  QueryBuilder<PlayingEpisode, PlayingEpisode, QAfterSortBy> thenByEidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eid', Sort.desc);
    });
  }

  QueryBuilder<PlayingEpisode, PlayingEpisode, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PlayingEpisode, PlayingEpisode, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension PlayingEpisodeQueryWhereDistinct
    on QueryBuilder<PlayingEpisode, PlayingEpisode, QDistinct> {
  QueryBuilder<PlayingEpisode, PlayingEpisode, QDistinct> distinctByEid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eid');
    });
  }
}

extension PlayingEpisodeQueryProperty
    on QueryBuilder<PlayingEpisode, PlayingEpisode, QQueryProperty> {
  QueryBuilder<PlayingEpisode, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlayingEpisode, int?, QQueryOperations> eidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eid');
    });
  }
}
