// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, duplicate_ignore

part of 'episode.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEpisodeCollection on Isar {
  IsarCollection<Episode> get episodes => this.collection();
}

const EpisodeSchema = CollectionSchema(
  name: r'Episode',
  id: -3258565036328751473,
  properties: {
    r'author': PropertySchema(
      id: 0,
      name: r'author',
      type: IsarType.string,
    ),
    r'contentUrl': PropertySchema(
      id: 1,
      name: r'contentUrl',
      type: IsarType.string,
    ),
    r'description': PropertySchema(
      id: 2,
      name: r'description',
      type: IsarType.string,
    ),
    r'durationMS': PropertySchema(
      id: 3,
      name: r'durationMS',
      type: IsarType.long,
    ),
    r'episode': PropertySchema(
      id: 4,
      name: r'episode',
      type: IsarType.long,
    ),
    r'explicit': PropertySchema(
      id: 5,
      name: r'explicit',
      type: IsarType.bool,
    ),
    r'guid': PropertySchema(
      id: 6,
      name: r'guid',
      type: IsarType.string,
    ),
    r'imageUrl': PropertySchema(
      id: 7,
      name: r'imageUrl',
      type: IsarType.string,
    ),
    r'link': PropertySchema(
      id: 8,
      name: r'link',
      type: IsarType.string,
    ),
    r'pid': PropertySchema(
      id: 9,
      name: r'pid',
      type: IsarType.long,
    ),
    r'publicationDate': PropertySchema(
      id: 10,
      name: r'publicationDate',
      type: IsarType.dateTime,
    ),
    r'season': PropertySchema(
      id: 11,
      name: r'season',
      type: IsarType.long,
    ),
    r'title': PropertySchema(
      id: 12,
      name: r'title',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 13,
      name: r'type',
      type: IsarType.byte,
      enumMap: _EpisodetypeEnumValueMap,
    )
  },
  estimateSize: _episodeEstimateSize,
  serialize: _episodeSerialize,
  deserialize: _episodeDeserialize,
  deserializeProp: _episodeDeserializeProp,
  idName: r'id',
  indexes: {
    r'guid': IndexSchema(
      id: 4245463075130215835,
      name: r'guid',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'guid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {
    r'transcripts': LinkSchema(
      id: 2499130205585507551,
      name: r'transcripts',
      target: r'TranscriptUrl',
      single: false,
    ),
    r'block': LinkSchema(
      id: -5968238924456049578,
      name: r'block',
      target: r'Block',
      single: false,
    ),
    r'person': LinkSchema(
      id: -3086283965245414862,
      name: r'person',
      target: r'Person',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _episodeGetId,
  getLinks: _episodeGetLinks,
  attach: _episodeAttach,
  version: '3.1.0+1',
);

int _episodeEstimateSize(
  Episode object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.author;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.contentUrl.length * 3;
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.guid.length * 3;
  {
    final value = object.imageUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.link;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _episodeSerialize(
  Episode object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.author);
  writer.writeString(offsets[1], object.contentUrl);
  writer.writeString(offsets[2], object.description);
  writer.writeLong(offsets[3], object.durationMS);
  writer.writeLong(offsets[4], object.episode);
  writer.writeBool(offsets[5], object.explicit);
  writer.writeString(offsets[6], object.guid);
  writer.writeString(offsets[7], object.imageUrl);
  writer.writeString(offsets[8], object.link);
  writer.writeLong(offsets[9], object.pid);
  writer.writeDateTime(offsets[10], object.publicationDate);
  writer.writeLong(offsets[11], object.season);
  writer.writeString(offsets[12], object.title);
  writer.writeByte(offsets[13], object.type.index);
}

Episode _episodeDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Episode(
    author: reader.readStringOrNull(offsets[0]),
    contentUrl: reader.readString(offsets[1]),
    description: reader.readStringOrNull(offsets[2]),
    durationMS: reader.readLongOrNull(offsets[3]),
    episode: reader.readLongOrNull(offsets[4]),
    explicit: reader.readBoolOrNull(offsets[5]) ?? false,
    guid: reader.readString(offsets[6]),
    imageUrl: reader.readStringOrNull(offsets[7]),
    link: reader.readStringOrNull(offsets[8]),
    pid: reader.readLong(offsets[9]),
    publicationDate: reader.readDateTimeOrNull(offsets[10]),
    season: reader.readLongOrNull(offsets[11]),
    title: reader.readString(offsets[12]),
    type: _EpisodetypeValueEnumMap[reader.readByteOrNull(offsets[13])] ??
        EpisodeType.full,
  );
  return object;
}

P _episodeDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readLongOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (_EpisodetypeValueEnumMap[reader.readByteOrNull(offset)] ??
          EpisodeType.full) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _EpisodetypeEnumValueMap = {
  'full': 0,
  'trailer': 1,
  'bonus': 2,
};
const _EpisodetypeValueEnumMap = {
  0: EpisodeType.full,
  1: EpisodeType.trailer,
  2: EpisodeType.bonus,
};

Id _episodeGetId(Episode object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _episodeGetLinks(Episode object) {
  return [object.transcripts, object.block, object.person];
}

void _episodeAttach(IsarCollection<dynamic> col, Id id, Episode object) {
  object.transcripts
      .attach(col, col.isar.collection<TranscriptUrl>(), r'transcripts', id);
  object.block.attach(col, col.isar.collection<Block>(), r'block', id);
  object.person.attach(col, col.isar.collection<Person>(), r'person', id);
}

extension EpisodeByIndex on IsarCollection<Episode> {
  Future<Episode?> getByGuid(String guid) {
    return getByIndex(r'guid', [guid]);
  }

  Episode? getByGuidSync(String guid) {
    return getByIndexSync(r'guid', [guid]);
  }

  Future<bool> deleteByGuid(String guid) {
    return deleteByIndex(r'guid', [guid]);
  }

  bool deleteByGuidSync(String guid) {
    return deleteByIndexSync(r'guid', [guid]);
  }

  Future<List<Episode?>> getAllByGuid(List<String> guidValues) {
    final values = guidValues.map((e) => [e]).toList();
    return getAllByIndex(r'guid', values);
  }

  List<Episode?> getAllByGuidSync(List<String> guidValues) {
    final values = guidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'guid', values);
  }

  Future<int> deleteAllByGuid(List<String> guidValues) {
    final values = guidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'guid', values);
  }

  int deleteAllByGuidSync(List<String> guidValues) {
    final values = guidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'guid', values);
  }

  Future<Id> putByGuid(Episode object) {
    return putByIndex(r'guid', object);
  }

  Id putByGuidSync(Episode object, {bool saveLinks = true}) {
    return putByIndexSync(r'guid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByGuid(List<Episode> objects) {
    return putAllByIndex(r'guid', objects);
  }

  List<Id> putAllByGuidSync(List<Episode> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'guid', objects, saveLinks: saveLinks);
  }
}

extension EpisodeQueryWhereSort on QueryBuilder<Episode, Episode, QWhere> {
  QueryBuilder<Episode, Episode, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension EpisodeQueryWhere on QueryBuilder<Episode, Episode, QWhereClause> {
  QueryBuilder<Episode, Episode, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Episode, Episode, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Episode, Episode, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Episode, Episode, QAfterWhereClause> idBetween(
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

  QueryBuilder<Episode, Episode, QAfterWhereClause> guidEqualTo(String guid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'guid',
        value: [guid],
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterWhereClause> guidNotEqualTo(
      String guid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'guid',
              lower: [],
              upper: [guid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'guid',
              lower: [guid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'guid',
              lower: [guid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'guid',
              lower: [],
              upper: [guid],
              includeUpper: false,
            ));
      }
    });
  }
}

extension EpisodeQueryFilter
    on QueryBuilder<Episode, Episode, QFilterCondition> {
  QueryBuilder<Episode, Episode, QAfterFilterCondition> authorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'author',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> authorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'author',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> authorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> authorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> authorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> authorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'author',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> authorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> authorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> authorContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> authorMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'author',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> authorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'author',
        value: '',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> authorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'author',
        value: '',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> contentUrlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> contentUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contentUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> contentUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contentUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> contentUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contentUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> contentUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contentUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> contentUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contentUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> contentUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contentUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> contentUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contentUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> contentUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> contentUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contentUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> descriptionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> descriptionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> durationMSIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'durationMS',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> durationMSIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'durationMS',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> durationMSEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationMS',
        value: value,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> durationMSGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationMS',
        value: value,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> durationMSLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationMS',
        value: value,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> durationMSBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationMS',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> episodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'episode',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> episodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'episode',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> episodeEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'episode',
        value: value,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> episodeGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'episode',
        value: value,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> episodeLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'episode',
        value: value,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> episodeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'episode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> explicitEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'explicit',
        value: value,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> guidEqualTo(
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> guidGreaterThan(
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> guidLessThan(
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> guidBetween(
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> guidStartsWith(
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> guidEndsWith(
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> guidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> guidMatches(
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> guidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'guid',
        value: '',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> guidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'guid',
        value: '',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> imageUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imageUrl',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> imageUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imageUrl',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> imageUrlEqualTo(
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> imageUrlGreaterThan(
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> imageUrlLessThan(
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> imageUrlBetween(
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> imageUrlStartsWith(
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> imageUrlEndsWith(
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> imageUrlContains(
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> imageUrlMatches(
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> imageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> imageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> linkIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'link',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> linkIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'link',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> linkEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'link',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> linkGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'link',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> linkLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'link',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> linkBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'link',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> linkStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'link',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> linkEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'link',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> linkContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'link',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> linkMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'link',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> linkIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'link',
        value: '',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> linkIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'link',
        value: '',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> pidEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pid',
        value: value,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> pidGreaterThan(
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> pidLessThan(
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> pidBetween(
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition>
      publicationDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'publicationDate',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition>
      publicationDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'publicationDate',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> publicationDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'publicationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition>
      publicationDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'publicationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> publicationDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'publicationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> publicationDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'publicationDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> seasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'season',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> seasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'season',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> seasonEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'season',
        value: value,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> seasonGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'season',
        value: value,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> seasonLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'season',
        value: value,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> seasonBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'season',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> titleEqualTo(
    String value, {
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> titleGreaterThan(
    String value, {
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> titleLessThan(
    String value, {
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> titleStartsWith(
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> titleEndsWith(
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> titleContains(
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> titleMatches(
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

  QueryBuilder<Episode, Episode, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> typeEqualTo(
      EpisodeType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> typeGreaterThan(
    EpisodeType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> typeLessThan(
    EpisodeType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> typeBetween(
    EpisodeType lower,
    EpisodeType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension EpisodeQueryObject
    on QueryBuilder<Episode, Episode, QFilterCondition> {}

extension EpisodeQueryLinks
    on QueryBuilder<Episode, Episode, QFilterCondition> {
  QueryBuilder<Episode, Episode, QAfterFilterCondition> transcripts(
      FilterQuery<TranscriptUrl> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'transcripts');
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition>
      transcriptsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'transcripts', length, true, length, true);
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> transcriptsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'transcripts', 0, true, 0, true);
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition>
      transcriptsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'transcripts', 0, false, 999999, true);
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition>
      transcriptsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'transcripts', 0, true, length, include);
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition>
      transcriptsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'transcripts', length, include, 999999, true);
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition>
      transcriptsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'transcripts', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> block(
      FilterQuery<Block> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'block');
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> blockLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'block', length, true, length, true);
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> blockIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'block', 0, true, 0, true);
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> blockIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'block', 0, false, 999999, true);
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> blockLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'block', 0, true, length, include);
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> blockLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'block', length, include, 999999, true);
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> blockLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'block', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> person(
      FilterQuery<Person> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'person');
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> personLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'person', length, true, length, true);
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> personIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'person', 0, true, 0, true);
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> personIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'person', 0, false, 999999, true);
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> personLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'person', 0, true, length, include);
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> personLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'person', length, include, 999999, true);
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> personLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'person', lower, includeLower, upper, includeUpper);
    });
  }
}

extension EpisodeQuerySortBy on QueryBuilder<Episode, Episode, QSortBy> {
  QueryBuilder<Episode, Episode, QAfterSortBy> sortByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortByContentUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentUrl', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortByContentUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentUrl', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortByDurationMS() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMS', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortByDurationMSDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMS', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortByEpisode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episode', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortByEpisodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episode', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortByExplicit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explicit', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortByExplicitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explicit', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortByLink() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'link', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortByLinkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'link', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortByPid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pid', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortByPidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pid', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortByPublicationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicationDate', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortByPublicationDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicationDate', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortBySeason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'season', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortBySeasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'season', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension EpisodeQuerySortThenBy
    on QueryBuilder<Episode, Episode, QSortThenBy> {
  QueryBuilder<Episode, Episode, QAfterSortBy> thenByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenByContentUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentUrl', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenByContentUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentUrl', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenByDurationMS() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMS', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenByDurationMSDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMS', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenByEpisode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episode', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenByEpisodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episode', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenByExplicit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explicit', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenByExplicitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explicit', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenByLink() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'link', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenByLinkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'link', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenByPid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pid', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenByPidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pid', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenByPublicationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicationDate', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenByPublicationDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicationDate', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenBySeason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'season', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenBySeasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'season', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<Episode, Episode, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension EpisodeQueryWhereDistinct
    on QueryBuilder<Episode, Episode, QDistinct> {
  QueryBuilder<Episode, Episode, QDistinct> distinctByAuthor(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'author', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Episode, Episode, QDistinct> distinctByContentUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contentUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Episode, Episode, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Episode, Episode, QDistinct> distinctByDurationMS() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationMS');
    });
  }

  QueryBuilder<Episode, Episode, QDistinct> distinctByEpisode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'episode');
    });
  }

  QueryBuilder<Episode, Episode, QDistinct> distinctByExplicit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'explicit');
    });
  }

  QueryBuilder<Episode, Episode, QDistinct> distinctByGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'guid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Episode, Episode, QDistinct> distinctByImageUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imageUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Episode, Episode, QDistinct> distinctByLink(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'link', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Episode, Episode, QDistinct> distinctByPid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pid');
    });
  }

  QueryBuilder<Episode, Episode, QDistinct> distinctByPublicationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'publicationDate');
    });
  }

  QueryBuilder<Episode, Episode, QDistinct> distinctBySeason() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'season');
    });
  }

  QueryBuilder<Episode, Episode, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Episode, Episode, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension EpisodeQueryProperty
    on QueryBuilder<Episode, Episode, QQueryProperty> {
  QueryBuilder<Episode, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Episode, String?, QQueryOperations> authorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'author');
    });
  }

  QueryBuilder<Episode, String, QQueryOperations> contentUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentUrl');
    });
  }

  QueryBuilder<Episode, String?, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<Episode, int?, QQueryOperations> durationMSProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationMS');
    });
  }

  QueryBuilder<Episode, int?, QQueryOperations> episodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episode');
    });
  }

  QueryBuilder<Episode, bool, QQueryOperations> explicitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'explicit');
    });
  }

  QueryBuilder<Episode, String, QQueryOperations> guidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'guid');
    });
  }

  QueryBuilder<Episode, String?, QQueryOperations> imageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imageUrl');
    });
  }

  QueryBuilder<Episode, String?, QQueryOperations> linkProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'link');
    });
  }

  QueryBuilder<Episode, int, QQueryOperations> pidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pid');
    });
  }

  QueryBuilder<Episode, DateTime?, QQueryOperations> publicationDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'publicationDate');
    });
  }

  QueryBuilder<Episode, int?, QQueryOperations> seasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'season');
    });
  }

  QueryBuilder<Episode, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<Episode, EpisodeType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEpisodeStatsCollection on Isar {
  IsarCollection<EpisodeStats> get episodeStats => this.collection();
}

const EpisodeStatsSchema = CollectionSchema(
  name: r'EpisodeStats',
  id: 8824763149003936592,
  properties: {
    r'completeCount': PropertySchema(
      id: 0,
      name: r'completeCount',
      type: IsarType.long,
    ),
    r'downloadedTime': PropertySchema(
      id: 1,
      name: r'downloadedTime',
      type: IsarType.dateTime,
    ),
    r'durationMS': PropertySchema(
      id: 2,
      name: r'durationMS',
      type: IsarType.long,
    ),
    r'inQueue': PropertySchema(
      id: 3,
      name: r'inQueue',
      type: IsarType.bool,
    ),
    r'lastPlayedAt': PropertySchema(
      id: 4,
      name: r'lastPlayedAt',
      type: IsarType.dateTime,
    ),
    r'pid': PropertySchema(
      id: 5,
      name: r'pid',
      type: IsarType.long,
    ),
    r'playCount': PropertySchema(
      id: 6,
      name: r'playCount',
      type: IsarType.long,
    ),
    r'playTotalMS': PropertySchema(
      id: 7,
      name: r'playTotalMS',
      type: IsarType.long,
    ),
    r'played': PropertySchema(
      id: 8,
      name: r'played',
      type: IsarType.bool,
    ),
    r'positionMS': PropertySchema(
      id: 9,
      name: r'positionMS',
      type: IsarType.long,
    )
  },
  estimateSize: _episodeStatsEstimateSize,
  serialize: _episodeStatsSerialize,
  deserialize: _episodeStatsDeserialize,
  deserializeProp: _episodeStatsDeserializeProp,
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
    r'played': IndexSchema(
      id: 2181219931364678477,
      name: r'played',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'played',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'inQueue': IndexSchema(
      id: 8111862656609435752,
      name: r'inQueue',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'inQueue',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'downloadedTime': IndexSchema(
      id: -2690293643392173367,
      name: r'downloadedTime',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'downloadedTime',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'lastPlayedAt': IndexSchema(
      id: 1709968845012040220,
      name: r'lastPlayedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'lastPlayedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _episodeStatsGetId,
  getLinks: _episodeStatsGetLinks,
  attach: _episodeStatsAttach,
  version: '3.1.0+1',
);

int _episodeStatsEstimateSize(
  EpisodeStats object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _episodeStatsSerialize(
  EpisodeStats object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.completeCount);
  writer.writeDateTime(offsets[1], object.downloadedTime);
  writer.writeLong(offsets[2], object.durationMS);
  writer.writeBool(offsets[3], object.inQueue);
  writer.writeDateTime(offsets[4], object.lastPlayedAt);
  writer.writeLong(offsets[5], object.pid);
  writer.writeLong(offsets[6], object.playCount);
  writer.writeLong(offsets[7], object.playTotalMS);
  writer.writeBool(offsets[8], object.played);
  writer.writeLong(offsets[9], object.positionMS);
}

EpisodeStats _episodeStatsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EpisodeStats(
    completeCount: reader.readLongOrNull(offsets[0]) ?? 0,
    downloadedTime: reader.readDateTimeOrNull(offsets[1]),
    durationMS: reader.readLongOrNull(offsets[2]),
    id: id,
    inQueue: reader.readBoolOrNull(offsets[3]) ?? false,
    lastPlayedAt: reader.readDateTimeOrNull(offsets[4]),
    pid: reader.readLong(offsets[5]),
    playCount: reader.readLongOrNull(offsets[6]) ?? 0,
    playTotalMS: reader.readLongOrNull(offsets[7]) ?? 0,
    played: reader.readBoolOrNull(offsets[8]) ?? false,
    positionMS: reader.readLongOrNull(offsets[9]) ?? 0,
  );
  return object;
}

P _episodeStatsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 7:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 8:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 9:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _episodeStatsGetId(EpisodeStats object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _episodeStatsGetLinks(EpisodeStats object) {
  return [];
}

void _episodeStatsAttach(
    IsarCollection<dynamic> col, Id id, EpisodeStats object) {}

extension EpisodeStatsQueryWhereSort
    on QueryBuilder<EpisodeStats, EpisodeStats, QWhere> {
  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhere> anyPid() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'pid'),
      );
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhere> anyPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'played'),
      );
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhere> anyInQueue() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'inQueue'),
      );
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhere> anyDownloadedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'downloadedTime'),
      );
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhere> anyLastPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'lastPlayedAt'),
      );
    });
  }
}

extension EpisodeStatsQueryWhere
    on QueryBuilder<EpisodeStats, EpisodeStats, QWhereClause> {
  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause> idBetween(
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

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause> pidEqualTo(
      int pid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pid',
        value: [pid],
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause> pidNotEqualTo(
      int pid) {
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

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause> pidGreaterThan(
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

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause> pidLessThan(
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

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause> pidBetween(
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

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause> playedEqualTo(
      bool played) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'played',
        value: [played],
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause> playedNotEqualTo(
      bool played) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'played',
              lower: [],
              upper: [played],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'played',
              lower: [played],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'played',
              lower: [played],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'played',
              lower: [],
              upper: [played],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause> inQueueEqualTo(
      bool inQueue) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'inQueue',
        value: [inQueue],
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause> inQueueNotEqualTo(
      bool inQueue) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'inQueue',
              lower: [],
              upper: [inQueue],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'inQueue',
              lower: [inQueue],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'inQueue',
              lower: [inQueue],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'inQueue',
              lower: [],
              upper: [inQueue],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause>
      downloadedTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'downloadedTime',
        value: [null],
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause>
      downloadedTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'downloadedTime',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause>
      downloadedTimeEqualTo(DateTime? downloadedTime) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'downloadedTime',
        value: [downloadedTime],
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause>
      downloadedTimeNotEqualTo(DateTime? downloadedTime) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'downloadedTime',
              lower: [],
              upper: [downloadedTime],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'downloadedTime',
              lower: [downloadedTime],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'downloadedTime',
              lower: [downloadedTime],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'downloadedTime',
              lower: [],
              upper: [downloadedTime],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause>
      downloadedTimeGreaterThan(
    DateTime? downloadedTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'downloadedTime',
        lower: [downloadedTime],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause>
      downloadedTimeLessThan(
    DateTime? downloadedTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'downloadedTime',
        lower: [],
        upper: [downloadedTime],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause>
      downloadedTimeBetween(
    DateTime? lowerDownloadedTime,
    DateTime? upperDownloadedTime, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'downloadedTime',
        lower: [lowerDownloadedTime],
        includeLower: includeLower,
        upper: [upperDownloadedTime],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause>
      lastPlayedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lastPlayedAt',
        value: [null],
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause>
      lastPlayedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastPlayedAt',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause>
      lastPlayedAtEqualTo(DateTime? lastPlayedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lastPlayedAt',
        value: [lastPlayedAt],
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause>
      lastPlayedAtNotEqualTo(DateTime? lastPlayedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastPlayedAt',
              lower: [],
              upper: [lastPlayedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastPlayedAt',
              lower: [lastPlayedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastPlayedAt',
              lower: [lastPlayedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastPlayedAt',
              lower: [],
              upper: [lastPlayedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause>
      lastPlayedAtGreaterThan(
    DateTime? lastPlayedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastPlayedAt',
        lower: [lastPlayedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause>
      lastPlayedAtLessThan(
    DateTime? lastPlayedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastPlayedAt',
        lower: [],
        upper: [lastPlayedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterWhereClause>
      lastPlayedAtBetween(
    DateTime? lowerLastPlayedAt,
    DateTime? upperLastPlayedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastPlayedAt',
        lower: [lowerLastPlayedAt],
        includeLower: includeLower,
        upper: [upperLastPlayedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension EpisodeStatsQueryFilter
    on QueryBuilder<EpisodeStats, EpisodeStats, QFilterCondition> {
  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      completeCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completeCount',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      completeCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completeCount',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      completeCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completeCount',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      completeCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completeCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      downloadedTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'downloadedTime',
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      downloadedTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'downloadedTime',
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      downloadedTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downloadedTime',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      downloadedTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'downloadedTime',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      downloadedTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'downloadedTime',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      downloadedTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'downloadedTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      durationMSIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'durationMS',
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      durationMSIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'durationMS',
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      durationMSEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationMS',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      durationMSGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationMS',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      durationMSLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationMS',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      durationMSBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationMS',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition> idBetween(
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

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      inQueueEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inQueue',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      lastPlayedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastPlayedAt',
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      lastPlayedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastPlayedAt',
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      lastPlayedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPlayedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      lastPlayedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPlayedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      lastPlayedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPlayedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      lastPlayedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPlayedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition> pidEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pid',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      pidGreaterThan(
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

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition> pidLessThan(
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

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition> pidBetween(
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

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      playCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playCount',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      playCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playCount',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      playCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playCount',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      playCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      playTotalMSEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playTotalMS',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      playTotalMSGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playTotalMS',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      playTotalMSLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playTotalMS',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      playTotalMSBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playTotalMS',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition> playedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'played',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      positionMSEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'positionMS',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      positionMSGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'positionMS',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      positionMSLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'positionMS',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterFilterCondition>
      positionMSBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'positionMS',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension EpisodeStatsQueryObject
    on QueryBuilder<EpisodeStats, EpisodeStats, QFilterCondition> {}

extension EpisodeStatsQueryLinks
    on QueryBuilder<EpisodeStats, EpisodeStats, QFilterCondition> {}

extension EpisodeStatsQuerySortBy
    on QueryBuilder<EpisodeStats, EpisodeStats, QSortBy> {
  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> sortByCompleteCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completeCount', Sort.asc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy>
      sortByCompleteCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completeCount', Sort.desc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy>
      sortByDownloadedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadedTime', Sort.asc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy>
      sortByDownloadedTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadedTime', Sort.desc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> sortByDurationMS() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMS', Sort.asc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy>
      sortByDurationMSDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMS', Sort.desc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> sortByInQueue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inQueue', Sort.asc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> sortByInQueueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inQueue', Sort.desc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> sortByLastPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.asc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy>
      sortByLastPlayedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.desc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> sortByPid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pid', Sort.asc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> sortByPidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pid', Sort.desc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> sortByPlayCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.asc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> sortByPlayCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.desc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> sortByPlayTotalMS() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playTotalMS', Sort.asc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy>
      sortByPlayTotalMSDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playTotalMS', Sort.desc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> sortByPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'played', Sort.asc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> sortByPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'played', Sort.desc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> sortByPositionMS() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMS', Sort.asc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy>
      sortByPositionMSDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMS', Sort.desc);
    });
  }
}

extension EpisodeStatsQuerySortThenBy
    on QueryBuilder<EpisodeStats, EpisodeStats, QSortThenBy> {
  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> thenByCompleteCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completeCount', Sort.asc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy>
      thenByCompleteCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completeCount', Sort.desc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy>
      thenByDownloadedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadedTime', Sort.asc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy>
      thenByDownloadedTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadedTime', Sort.desc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> thenByDurationMS() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMS', Sort.asc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy>
      thenByDurationMSDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMS', Sort.desc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> thenByInQueue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inQueue', Sort.asc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> thenByInQueueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inQueue', Sort.desc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> thenByLastPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.asc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy>
      thenByLastPlayedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.desc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> thenByPid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pid', Sort.asc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> thenByPidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pid', Sort.desc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> thenByPlayCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.asc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> thenByPlayCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.desc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> thenByPlayTotalMS() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playTotalMS', Sort.asc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy>
      thenByPlayTotalMSDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playTotalMS', Sort.desc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> thenByPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'played', Sort.asc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> thenByPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'played', Sort.desc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy> thenByPositionMS() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMS', Sort.asc);
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QAfterSortBy>
      thenByPositionMSDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMS', Sort.desc);
    });
  }
}

extension EpisodeStatsQueryWhereDistinct
    on QueryBuilder<EpisodeStats, EpisodeStats, QDistinct> {
  QueryBuilder<EpisodeStats, EpisodeStats, QDistinct>
      distinctByCompleteCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completeCount');
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QDistinct>
      distinctByDownloadedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'downloadedTime');
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QDistinct> distinctByDurationMS() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationMS');
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QDistinct> distinctByInQueue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inQueue');
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QDistinct> distinctByLastPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPlayedAt');
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QDistinct> distinctByPid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pid');
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QDistinct> distinctByPlayCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playCount');
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QDistinct> distinctByPlayTotalMS() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playTotalMS');
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QDistinct> distinctByPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'played');
    });
  }

  QueryBuilder<EpisodeStats, EpisodeStats, QDistinct> distinctByPositionMS() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'positionMS');
    });
  }
}

extension EpisodeStatsQueryProperty
    on QueryBuilder<EpisodeStats, EpisodeStats, QQueryProperty> {
  QueryBuilder<EpisodeStats, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<EpisodeStats, int, QQueryOperations> completeCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completeCount');
    });
  }

  QueryBuilder<EpisodeStats, DateTime?, QQueryOperations>
      downloadedTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'downloadedTime');
    });
  }

  QueryBuilder<EpisodeStats, int?, QQueryOperations> durationMSProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationMS');
    });
  }

  QueryBuilder<EpisodeStats, bool, QQueryOperations> inQueueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inQueue');
    });
  }

  QueryBuilder<EpisodeStats, DateTime?, QQueryOperations>
      lastPlayedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPlayedAt');
    });
  }

  QueryBuilder<EpisodeStats, int, QQueryOperations> pidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pid');
    });
  }

  QueryBuilder<EpisodeStats, int, QQueryOperations> playCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playCount');
    });
  }

  QueryBuilder<EpisodeStats, int, QQueryOperations> playTotalMSProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playTotalMS');
    });
  }

  QueryBuilder<EpisodeStats, bool, QQueryOperations> playedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'played');
    });
  }

  QueryBuilder<EpisodeStats, int, QQueryOperations> positionMSProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'positionMS');
    });
  }
}
