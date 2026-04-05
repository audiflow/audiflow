// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode_transcript.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEpisodeTranscriptCollection on Isar {
  IsarCollection<EpisodeTranscript> get episodeTranscripts => this.collection();
}

const EpisodeTranscriptSchema = CollectionSchema(
  name: r'EpisodeTranscript',
  id: -2332592946456523483,
  properties: {
    r'episodeId': PropertySchema(
      id: 0,
      name: r'episodeId',
      type: IsarType.long,
    ),
    r'fetchedAt': PropertySchema(
      id: 1,
      name: r'fetchedAt',
      type: IsarType.dateTime,
    ),
    r'language': PropertySchema(
      id: 2,
      name: r'language',
      type: IsarType.string,
    ),
    r'rel': PropertySchema(id: 3, name: r'rel', type: IsarType.string),
    r'type': PropertySchema(id: 4, name: r'type', type: IsarType.string),
    r'url': PropertySchema(id: 5, name: r'url', type: IsarType.string),
  },

  estimateSize: _episodeTranscriptEstimateSize,
  serialize: _episodeTranscriptSerialize,
  deserialize: _episodeTranscriptDeserialize,
  deserializeProp: _episodeTranscriptDeserializeProp,
  idName: r'id',
  indexes: {
    r'episodeId_url': IndexSchema(
      id: -2366990471514011911,
      name: r'episodeId_url',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'episodeId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'url',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _episodeTranscriptGetId,
  getLinks: _episodeTranscriptGetLinks,
  attach: _episodeTranscriptAttach,
  version: '3.3.2',
);

int _episodeTranscriptEstimateSize(
  EpisodeTranscript object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.language;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.rel;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.type.length * 3;
  bytesCount += 3 + object.url.length * 3;
  return bytesCount;
}

void _episodeTranscriptSerialize(
  EpisodeTranscript object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.episodeId);
  writer.writeDateTime(offsets[1], object.fetchedAt);
  writer.writeString(offsets[2], object.language);
  writer.writeString(offsets[3], object.rel);
  writer.writeString(offsets[4], object.type);
  writer.writeString(offsets[5], object.url);
}

EpisodeTranscript _episodeTranscriptDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EpisodeTranscript();
  object.episodeId = reader.readLong(offsets[0]);
  object.fetchedAt = reader.readDateTimeOrNull(offsets[1]);
  object.id = id;
  object.language = reader.readStringOrNull(offsets[2]);
  object.rel = reader.readStringOrNull(offsets[3]);
  object.type = reader.readString(offsets[4]);
  object.url = reader.readString(offsets[5]);
  return object;
}

P _episodeTranscriptDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _episodeTranscriptGetId(EpisodeTranscript object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _episodeTranscriptGetLinks(
  EpisodeTranscript object,
) {
  return [];
}

void _episodeTranscriptAttach(
  IsarCollection<dynamic> col,
  Id id,
  EpisodeTranscript object,
) {
  object.id = id;
}

extension EpisodeTranscriptByIndex on IsarCollection<EpisodeTranscript> {
  Future<EpisodeTranscript?> getByEpisodeIdUrl(int episodeId, String url) {
    return getByIndex(r'episodeId_url', [episodeId, url]);
  }

  EpisodeTranscript? getByEpisodeIdUrlSync(int episodeId, String url) {
    return getByIndexSync(r'episodeId_url', [episodeId, url]);
  }

  Future<bool> deleteByEpisodeIdUrl(int episodeId, String url) {
    return deleteByIndex(r'episodeId_url', [episodeId, url]);
  }

  bool deleteByEpisodeIdUrlSync(int episodeId, String url) {
    return deleteByIndexSync(r'episodeId_url', [episodeId, url]);
  }

  Future<List<EpisodeTranscript?>> getAllByEpisodeIdUrl(
    List<int> episodeIdValues,
    List<String> urlValues,
  ) {
    final len = episodeIdValues.length;
    assert(
      urlValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([episodeIdValues[i], urlValues[i]]);
    }

    return getAllByIndex(r'episodeId_url', values);
  }

  List<EpisodeTranscript?> getAllByEpisodeIdUrlSync(
    List<int> episodeIdValues,
    List<String> urlValues,
  ) {
    final len = episodeIdValues.length;
    assert(
      urlValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([episodeIdValues[i], urlValues[i]]);
    }

    return getAllByIndexSync(r'episodeId_url', values);
  }

  Future<int> deleteAllByEpisodeIdUrl(
    List<int> episodeIdValues,
    List<String> urlValues,
  ) {
    final len = episodeIdValues.length;
    assert(
      urlValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([episodeIdValues[i], urlValues[i]]);
    }

    return deleteAllByIndex(r'episodeId_url', values);
  }

  int deleteAllByEpisodeIdUrlSync(
    List<int> episodeIdValues,
    List<String> urlValues,
  ) {
    final len = episodeIdValues.length;
    assert(
      urlValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([episodeIdValues[i], urlValues[i]]);
    }

    return deleteAllByIndexSync(r'episodeId_url', values);
  }

  Future<Id> putByEpisodeIdUrl(EpisodeTranscript object) {
    return putByIndex(r'episodeId_url', object);
  }

  Id putByEpisodeIdUrlSync(EpisodeTranscript object, {bool saveLinks = true}) {
    return putByIndexSync(r'episodeId_url', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEpisodeIdUrl(List<EpisodeTranscript> objects) {
    return putAllByIndex(r'episodeId_url', objects);
  }

  List<Id> putAllByEpisodeIdUrlSync(
    List<EpisodeTranscript> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'episodeId_url', objects, saveLinks: saveLinks);
  }
}

extension EpisodeTranscriptQueryWhereSort
    on QueryBuilder<EpisodeTranscript, EpisodeTranscript, QWhere> {
  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension EpisodeTranscriptQueryWhere
    on QueryBuilder<EpisodeTranscript, EpisodeTranscript, QWhereClause> {
  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterWhereClause>
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

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterWhereClause>
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

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterWhereClause>
  episodeIdEqualToAnyUrl(int episodeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'episodeId_url',
          value: [episodeId],
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterWhereClause>
  episodeIdNotEqualToAnyUrl(int episodeId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeId_url',
                lower: [],
                upper: [episodeId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeId_url',
                lower: [episodeId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeId_url',
                lower: [episodeId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeId_url',
                lower: [],
                upper: [episodeId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterWhereClause>
  episodeIdGreaterThanAnyUrl(int episodeId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'episodeId_url',
          lower: [episodeId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterWhereClause>
  episodeIdLessThanAnyUrl(int episodeId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'episodeId_url',
          lower: [],
          upper: [episodeId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterWhereClause>
  episodeIdBetweenAnyUrl(
    int lowerEpisodeId,
    int upperEpisodeId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'episodeId_url',
          lower: [lowerEpisodeId],
          includeLower: includeLower,
          upper: [upperEpisodeId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterWhereClause>
  episodeIdUrlEqualTo(int episodeId, String url) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'episodeId_url',
          value: [episodeId, url],
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterWhereClause>
  episodeIdEqualToUrlNotEqualTo(int episodeId, String url) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeId_url',
                lower: [episodeId],
                upper: [episodeId, url],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeId_url',
                lower: [episodeId, url],
                includeLower: false,
                upper: [episodeId],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeId_url',
                lower: [episodeId, url],
                includeLower: false,
                upper: [episodeId],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeId_url',
                lower: [episodeId],
                upper: [episodeId, url],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension EpisodeTranscriptQueryFilter
    on QueryBuilder<EpisodeTranscript, EpisodeTranscript, QFilterCondition> {
  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  episodeIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeId', value: value),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  episodeIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'episodeId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  episodeIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'episodeId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  episodeIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'episodeId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  fetchedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'fetchedAt'),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  fetchedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'fetchedAt'),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  fetchedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fetchedAt', value: value),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  fetchedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fetchedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  fetchedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fetchedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  fetchedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fetchedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
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

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
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

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
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

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  languageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'language'),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  languageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'language'),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  languageEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  languageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  languageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  languageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'language',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  languageStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  languageEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  languageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  languageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'language',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  languageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'language', value: ''),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  languageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'language', value: ''),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  relIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'rel'),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  relIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'rel'),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  relEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'rel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  relGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  relLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  relBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rel',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  relStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'rel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  relEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'rel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  relContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'rel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  relMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'rel',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  relIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'rel', value: ''),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  relIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'rel', value: ''),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  typeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'type',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  typeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  typeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'type',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  urlEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  urlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  urlLessThan(String value, {bool include = false, bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  urlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'url',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  urlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  urlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  urlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  urlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'url',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'url', value: ''),
      );
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterFilterCondition>
  urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'url', value: ''),
      );
    });
  }
}

extension EpisodeTranscriptQueryObject
    on QueryBuilder<EpisodeTranscript, EpisodeTranscript, QFilterCondition> {}

extension EpisodeTranscriptQueryLinks
    on QueryBuilder<EpisodeTranscript, EpisodeTranscript, QFilterCondition> {}

extension EpisodeTranscriptQuerySortBy
    on QueryBuilder<EpisodeTranscript, EpisodeTranscript, QSortBy> {
  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterSortBy>
  sortByEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.asc);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterSortBy>
  sortByEpisodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.desc);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterSortBy>
  sortByFetchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fetchedAt', Sort.asc);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterSortBy>
  sortByFetchedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fetchedAt', Sort.desc);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterSortBy>
  sortByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterSortBy>
  sortByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterSortBy> sortByRel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rel', Sort.asc);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterSortBy>
  sortByRelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rel', Sort.desc);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterSortBy>
  sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterSortBy>
  sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterSortBy> sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterSortBy>
  sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension EpisodeTranscriptQuerySortThenBy
    on QueryBuilder<EpisodeTranscript, EpisodeTranscript, QSortThenBy> {
  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterSortBy>
  thenByEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.asc);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterSortBy>
  thenByEpisodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.desc);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterSortBy>
  thenByFetchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fetchedAt', Sort.asc);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterSortBy>
  thenByFetchedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fetchedAt', Sort.desc);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterSortBy>
  thenByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterSortBy>
  thenByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterSortBy> thenByRel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rel', Sort.asc);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterSortBy>
  thenByRelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rel', Sort.desc);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterSortBy>
  thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterSortBy>
  thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterSortBy> thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QAfterSortBy>
  thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension EpisodeTranscriptQueryWhereDistinct
    on QueryBuilder<EpisodeTranscript, EpisodeTranscript, QDistinct> {
  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QDistinct>
  distinctByEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'episodeId');
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QDistinct>
  distinctByFetchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fetchedAt');
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QDistinct>
  distinctByLanguage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'language', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QDistinct> distinctByRel({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QDistinct> distinctByType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EpisodeTranscript, EpisodeTranscript, QDistinct> distinctByUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }
}

extension EpisodeTranscriptQueryProperty
    on QueryBuilder<EpisodeTranscript, EpisodeTranscript, QQueryProperty> {
  QueryBuilder<EpisodeTranscript, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<EpisodeTranscript, int, QQueryOperations> episodeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeId');
    });
  }

  QueryBuilder<EpisodeTranscript, DateTime?, QQueryOperations>
  fetchedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fetchedAt');
    });
  }

  QueryBuilder<EpisodeTranscript, String?, QQueryOperations>
  languageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'language');
    });
  }

  QueryBuilder<EpisodeTranscript, String?, QQueryOperations> relProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rel');
    });
  }

  QueryBuilder<EpisodeTranscript, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<EpisodeTranscript, String, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }
}
