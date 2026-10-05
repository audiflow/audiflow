// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_audio_preference.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetPodcastAudioPreferenceCollection on Isar {
  IsarCollection<PodcastAudioPreference> get podcastAudioPreferences =>
      this.collection();
}

const PodcastAudioPreferenceSchema = CollectionSchema(
  name: r'PodcastAudioPreference',
  id: 5941285181138385537,
  properties: {
    r'podcastId': PropertySchema(
      id: 0,
      name: r'podcastId',
      type: IsarType.long,
    ),
    r'skipSilence': PropertySchema(
      id: 1,
      name: r'skipSilence',
      type: IsarType.bool,
    ),
    r'speed': PropertySchema(id: 2, name: r'speed', type: IsarType.double),
    r'voiceBoost': PropertySchema(
      id: 3,
      name: r'voiceBoost',
      type: IsarType.bool,
    ),
  },

  estimateSize: _podcastAudioPreferenceEstimateSize,
  serialize: _podcastAudioPreferenceSerialize,
  deserialize: _podcastAudioPreferenceDeserialize,
  deserializeProp: _podcastAudioPreferenceDeserializeProp,
  idName: r'id',
  indexes: {
    r'podcastId': IndexSchema(
      id: -1067219606322714012,
      name: r'podcastId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'podcastId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _podcastAudioPreferenceGetId,
  getLinks: _podcastAudioPreferenceGetLinks,
  attach: _podcastAudioPreferenceAttach,
  version: '3.3.2',
);

int _podcastAudioPreferenceEstimateSize(
  PodcastAudioPreference object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _podcastAudioPreferenceSerialize(
  PodcastAudioPreference object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.podcastId);
  writer.writeBool(offsets[1], object.skipSilence);
  writer.writeDouble(offsets[2], object.speed);
  writer.writeBool(offsets[3], object.voiceBoost);
}

PodcastAudioPreference _podcastAudioPreferenceDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PodcastAudioPreference();
  object.id = id;
  object.podcastId = reader.readLong(offsets[0]);
  object.skipSilence = reader.readBoolOrNull(offsets[1]);
  object.speed = reader.readDouble(offsets[2]);
  object.voiceBoost = reader.readBoolOrNull(offsets[3]);
  return object;
}

P _podcastAudioPreferenceDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _podcastAudioPreferenceGetId(PodcastAudioPreference object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _podcastAudioPreferenceGetLinks(
  PodcastAudioPreference object,
) {
  return [];
}

void _podcastAudioPreferenceAttach(
  IsarCollection<dynamic> col,
  Id id,
  PodcastAudioPreference object,
) {
  object.id = id;
}

extension PodcastAudioPreferenceByIndex
    on IsarCollection<PodcastAudioPreference> {
  Future<PodcastAudioPreference?> getByPodcastId(int podcastId) {
    return getByIndex(r'podcastId', [podcastId]);
  }

  PodcastAudioPreference? getByPodcastIdSync(int podcastId) {
    return getByIndexSync(r'podcastId', [podcastId]);
  }

  Future<bool> deleteByPodcastId(int podcastId) {
    return deleteByIndex(r'podcastId', [podcastId]);
  }

  bool deleteByPodcastIdSync(int podcastId) {
    return deleteByIndexSync(r'podcastId', [podcastId]);
  }

  Future<List<PodcastAudioPreference?>> getAllByPodcastId(
    List<int> podcastIdValues,
  ) {
    final values = podcastIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'podcastId', values);
  }

  List<PodcastAudioPreference?> getAllByPodcastIdSync(
    List<int> podcastIdValues,
  ) {
    final values = podcastIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'podcastId', values);
  }

  Future<int> deleteAllByPodcastId(List<int> podcastIdValues) {
    final values = podcastIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'podcastId', values);
  }

  int deleteAllByPodcastIdSync(List<int> podcastIdValues) {
    final values = podcastIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'podcastId', values);
  }

  Future<Id> putByPodcastId(PodcastAudioPreference object) {
    return putByIndex(r'podcastId', object);
  }

  Id putByPodcastIdSync(
    PodcastAudioPreference object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(r'podcastId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPodcastId(List<PodcastAudioPreference> objects) {
    return putAllByIndex(r'podcastId', objects);
  }

  List<Id> putAllByPodcastIdSync(
    List<PodcastAudioPreference> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'podcastId', objects, saveLinks: saveLinks);
  }
}

extension PodcastAudioPreferenceQueryWhereSort
    on QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QWhere> {
  QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QAfterWhere>
  anyPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'podcastId'),
      );
    });
  }
}

extension PodcastAudioPreferenceQueryWhere
    on
        QueryBuilder<
          PodcastAudioPreference,
          PodcastAudioPreference,
          QWhereClause
        > {
  QueryBuilder<
    PodcastAudioPreference,
    PodcastAudioPreference,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    PodcastAudioPreference,
    PodcastAudioPreference,
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
    PodcastAudioPreference,
    PodcastAudioPreference,
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
    PodcastAudioPreference,
    PodcastAudioPreference,
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
    PodcastAudioPreference,
    PodcastAudioPreference,
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
    PodcastAudioPreference,
    PodcastAudioPreference,
    QAfterWhereClause
  >
  podcastIdEqualTo(int podcastId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'podcastId', value: [podcastId]),
      );
    });
  }

  QueryBuilder<
    PodcastAudioPreference,
    PodcastAudioPreference,
    QAfterWhereClause
  >
  podcastIdNotEqualTo(int podcastId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId',
                lower: [],
                upper: [podcastId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId',
                lower: [podcastId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId',
                lower: [podcastId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId',
                lower: [],
                upper: [podcastId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    PodcastAudioPreference,
    PodcastAudioPreference,
    QAfterWhereClause
  >
  podcastIdGreaterThan(int podcastId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'podcastId',
          lower: [podcastId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<
    PodcastAudioPreference,
    PodcastAudioPreference,
    QAfterWhereClause
  >
  podcastIdLessThan(int podcastId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'podcastId',
          lower: [],
          upper: [podcastId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastAudioPreference,
    PodcastAudioPreference,
    QAfterWhereClause
  >
  podcastIdBetween(
    int lowerPodcastId,
    int upperPodcastId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'podcastId',
          lower: [lowerPodcastId],
          includeLower: includeLower,
          upper: [upperPodcastId],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension PodcastAudioPreferenceQueryFilter
    on
        QueryBuilder<
          PodcastAudioPreference,
          PodcastAudioPreference,
          QFilterCondition
        > {
  QueryBuilder<
    PodcastAudioPreference,
    PodcastAudioPreference,
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
    PodcastAudioPreference,
    PodcastAudioPreference,
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
    PodcastAudioPreference,
    PodcastAudioPreference,
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
    PodcastAudioPreference,
    PodcastAudioPreference,
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
    PodcastAudioPreference,
    PodcastAudioPreference,
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
    PodcastAudioPreference,
    PodcastAudioPreference,
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
    PodcastAudioPreference,
    PodcastAudioPreference,
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
    PodcastAudioPreference,
    PodcastAudioPreference,
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

  QueryBuilder<
    PodcastAudioPreference,
    PodcastAudioPreference,
    QAfterFilterCondition
  >
  skipSilenceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'skipSilence'),
      );
    });
  }

  QueryBuilder<
    PodcastAudioPreference,
    PodcastAudioPreference,
    QAfterFilterCondition
  >
  skipSilenceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'skipSilence'),
      );
    });
  }

  QueryBuilder<
    PodcastAudioPreference,
    PodcastAudioPreference,
    QAfterFilterCondition
  >
  skipSilenceEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'skipSilence', value: value),
      );
    });
  }

  QueryBuilder<
    PodcastAudioPreference,
    PodcastAudioPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PodcastAudioPreference,
    PodcastAudioPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PodcastAudioPreference,
    PodcastAudioPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PodcastAudioPreference,
    PodcastAudioPreference,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PodcastAudioPreference,
    PodcastAudioPreference,
    QAfterFilterCondition
  >
  voiceBoostIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'voiceBoost'),
      );
    });
  }

  QueryBuilder<
    PodcastAudioPreference,
    PodcastAudioPreference,
    QAfterFilterCondition
  >
  voiceBoostIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'voiceBoost'),
      );
    });
  }

  QueryBuilder<
    PodcastAudioPreference,
    PodcastAudioPreference,
    QAfterFilterCondition
  >
  voiceBoostEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'voiceBoost', value: value),
      );
    });
  }
}

extension PodcastAudioPreferenceQueryObject
    on
        QueryBuilder<
          PodcastAudioPreference,
          PodcastAudioPreference,
          QFilterCondition
        > {}

extension PodcastAudioPreferenceQueryLinks
    on
        QueryBuilder<
          PodcastAudioPreference,
          PodcastAudioPreference,
          QFilterCondition
        > {}

extension PodcastAudioPreferenceQuerySortBy
    on QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QSortBy> {
  QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QAfterSortBy>
  sortByPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.asc);
    });
  }

  QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QAfterSortBy>
  sortByPodcastIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.desc);
    });
  }

  QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QAfterSortBy>
  sortBySkipSilence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipSilence', Sort.asc);
    });
  }

  QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QAfterSortBy>
  sortBySkipSilenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipSilence', Sort.desc);
    });
  }

  QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QAfterSortBy>
  sortBySpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.asc);
    });
  }

  QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QAfterSortBy>
  sortBySpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.desc);
    });
  }

  QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QAfterSortBy>
  sortByVoiceBoost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceBoost', Sort.asc);
    });
  }

  QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QAfterSortBy>
  sortByVoiceBoostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceBoost', Sort.desc);
    });
  }
}

extension PodcastAudioPreferenceQuerySortThenBy
    on
        QueryBuilder<
          PodcastAudioPreference,
          PodcastAudioPreference,
          QSortThenBy
        > {
  QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QAfterSortBy>
  thenByPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.asc);
    });
  }

  QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QAfterSortBy>
  thenByPodcastIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.desc);
    });
  }

  QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QAfterSortBy>
  thenBySkipSilence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipSilence', Sort.asc);
    });
  }

  QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QAfterSortBy>
  thenBySkipSilenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipSilence', Sort.desc);
    });
  }

  QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QAfterSortBy>
  thenBySpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.asc);
    });
  }

  QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QAfterSortBy>
  thenBySpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.desc);
    });
  }

  QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QAfterSortBy>
  thenByVoiceBoost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceBoost', Sort.asc);
    });
  }

  QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QAfterSortBy>
  thenByVoiceBoostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceBoost', Sort.desc);
    });
  }
}

extension PodcastAudioPreferenceQueryWhereDistinct
    on QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QDistinct> {
  QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QDistinct>
  distinctByPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'podcastId');
    });
  }

  QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QDistinct>
  distinctBySkipSilence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'skipSilence');
    });
  }

  QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QDistinct>
  distinctBySpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'speed');
    });
  }

  QueryBuilder<PodcastAudioPreference, PodcastAudioPreference, QDistinct>
  distinctByVoiceBoost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'voiceBoost');
    });
  }
}

extension PodcastAudioPreferenceQueryProperty
    on
        QueryBuilder<
          PodcastAudioPreference,
          PodcastAudioPreference,
          QQueryProperty
        > {
  QueryBuilder<PodcastAudioPreference, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PodcastAudioPreference, int, QQueryOperations>
  podcastIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'podcastId');
    });
  }

  QueryBuilder<PodcastAudioPreference, bool?, QQueryOperations>
  skipSilenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'skipSilence');
    });
  }

  QueryBuilder<PodcastAudioPreference, double, QQueryOperations>
  speedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'speed');
    });
  }

  QueryBuilder<PodcastAudioPreference, bool?, QQueryOperations>
  voiceBoostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'voiceBoost');
    });
  }
}
