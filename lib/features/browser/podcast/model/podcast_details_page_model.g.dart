// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_details_page_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPodcastDetailsPageModelCollection on Isar {
  IsarCollection<PodcastDetailsPageModel> get podcastDetailsPageModels =>
      this.collection();
}

const PodcastDetailsPageModelSchema = CollectionSchema(
  name: r'PodcastDetailsPageModel',
  id: -8447178456850710977,
  properties: {
    r'episodeFilterMode': PropertySchema(
      id: 0,
      name: r'episodeFilterMode',
      type: IsarType.byte,
      enumMap: _PodcastDetailsPageModelepisodeFilterModeEnumValueMap,
    ),
    r'episodesAscending': PropertySchema(
      id: 1,
      name: r'episodesAscending',
      type: IsarType.bool,
    ),
    r'pid': PropertySchema(
      id: 2,
      name: r'pid',
      type: IsarType.long,
    ),
    r'seasonEpisodesAscending': PropertySchema(
      id: 3,
      name: r'seasonEpisodesAscending',
      type: IsarType.bool,
    ),
    r'seasonFilterMode': PropertySchema(
      id: 4,
      name: r'seasonFilterMode',
      type: IsarType.byte,
      enumMap: _PodcastDetailsPageModelseasonFilterModeEnumValueMap,
    ),
    r'seasonsAscending': PropertySchema(
      id: 5,
      name: r'seasonsAscending',
      type: IsarType.bool,
    ),
    r'viewMode': PropertySchema(
      id: 6,
      name: r'viewMode',
      type: IsarType.byte,
      enumMap: _PodcastDetailsPageModelviewModeEnumValueMap,
    )
  },
  estimateSize: _podcastDetailsPageModelEstimateSize,
  serialize: _podcastDetailsPageModelSerialize,
  deserialize: _podcastDetailsPageModelDeserialize,
  deserializeProp: _podcastDetailsPageModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _podcastDetailsPageModelGetId,
  getLinks: _podcastDetailsPageModelGetLinks,
  attach: _podcastDetailsPageModelAttach,
  version: '3.1.7',
);

int _podcastDetailsPageModelEstimateSize(
  PodcastDetailsPageModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _podcastDetailsPageModelSerialize(
  PodcastDetailsPageModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.episodeFilterMode.index);
  writer.writeBool(offsets[1], object.episodesAscending);
  writer.writeLong(offsets[2], object.pid);
  writer.writeBool(offsets[3], object.seasonEpisodesAscending);
  writer.writeByte(offsets[4], object.seasonFilterMode.index);
  writer.writeBool(offsets[5], object.seasonsAscending);
  writer.writeByte(offsets[6], object.viewMode.index);
}

PodcastDetailsPageModel _podcastDetailsPageModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PodcastDetailsPageModel(
    episodeFilterMode: _PodcastDetailsPageModelepisodeFilterModeValueEnumMap[
            reader.readByteOrNull(offsets[0])] ??
        EpisodeFilterMode.all,
    episodesAscending: reader.readBoolOrNull(offsets[1]) ?? false,
    pid: reader.readLong(offsets[2]),
    seasonEpisodesAscending: reader.readBoolOrNull(offsets[3]) ?? true,
    seasonFilterMode: _PodcastDetailsPageModelseasonFilterModeValueEnumMap[
            reader.readByteOrNull(offsets[4])] ??
        SeasonFilterMode.all,
    seasonsAscending: reader.readBoolOrNull(offsets[5]) ?? false,
    viewMode: _PodcastDetailsPageModelviewModeValueEnumMap[
            reader.readByteOrNull(offsets[6])] ??
        PodcastDetailsPageViewMode.episodes,
  );
  return object;
}

P _podcastDetailsPageModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_PodcastDetailsPageModelepisodeFilterModeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          EpisodeFilterMode.all) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 4:
      return (_PodcastDetailsPageModelseasonFilterModeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SeasonFilterMode.all) as P;
    case 5:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 6:
      return (_PodcastDetailsPageModelviewModeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          PodcastDetailsPageViewMode.episodes) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PodcastDetailsPageModelepisodeFilterModeEnumValueMap = {
  'all': 0,
  'unplayed': 1,
  'completed': 2,
  'downloaded': 3,
};
const _PodcastDetailsPageModelepisodeFilterModeValueEnumMap = {
  0: EpisodeFilterMode.all,
  1: EpisodeFilterMode.unplayed,
  2: EpisodeFilterMode.completed,
  3: EpisodeFilterMode.downloaded,
};
const _PodcastDetailsPageModelseasonFilterModeEnumValueMap = {
  'all': 0,
  'unplayed': 1,
};
const _PodcastDetailsPageModelseasonFilterModeValueEnumMap = {
  0: SeasonFilterMode.all,
  1: SeasonFilterMode.unplayed,
};
const _PodcastDetailsPageModelviewModeEnumValueMap = {
  'episodes': 0,
  'seasons': 1,
};
const _PodcastDetailsPageModelviewModeValueEnumMap = {
  0: PodcastDetailsPageViewMode.episodes,
  1: PodcastDetailsPageViewMode.seasons,
};

Id _podcastDetailsPageModelGetId(PodcastDetailsPageModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _podcastDetailsPageModelGetLinks(
    PodcastDetailsPageModel object) {
  return [];
}

void _podcastDetailsPageModelAttach(
    IsarCollection<dynamic> col, Id id, PodcastDetailsPageModel object) {}

extension PodcastDetailsPageModelQueryWhereSort
    on QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QWhere> {
  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PodcastDetailsPageModelQueryWhere on QueryBuilder<
    PodcastDetailsPageModel, PodcastDetailsPageModel, QWhereClause> {
  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterWhereClause> idBetween(
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

extension PodcastDetailsPageModelQueryFilter on QueryBuilder<
    PodcastDetailsPageModel, PodcastDetailsPageModel, QFilterCondition> {
  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterFilterCondition> episodeFilterModeEqualTo(EpisodeFilterMode value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'episodeFilterMode',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterFilterCondition> episodeFilterModeGreaterThan(
    EpisodeFilterMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'episodeFilterMode',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterFilterCondition> episodeFilterModeLessThan(
    EpisodeFilterMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'episodeFilterMode',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterFilterCondition> episodeFilterModeBetween(
    EpisodeFilterMode lower,
    EpisodeFilterMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'episodeFilterMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterFilterCondition> episodesAscendingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'episodesAscending',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterFilterCondition> pidEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pid',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterFilterCondition> pidGreaterThan(
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

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterFilterCondition> pidLessThan(
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

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterFilterCondition> pidBetween(
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

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterFilterCondition> seasonEpisodesAscendingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'seasonEpisodesAscending',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterFilterCondition> seasonFilterModeEqualTo(SeasonFilterMode value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'seasonFilterMode',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterFilterCondition> seasonFilterModeGreaterThan(
    SeasonFilterMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'seasonFilterMode',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterFilterCondition> seasonFilterModeLessThan(
    SeasonFilterMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'seasonFilterMode',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterFilterCondition> seasonFilterModeBetween(
    SeasonFilterMode lower,
    SeasonFilterMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'seasonFilterMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterFilterCondition> seasonsAscendingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'seasonsAscending',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterFilterCondition> viewModeEqualTo(PodcastDetailsPageViewMode value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'viewMode',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterFilterCondition> viewModeGreaterThan(
    PodcastDetailsPageViewMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'viewMode',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterFilterCondition> viewModeLessThan(
    PodcastDetailsPageViewMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'viewMode',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel,
      QAfterFilterCondition> viewModeBetween(
    PodcastDetailsPageViewMode lower,
    PodcastDetailsPageViewMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'viewMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PodcastDetailsPageModelQueryObject on QueryBuilder<
    PodcastDetailsPageModel, PodcastDetailsPageModel, QFilterCondition> {}

extension PodcastDetailsPageModelQueryLinks on QueryBuilder<
    PodcastDetailsPageModel, PodcastDetailsPageModel, QFilterCondition> {}

extension PodcastDetailsPageModelQuerySortBy
    on QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QSortBy> {
  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      sortByEpisodeFilterMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeFilterMode', Sort.asc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      sortByEpisodeFilterModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeFilterMode', Sort.desc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      sortByEpisodesAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodesAscending', Sort.asc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      sortByEpisodesAscendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodesAscending', Sort.desc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      sortByPid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pid', Sort.asc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      sortByPidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pid', Sort.desc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      sortBySeasonEpisodesAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonEpisodesAscending', Sort.asc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      sortBySeasonEpisodesAscendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonEpisodesAscending', Sort.desc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      sortBySeasonFilterMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonFilterMode', Sort.asc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      sortBySeasonFilterModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonFilterMode', Sort.desc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      sortBySeasonsAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonsAscending', Sort.asc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      sortBySeasonsAscendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonsAscending', Sort.desc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      sortByViewMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.asc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      sortByViewModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.desc);
    });
  }
}

extension PodcastDetailsPageModelQuerySortThenBy on QueryBuilder<
    PodcastDetailsPageModel, PodcastDetailsPageModel, QSortThenBy> {
  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      thenByEpisodeFilterMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeFilterMode', Sort.asc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      thenByEpisodeFilterModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeFilterMode', Sort.desc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      thenByEpisodesAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodesAscending', Sort.asc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      thenByEpisodesAscendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodesAscending', Sort.desc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      thenByPid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pid', Sort.asc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      thenByPidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pid', Sort.desc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      thenBySeasonEpisodesAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonEpisodesAscending', Sort.asc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      thenBySeasonEpisodesAscendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonEpisodesAscending', Sort.desc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      thenBySeasonFilterMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonFilterMode', Sort.asc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      thenBySeasonFilterModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonFilterMode', Sort.desc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      thenBySeasonsAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonsAscending', Sort.asc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      thenBySeasonsAscendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonsAscending', Sort.desc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      thenByViewMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.asc);
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QAfterSortBy>
      thenByViewModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.desc);
    });
  }
}

extension PodcastDetailsPageModelQueryWhereDistinct on QueryBuilder<
    PodcastDetailsPageModel, PodcastDetailsPageModel, QDistinct> {
  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QDistinct>
      distinctByEpisodeFilterMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'episodeFilterMode');
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QDistinct>
      distinctByEpisodesAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'episodesAscending');
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QDistinct>
      distinctByPid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pid');
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QDistinct>
      distinctBySeasonEpisodesAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'seasonEpisodesAscending');
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QDistinct>
      distinctBySeasonFilterMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'seasonFilterMode');
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QDistinct>
      distinctBySeasonsAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'seasonsAscending');
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageModel, QDistinct>
      distinctByViewMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'viewMode');
    });
  }
}

extension PodcastDetailsPageModelQueryProperty on QueryBuilder<
    PodcastDetailsPageModel, PodcastDetailsPageModel, QQueryProperty> {
  QueryBuilder<PodcastDetailsPageModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PodcastDetailsPageModel, EpisodeFilterMode, QQueryOperations>
      episodeFilterModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeFilterMode');
    });
  }

  QueryBuilder<PodcastDetailsPageModel, bool, QQueryOperations>
      episodesAscendingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodesAscending');
    });
  }

  QueryBuilder<PodcastDetailsPageModel, int, QQueryOperations> pidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pid');
    });
  }

  QueryBuilder<PodcastDetailsPageModel, bool, QQueryOperations>
      seasonEpisodesAscendingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seasonEpisodesAscending');
    });
  }

  QueryBuilder<PodcastDetailsPageModel, SeasonFilterMode, QQueryOperations>
      seasonFilterModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seasonFilterMode');
    });
  }

  QueryBuilder<PodcastDetailsPageModel, bool, QQueryOperations>
      seasonsAscendingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seasonsAscending');
    });
  }

  QueryBuilder<PodcastDetailsPageModel, PodcastDetailsPageViewMode,
      QQueryOperations> viewModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'viewMode');
    });
  }
}
