// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcript_segment_table.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTranscriptSegmentCollection on Isar {
  IsarCollection<TranscriptSegment> get transcriptSegments => this.collection();
}

const TranscriptSegmentSchema = CollectionSchema(
  name: r'TranscriptSegment',
  id: 4875653609457479542,
  properties: {
    r'body': PropertySchema(id: 0, name: r'body', type: IsarType.string),
    r'endMs': PropertySchema(id: 1, name: r'endMs', type: IsarType.long),
    r'speaker': PropertySchema(id: 2, name: r'speaker', type: IsarType.string),
    r'startMs': PropertySchema(id: 3, name: r'startMs', type: IsarType.long),
    r'transcriptId': PropertySchema(
      id: 4,
      name: r'transcriptId',
      type: IsarType.long,
    ),
  },

  estimateSize: _transcriptSegmentEstimateSize,
  serialize: _transcriptSegmentSerialize,
  deserialize: _transcriptSegmentDeserialize,
  deserializeProp: _transcriptSegmentDeserializeProp,
  idName: r'id',
  indexes: {
    r'transcriptId': IndexSchema(
      id: 711949514161034553,
      name: r'transcriptId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'transcriptId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'startMs': IndexSchema(
      id: -105008981359880260,
      name: r'startMs',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'startMs',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _transcriptSegmentGetId,
  getLinks: _transcriptSegmentGetLinks,
  attach: _transcriptSegmentAttach,
  version: '3.3.0',
);

int _transcriptSegmentEstimateSize(
  TranscriptSegment object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.body.length * 3;
  {
    final value = object.speaker;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _transcriptSegmentSerialize(
  TranscriptSegment object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.body);
  writer.writeLong(offsets[1], object.endMs);
  writer.writeString(offsets[2], object.speaker);
  writer.writeLong(offsets[3], object.startMs);
  writer.writeLong(offsets[4], object.transcriptId);
}

TranscriptSegment _transcriptSegmentDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TranscriptSegment();
  object.body = reader.readString(offsets[0]);
  object.endMs = reader.readLong(offsets[1]);
  object.id = id;
  object.speaker = reader.readStringOrNull(offsets[2]);
  object.startMs = reader.readLong(offsets[3]);
  object.transcriptId = reader.readLong(offsets[4]);
  return object;
}

P _transcriptSegmentDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _transcriptSegmentGetId(TranscriptSegment object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _transcriptSegmentGetLinks(
  TranscriptSegment object,
) {
  return [];
}

void _transcriptSegmentAttach(
  IsarCollection<dynamic> col,
  Id id,
  TranscriptSegment object,
) {
  object.id = id;
}

extension TranscriptSegmentQueryWhereSort
    on QueryBuilder<TranscriptSegment, TranscriptSegment, QWhere> {
  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterWhere>
  anyTranscriptId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'transcriptId'),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterWhere> anyStartMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'startMs'),
      );
    });
  }
}

extension TranscriptSegmentQueryWhere
    on QueryBuilder<TranscriptSegment, TranscriptSegment, QWhereClause> {
  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterWhereClause>
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

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterWhereClause>
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

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterWhereClause>
  transcriptIdEqualTo(int transcriptId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'transcriptId',
          value: [transcriptId],
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterWhereClause>
  transcriptIdNotEqualTo(int transcriptId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transcriptId',
                lower: [],
                upper: [transcriptId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transcriptId',
                lower: [transcriptId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transcriptId',
                lower: [transcriptId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transcriptId',
                lower: [],
                upper: [transcriptId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterWhereClause>
  transcriptIdGreaterThan(int transcriptId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'transcriptId',
          lower: [transcriptId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterWhereClause>
  transcriptIdLessThan(int transcriptId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'transcriptId',
          lower: [],
          upper: [transcriptId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterWhereClause>
  transcriptIdBetween(
    int lowerTranscriptId,
    int upperTranscriptId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'transcriptId',
          lower: [lowerTranscriptId],
          includeLower: includeLower,
          upper: [upperTranscriptId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterWhereClause>
  startMsEqualTo(int startMs) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'startMs', value: [startMs]),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterWhereClause>
  startMsNotEqualTo(int startMs) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startMs',
                lower: [],
                upper: [startMs],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startMs',
                lower: [startMs],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startMs',
                lower: [startMs],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startMs',
                lower: [],
                upper: [startMs],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterWhereClause>
  startMsGreaterThan(int startMs, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'startMs',
          lower: [startMs],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterWhereClause>
  startMsLessThan(int startMs, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'startMs',
          lower: [],
          upper: [startMs],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterWhereClause>
  startMsBetween(
    int lowerStartMs,
    int upperStartMs, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'startMs',
          lower: [lowerStartMs],
          includeLower: includeLower,
          upper: [upperStartMs],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension TranscriptSegmentQueryFilter
    on QueryBuilder<TranscriptSegment, TranscriptSegment, QFilterCondition> {
  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  bodyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'body',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  bodyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'body',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  bodyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'body',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  bodyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'body',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  bodyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'body',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  bodyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'body',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  bodyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'body',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  bodyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'body',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  bodyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'body', value: ''),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  bodyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'body', value: ''),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  endMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'endMs', value: value),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  endMsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'endMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  endMsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'endMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  endMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'endMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
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

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
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

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
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

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  speakerIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'speaker'),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  speakerIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'speaker'),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  speakerEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'speaker',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  speakerGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'speaker',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  speakerLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'speaker',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  speakerBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'speaker',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  speakerStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'speaker',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  speakerEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'speaker',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  speakerContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'speaker',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  speakerMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'speaker',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  speakerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'speaker', value: ''),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  speakerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'speaker', value: ''),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  startMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startMs', value: value),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  startMsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  startMsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  startMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  transcriptIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'transcriptId', value: value),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  transcriptIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'transcriptId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  transcriptIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'transcriptId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterFilterCondition>
  transcriptIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'transcriptId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension TranscriptSegmentQueryObject
    on QueryBuilder<TranscriptSegment, TranscriptSegment, QFilterCondition> {}

extension TranscriptSegmentQueryLinks
    on QueryBuilder<TranscriptSegment, TranscriptSegment, QFilterCondition> {}

extension TranscriptSegmentQuerySortBy
    on QueryBuilder<TranscriptSegment, TranscriptSegment, QSortBy> {
  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterSortBy>
  sortByBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.asc);
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterSortBy>
  sortByBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.desc);
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterSortBy>
  sortByEndMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMs', Sort.asc);
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterSortBy>
  sortByEndMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMs', Sort.desc);
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterSortBy>
  sortBySpeaker() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speaker', Sort.asc);
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterSortBy>
  sortBySpeakerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speaker', Sort.desc);
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterSortBy>
  sortByStartMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMs', Sort.asc);
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterSortBy>
  sortByStartMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMs', Sort.desc);
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterSortBy>
  sortByTranscriptId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transcriptId', Sort.asc);
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterSortBy>
  sortByTranscriptIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transcriptId', Sort.desc);
    });
  }
}

extension TranscriptSegmentQuerySortThenBy
    on QueryBuilder<TranscriptSegment, TranscriptSegment, QSortThenBy> {
  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterSortBy>
  thenByBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.asc);
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterSortBy>
  thenByBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.desc);
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterSortBy>
  thenByEndMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMs', Sort.asc);
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterSortBy>
  thenByEndMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMs', Sort.desc);
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterSortBy>
  thenBySpeaker() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speaker', Sort.asc);
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterSortBy>
  thenBySpeakerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speaker', Sort.desc);
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterSortBy>
  thenByStartMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMs', Sort.asc);
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterSortBy>
  thenByStartMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMs', Sort.desc);
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterSortBy>
  thenByTranscriptId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transcriptId', Sort.asc);
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QAfterSortBy>
  thenByTranscriptIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transcriptId', Sort.desc);
    });
  }
}

extension TranscriptSegmentQueryWhereDistinct
    on QueryBuilder<TranscriptSegment, TranscriptSegment, QDistinct> {
  QueryBuilder<TranscriptSegment, TranscriptSegment, QDistinct> distinctByBody({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'body', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QDistinct>
  distinctByEndMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endMs');
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QDistinct>
  distinctBySpeaker({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'speaker', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QDistinct>
  distinctByStartMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startMs');
    });
  }

  QueryBuilder<TranscriptSegment, TranscriptSegment, QDistinct>
  distinctByTranscriptId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'transcriptId');
    });
  }
}

extension TranscriptSegmentQueryProperty
    on QueryBuilder<TranscriptSegment, TranscriptSegment, QQueryProperty> {
  QueryBuilder<TranscriptSegment, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TranscriptSegment, String, QQueryOperations> bodyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'body');
    });
  }

  QueryBuilder<TranscriptSegment, int, QQueryOperations> endMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endMs');
    });
  }

  QueryBuilder<TranscriptSegment, String?, QQueryOperations> speakerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'speaker');
    });
  }

  QueryBuilder<TranscriptSegment, int, QQueryOperations> startMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startMs');
    });
  }

  QueryBuilder<TranscriptSegment, int, QQueryOperations>
  transcriptIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transcriptId');
    });
  }
}
