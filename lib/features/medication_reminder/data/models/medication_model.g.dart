// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMedicationCollection on Isar {
  IsarCollection<Medication> get medications => this.collection();
}

const MedicationSchema = CollectionSchema(
  name: r'Medication',
  id: -2541039227040579663,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'doctorName': PropertySchema(
      id: 1,
      name: r'doctorName',
      type: IsarType.string,
    ),
    r'dosage': PropertySchema(
      id: 2,
      name: r'dosage',
      type: IsarType.string,
    ),
    r'endDate': PropertySchema(
      id: 3,
      name: r'endDate',
      type: IsarType.dateTime,
    ),
    r'foodTiming': PropertySchema(
      id: 4,
      name: r'foodTiming',
      type: IsarType.string,
    ),
    r'frequencyType': PropertySchema(
      id: 5,
      name: r'frequencyType',
      type: IsarType.string,
    ),
    r'intervalValue': PropertySchema(
      id: 6,
      name: r'intervalValue',
      type: IsarType.long,
    ),
    r'isActive': PropertySchema(
      id: 7,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'name': PropertySchema(
      id: 8,
      name: r'name',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(
      id: 9,
      name: r'notes',
      type: IsarType.string,
    ),
    r'reminderTimes': PropertySchema(
      id: 10,
      name: r'reminderTimes',
      type: IsarType.objectList,
      target: r'ReminderTime',
    ),
    r'startDate': PropertySchema(
      id: 11,
      name: r'startDate',
      type: IsarType.dateTime,
    ),
    r'strength': PropertySchema(
      id: 12,
      name: r'strength',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 13,
      name: r'type',
      type: IsarType.string,
    ),
    r'weekDays': PropertySchema(
      id: 14,
      name: r'weekDays',
      type: IsarType.longList,
    )
  },
  estimateSize: _medicationEstimateSize,
  serialize: _medicationSerialize,
  deserialize: _medicationDeserialize,
  deserializeProp: _medicationDeserializeProp,
  idName: r'id',
  indexes: {
    r'startDate': IndexSchema(
      id: 7723980484494730382,
      name: r'startDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'startDate',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'ReminderTime': ReminderTimeSchema},
  getId: _medicationGetId,
  getLinks: _medicationGetLinks,
  attach: _medicationAttach,
  version: '3.1.0+1',
);

int _medicationEstimateSize(
  Medication object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.doctorName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.dosage.length * 3;
  bytesCount += 3 + object.foodTiming.length * 3;
  bytesCount += 3 + object.frequencyType.length * 3;
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.reminderTimes.length * 3;
  {
    final offsets = allOffsets[ReminderTime]!;
    for (var i = 0; i < object.reminderTimes.length; i++) {
      final value = object.reminderTimes[i];
      bytesCount += ReminderTimeSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  {
    final value = object.strength;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.type.length * 3;
  {
    final value = object.weekDays;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  return bytesCount;
}

void _medicationSerialize(
  Medication object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.doctorName);
  writer.writeString(offsets[2], object.dosage);
  writer.writeDateTime(offsets[3], object.endDate);
  writer.writeString(offsets[4], object.foodTiming);
  writer.writeString(offsets[5], object.frequencyType);
  writer.writeLong(offsets[6], object.intervalValue);
  writer.writeBool(offsets[7], object.isActive);
  writer.writeString(offsets[8], object.name);
  writer.writeString(offsets[9], object.notes);
  writer.writeObjectList<ReminderTime>(
    offsets[10],
    allOffsets,
    ReminderTimeSchema.serialize,
    object.reminderTimes,
  );
  writer.writeDateTime(offsets[11], object.startDate);
  writer.writeString(offsets[12], object.strength);
  writer.writeString(offsets[13], object.type);
  writer.writeLongList(offsets[14], object.weekDays);
}

Medication _medicationDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Medication();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.doctorName = reader.readStringOrNull(offsets[1]);
  object.dosage = reader.readString(offsets[2]);
  object.endDate = reader.readDateTimeOrNull(offsets[3]);
  object.foodTiming = reader.readString(offsets[4]);
  object.frequencyType = reader.readString(offsets[5]);
  object.id = id;
  object.intervalValue = reader.readLongOrNull(offsets[6]);
  object.isActive = reader.readBool(offsets[7]);
  object.name = reader.readString(offsets[8]);
  object.notes = reader.readStringOrNull(offsets[9]);
  object.reminderTimes = reader.readObjectList<ReminderTime>(
        offsets[10],
        ReminderTimeSchema.deserialize,
        allOffsets,
        ReminderTime(),
      ) ??
      [];
  object.startDate = reader.readDateTime(offsets[11]);
  object.strength = reader.readStringOrNull(offsets[12]);
  object.type = reader.readString(offsets[13]);
  object.weekDays = reader.readLongList(offsets[14]);
  return object;
}

P _medicationDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readObjectList<ReminderTime>(
            offset,
            ReminderTimeSchema.deserialize,
            allOffsets,
            ReminderTime(),
          ) ??
          []) as P;
    case 11:
      return (reader.readDateTime(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readLongList(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _medicationGetId(Medication object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _medicationGetLinks(Medication object) {
  return [];
}

void _medicationAttach(IsarCollection<dynamic> col, Id id, Medication object) {
  object.id = id;
}

extension MedicationQueryWhereSort
    on QueryBuilder<Medication, Medication, QWhere> {
  QueryBuilder<Medication, Medication, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Medication, Medication, QAfterWhere> anyStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'startDate'),
      );
    });
  }
}

extension MedicationQueryWhere
    on QueryBuilder<Medication, Medication, QWhereClause> {
  QueryBuilder<Medication, Medication, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Medication, Medication, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Medication, Medication, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Medication, Medication, QAfterWhereClause> idBetween(
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

  QueryBuilder<Medication, Medication, QAfterWhereClause> startDateEqualTo(
      DateTime startDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'startDate',
        value: [startDate],
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterWhereClause> startDateNotEqualTo(
      DateTime startDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startDate',
              lower: [],
              upper: [startDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startDate',
              lower: [startDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startDate',
              lower: [startDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startDate',
              lower: [],
              upper: [startDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Medication, Medication, QAfterWhereClause> startDateGreaterThan(
    DateTime startDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startDate',
        lower: [startDate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterWhereClause> startDateLessThan(
    DateTime startDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startDate',
        lower: [],
        upper: [startDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterWhereClause> startDateBetween(
    DateTime lowerStartDate,
    DateTime upperStartDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startDate',
        lower: [lowerStartDate],
        includeLower: includeLower,
        upper: [upperStartDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MedicationQueryFilter
    on QueryBuilder<Medication, Medication, QFilterCondition> {
  QueryBuilder<Medication, Medication, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      doctorNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'doctorName',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      doctorNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'doctorName',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> doctorNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'doctorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      doctorNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'doctorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      doctorNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'doctorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> doctorNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'doctorName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      doctorNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'doctorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      doctorNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'doctorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      doctorNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'doctorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> doctorNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'doctorName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      doctorNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'doctorName',
        value: '',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      doctorNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'doctorName',
        value: '',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> dosageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> dosageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> dosageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> dosageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dosage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> dosageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> dosageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> dosageContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> dosageMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dosage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> dosageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dosage',
        value: '',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      dosageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dosage',
        value: '',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> endDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endDate',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      endDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endDate',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> endDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      endDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> endDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> endDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> foodTimingEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'foodTiming',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      foodTimingGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'foodTiming',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      foodTimingLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'foodTiming',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> foodTimingBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'foodTiming',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      foodTimingStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'foodTiming',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      foodTimingEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'foodTiming',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      foodTimingContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'foodTiming',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> foodTimingMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'foodTiming',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      foodTimingIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'foodTiming',
        value: '',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      foodTimingIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'foodTiming',
        value: '',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      frequencyTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frequencyType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      frequencyTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'frequencyType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      frequencyTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'frequencyType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      frequencyTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'frequencyType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      frequencyTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'frequencyType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      frequencyTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'frequencyType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      frequencyTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'frequencyType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      frequencyTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'frequencyType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      frequencyTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frequencyType',
        value: '',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      frequencyTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'frequencyType',
        value: '',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Medication, Medication, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Medication, Medication, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      intervalValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'intervalValue',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      intervalValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'intervalValue',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      intervalValueEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'intervalValue',
        value: value,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      intervalValueGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'intervalValue',
        value: value,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      intervalValueLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'intervalValue',
        value: value,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      intervalValueBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'intervalValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> isActiveEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> notesContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> notesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      reminderTimesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reminderTimes',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      reminderTimesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reminderTimes',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      reminderTimesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reminderTimes',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      reminderTimesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reminderTimes',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      reminderTimesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reminderTimes',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      reminderTimesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reminderTimes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> startDateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      startDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> startDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> startDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> strengthIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'strength',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      strengthIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'strength',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> strengthEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'strength',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      strengthGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'strength',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> strengthLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'strength',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> strengthBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'strength',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      strengthStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'strength',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> strengthEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'strength',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> strengthContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'strength',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> strengthMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'strength',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      strengthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'strength',
        value: '',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      strengthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'strength',
        value: '',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> typeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> typeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> typeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition> weekDaysIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'weekDays',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      weekDaysIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'weekDays',
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      weekDaysElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weekDays',
        value: value,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      weekDaysElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weekDays',
        value: value,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      weekDaysElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weekDays',
        value: value,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      weekDaysElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weekDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      weekDaysLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weekDays',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      weekDaysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weekDays',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      weekDaysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weekDays',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      weekDaysLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weekDays',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      weekDaysLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weekDays',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      weekDaysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weekDays',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension MedicationQueryObject
    on QueryBuilder<Medication, Medication, QFilterCondition> {
  QueryBuilder<Medication, Medication, QAfterFilterCondition>
      reminderTimesElement(FilterQuery<ReminderTime> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'reminderTimes');
    });
  }
}

extension MedicationQueryLinks
    on QueryBuilder<Medication, Medication, QFilterCondition> {}

extension MedicationQuerySortBy
    on QueryBuilder<Medication, Medication, QSortBy> {
  QueryBuilder<Medication, Medication, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> sortByDoctorName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doctorName', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> sortByDoctorNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doctorName', Sort.desc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> sortByDosage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dosage', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> sortByDosageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dosage', Sort.desc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> sortByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> sortByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> sortByFoodTiming() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foodTiming', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> sortByFoodTimingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foodTiming', Sort.desc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> sortByFrequencyType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequencyType', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> sortByFrequencyTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequencyType', Sort.desc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> sortByIntervalValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalValue', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> sortByIntervalValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalValue', Sort.desc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> sortByStrength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strength', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> sortByStrengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strength', Sort.desc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension MedicationQuerySortThenBy
    on QueryBuilder<Medication, Medication, QSortThenBy> {
  QueryBuilder<Medication, Medication, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenByDoctorName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doctorName', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenByDoctorNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doctorName', Sort.desc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenByDosage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dosage', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenByDosageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dosage', Sort.desc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenByFoodTiming() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foodTiming', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenByFoodTimingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foodTiming', Sort.desc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenByFrequencyType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequencyType', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenByFrequencyTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequencyType', Sort.desc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenByIntervalValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalValue', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenByIntervalValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalValue', Sort.desc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenByStrength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strength', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenByStrengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strength', Sort.desc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<Medication, Medication, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension MedicationQueryWhereDistinct
    on QueryBuilder<Medication, Medication, QDistinct> {
  QueryBuilder<Medication, Medication, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Medication, Medication, QDistinct> distinctByDoctorName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'doctorName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Medication, Medication, QDistinct> distinctByDosage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dosage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Medication, Medication, QDistinct> distinctByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endDate');
    });
  }

  QueryBuilder<Medication, Medication, QDistinct> distinctByFoodTiming(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'foodTiming', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Medication, Medication, QDistinct> distinctByFrequencyType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'frequencyType',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Medication, Medication, QDistinct> distinctByIntervalValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'intervalValue');
    });
  }

  QueryBuilder<Medication, Medication, QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<Medication, Medication, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Medication, Medication, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Medication, Medication, QDistinct> distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate');
    });
  }

  QueryBuilder<Medication, Medication, QDistinct> distinctByStrength(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'strength', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Medication, Medication, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Medication, Medication, QDistinct> distinctByWeekDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weekDays');
    });
  }
}

extension MedicationQueryProperty
    on QueryBuilder<Medication, Medication, QQueryProperty> {
  QueryBuilder<Medication, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Medication, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Medication, String?, QQueryOperations> doctorNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'doctorName');
    });
  }

  QueryBuilder<Medication, String, QQueryOperations> dosageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dosage');
    });
  }

  QueryBuilder<Medication, DateTime?, QQueryOperations> endDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endDate');
    });
  }

  QueryBuilder<Medication, String, QQueryOperations> foodTimingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'foodTiming');
    });
  }

  QueryBuilder<Medication, String, QQueryOperations> frequencyTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'frequencyType');
    });
  }

  QueryBuilder<Medication, int?, QQueryOperations> intervalValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'intervalValue');
    });
  }

  QueryBuilder<Medication, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<Medication, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Medication, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<Medication, List<ReminderTime>, QQueryOperations>
      reminderTimesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderTimes');
    });
  }

  QueryBuilder<Medication, DateTime, QQueryOperations> startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }

  QueryBuilder<Medication, String?, QQueryOperations> strengthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'strength');
    });
  }

  QueryBuilder<Medication, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<Medication, List<int>?, QQueryOperations> weekDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weekDays');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMedicationLogCollection on Isar {
  IsarCollection<MedicationLog> get medicationLogs => this.collection();
}

const MedicationLogSchema = CollectionSchema(
  name: r'MedicationLog',
  id: 1536858489241207630,
  properties: {
    r'actualTime': PropertySchema(
      id: 0,
      name: r'actualTime',
      type: IsarType.dateTime,
    ),
    r'medicationId': PropertySchema(
      id: 1,
      name: r'medicationId',
      type: IsarType.long,
    ),
    r'medicationName': PropertySchema(
      id: 2,
      name: r'medicationName',
      type: IsarType.string,
    ),
    r'note': PropertySchema(
      id: 3,
      name: r'note',
      type: IsarType.string,
    ),
    r'scheduledTime': PropertySchema(
      id: 4,
      name: r'scheduledTime',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(
      id: 5,
      name: r'status',
      type: IsarType.string,
    )
  },
  estimateSize: _medicationLogEstimateSize,
  serialize: _medicationLogSerialize,
  deserialize: _medicationLogDeserialize,
  deserializeProp: _medicationLogDeserializeProp,
  idName: r'id',
  indexes: {
    r'medicationId': IndexSchema(
      id: -3054361819135306882,
      name: r'medicationId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'medicationId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'scheduledTime': IndexSchema(
      id: 4528483578431344364,
      name: r'scheduledTime',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'scheduledTime',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _medicationLogGetId,
  getLinks: _medicationLogGetLinks,
  attach: _medicationLogAttach,
  version: '3.1.0+1',
);

int _medicationLogEstimateSize(
  MedicationLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.medicationName.length * 3;
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.length * 3;
  return bytesCount;
}

void _medicationLogSerialize(
  MedicationLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.actualTime);
  writer.writeLong(offsets[1], object.medicationId);
  writer.writeString(offsets[2], object.medicationName);
  writer.writeString(offsets[3], object.note);
  writer.writeDateTime(offsets[4], object.scheduledTime);
  writer.writeString(offsets[5], object.status);
}

MedicationLog _medicationLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MedicationLog();
  object.actualTime = reader.readDateTimeOrNull(offsets[0]);
  object.id = id;
  object.medicationId = reader.readLong(offsets[1]);
  object.medicationName = reader.readString(offsets[2]);
  object.note = reader.readStringOrNull(offsets[3]);
  object.scheduledTime = reader.readDateTime(offsets[4]);
  object.status = reader.readString(offsets[5]);
  return object;
}

P _medicationLogDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _medicationLogGetId(MedicationLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _medicationLogGetLinks(MedicationLog object) {
  return [];
}

void _medicationLogAttach(
    IsarCollection<dynamic> col, Id id, MedicationLog object) {
  object.id = id;
}

extension MedicationLogQueryWhereSort
    on QueryBuilder<MedicationLog, MedicationLog, QWhere> {
  QueryBuilder<MedicationLog, MedicationLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterWhere> anyMedicationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'medicationId'),
      );
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterWhere> anyScheduledTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'scheduledTime'),
      );
    });
  }
}

extension MedicationLogQueryWhere
    on QueryBuilder<MedicationLog, MedicationLog, QWhereClause> {
  QueryBuilder<MedicationLog, MedicationLog, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<MedicationLog, MedicationLog, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterWhereClause> idBetween(
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

  QueryBuilder<MedicationLog, MedicationLog, QAfterWhereClause>
      medicationIdEqualTo(int medicationId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'medicationId',
        value: [medicationId],
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterWhereClause>
      medicationIdNotEqualTo(int medicationId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'medicationId',
              lower: [],
              upper: [medicationId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'medicationId',
              lower: [medicationId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'medicationId',
              lower: [medicationId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'medicationId',
              lower: [],
              upper: [medicationId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterWhereClause>
      medicationIdGreaterThan(
    int medicationId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'medicationId',
        lower: [medicationId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterWhereClause>
      medicationIdLessThan(
    int medicationId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'medicationId',
        lower: [],
        upper: [medicationId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterWhereClause>
      medicationIdBetween(
    int lowerMedicationId,
    int upperMedicationId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'medicationId',
        lower: [lowerMedicationId],
        includeLower: includeLower,
        upper: [upperMedicationId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterWhereClause>
      scheduledTimeEqualTo(DateTime scheduledTime) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'scheduledTime',
        value: [scheduledTime],
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterWhereClause>
      scheduledTimeNotEqualTo(DateTime scheduledTime) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scheduledTime',
              lower: [],
              upper: [scheduledTime],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scheduledTime',
              lower: [scheduledTime],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scheduledTime',
              lower: [scheduledTime],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scheduledTime',
              lower: [],
              upper: [scheduledTime],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterWhereClause>
      scheduledTimeGreaterThan(
    DateTime scheduledTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'scheduledTime',
        lower: [scheduledTime],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterWhereClause>
      scheduledTimeLessThan(
    DateTime scheduledTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'scheduledTime',
        lower: [],
        upper: [scheduledTime],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterWhereClause>
      scheduledTimeBetween(
    DateTime lowerScheduledTime,
    DateTime upperScheduledTime, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'scheduledTime',
        lower: [lowerScheduledTime],
        includeLower: includeLower,
        upper: [upperScheduledTime],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MedicationLogQueryFilter
    on QueryBuilder<MedicationLog, MedicationLog, QFilterCondition> {
  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      actualTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'actualTime',
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      actualTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'actualTime',
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      actualTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actualTime',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      actualTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actualTime',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      actualTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actualTime',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      actualTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actualTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
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

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      medicationIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'medicationId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      medicationIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'medicationId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      medicationIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'medicationId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      medicationIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'medicationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      medicationNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'medicationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      medicationNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'medicationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      medicationNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'medicationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      medicationNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'medicationName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      medicationNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'medicationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      medicationNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'medicationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      medicationNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'medicationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      medicationNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'medicationName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      medicationNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'medicationName',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      medicationNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'medicationName',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition> noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition> noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'note',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition> noteMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      scheduledTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledTime',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      scheduledTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduledTime',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      scheduledTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduledTime',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      scheduledTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduledTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }
}

extension MedicationLogQueryObject
    on QueryBuilder<MedicationLog, MedicationLog, QFilterCondition> {}

extension MedicationLogQueryLinks
    on QueryBuilder<MedicationLog, MedicationLog, QFilterCondition> {}

extension MedicationLogQuerySortBy
    on QueryBuilder<MedicationLog, MedicationLog, QSortBy> {
  QueryBuilder<MedicationLog, MedicationLog, QAfterSortBy> sortByActualTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualTime', Sort.asc);
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterSortBy>
      sortByActualTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualTime', Sort.desc);
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterSortBy>
      sortByMedicationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicationId', Sort.asc);
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterSortBy>
      sortByMedicationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicationId', Sort.desc);
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterSortBy>
      sortByMedicationName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicationName', Sort.asc);
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterSortBy>
      sortByMedicationNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicationName', Sort.desc);
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterSortBy>
      sortByScheduledTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledTime', Sort.asc);
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterSortBy>
      sortByScheduledTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledTime', Sort.desc);
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension MedicationLogQuerySortThenBy
    on QueryBuilder<MedicationLog, MedicationLog, QSortThenBy> {
  QueryBuilder<MedicationLog, MedicationLog, QAfterSortBy> thenByActualTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualTime', Sort.asc);
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterSortBy>
      thenByActualTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualTime', Sort.desc);
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterSortBy>
      thenByMedicationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicationId', Sort.asc);
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterSortBy>
      thenByMedicationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicationId', Sort.desc);
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterSortBy>
      thenByMedicationName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicationName', Sort.asc);
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterSortBy>
      thenByMedicationNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicationName', Sort.desc);
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterSortBy>
      thenByScheduledTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledTime', Sort.asc);
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterSortBy>
      thenByScheduledTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledTime', Sort.desc);
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension MedicationLogQueryWhereDistinct
    on QueryBuilder<MedicationLog, MedicationLog, QDistinct> {
  QueryBuilder<MedicationLog, MedicationLog, QDistinct> distinctByActualTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actualTime');
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QDistinct>
      distinctByMedicationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'medicationId');
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QDistinct>
      distinctByMedicationName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'medicationName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QDistinct> distinctByNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QDistinct>
      distinctByScheduledTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledTime');
    });
  }

  QueryBuilder<MedicationLog, MedicationLog, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }
}

extension MedicationLogQueryProperty
    on QueryBuilder<MedicationLog, MedicationLog, QQueryProperty> {
  QueryBuilder<MedicationLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MedicationLog, DateTime?, QQueryOperations>
      actualTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actualTime');
    });
  }

  QueryBuilder<MedicationLog, int, QQueryOperations> medicationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'medicationId');
    });
  }

  QueryBuilder<MedicationLog, String, QQueryOperations>
      medicationNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'medicationName');
    });
  }

  QueryBuilder<MedicationLog, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<MedicationLog, DateTime, QQueryOperations>
      scheduledTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledTime');
    });
  }

  QueryBuilder<MedicationLog, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const ReminderTimeSchema = Schema(
  name: r'ReminderTime',
  id: -2850666418744187622,
  properties: {
    r'hour': PropertySchema(
      id: 0,
      name: r'hour',
      type: IsarType.long,
    ),
    r'minute': PropertySchema(
      id: 1,
      name: r'minute',
      type: IsarType.long,
    )
  },
  estimateSize: _reminderTimeEstimateSize,
  serialize: _reminderTimeSerialize,
  deserialize: _reminderTimeDeserialize,
  deserializeProp: _reminderTimeDeserializeProp,
);

int _reminderTimeEstimateSize(
  ReminderTime object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _reminderTimeSerialize(
  ReminderTime object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.hour);
  writer.writeLong(offsets[1], object.minute);
}

ReminderTime _reminderTimeDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ReminderTime(
    hour: reader.readLongOrNull(offsets[0]) ?? 0,
    minute: reader.readLongOrNull(offsets[1]) ?? 0,
  );
  return object;
}

P _reminderTimeDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 1:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension ReminderTimeQueryFilter
    on QueryBuilder<ReminderTime, ReminderTime, QFilterCondition> {
  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition> hourEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hour',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition>
      hourGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hour',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition> hourLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hour',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition> hourBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition> minuteEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'minute',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition>
      minuteGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'minute',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition>
      minuteLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'minute',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition> minuteBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'minute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ReminderTimeQueryObject
    on QueryBuilder<ReminderTime, ReminderTime, QFilterCondition> {}
