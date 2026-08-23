// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLoanEntityCollection on Isar {
  IsarCollection<LoanEntity> get loanEntitys => this.collection();
}

const LoanEntitySchema = CollectionSchema(
  name: r'LoanEntity',
  id: 1414663597752982809,
  properties: {
    r'accountId': PropertySchema(
      id: 0,
      name: r'accountId',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'emiAmount': PropertySchema(
      id: 2,
      name: r'emiAmount',
      type: IsarType.double,
    ),
    r'expectedEndDate': PropertySchema(
      id: 3,
      name: r'expectedEndDate',
      type: IsarType.dateTime,
    ),
    r'interestRate': PropertySchema(
      id: 4,
      name: r'interestRate',
      type: IsarType.double,
    ),
    r'interestType': PropertySchema(
      id: 5,
      name: r'interestType',
      type: IsarType.string,
    ),
    r'lender': PropertySchema(
      id: 6,
      name: r'lender',
      type: IsarType.string,
    ),
    r'loanType': PropertySchema(
      id: 7,
      name: r'loanType',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 8,
      name: r'name',
      type: IsarType.string,
    ),
    r'nextDueDate': PropertySchema(
      id: 9,
      name: r'nextDueDate',
      type: IsarType.dateTime,
    ),
    r'notes': PropertySchema(
      id: 10,
      name: r'notes',
      type: IsarType.string,
    ),
    r'outstandingPrincipal': PropertySchema(
      id: 11,
      name: r'outstandingPrincipal',
      type: IsarType.double,
    ),
    r'paymentDay': PropertySchema(
      id: 12,
      name: r'paymentDay',
      type: IsarType.long,
    ),
    r'principalAmount': PropertySchema(
      id: 13,
      name: r'principalAmount',
      type: IsarType.double,
    ),
    r'startDate': PropertySchema(
      id: 14,
      name: r'startDate',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(
      id: 15,
      name: r'status',
      type: IsarType.string,
    ),
    r'tenureMonths': PropertySchema(
      id: 16,
      name: r'tenureMonths',
      type: IsarType.long,
    ),
    r'totalInterestPaid': PropertySchema(
      id: 17,
      name: r'totalInterestPaid',
      type: IsarType.double,
    ),
    r'totalPrincipalPaid': PropertySchema(
      id: 18,
      name: r'totalPrincipalPaid',
      type: IsarType.double,
    ),
    r'updatedAt': PropertySchema(
      id: 19,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'uuid': PropertySchema(
      id: 20,
      name: r'uuid',
      type: IsarType.string,
    )
  },
  estimateSize: _loanEntityEstimateSize,
  serialize: _loanEntitySerialize,
  deserialize: _loanEntityDeserialize,
  deserializeProp: _loanEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'uuid': IndexSchema(
      id: 2134397340427724972,
      name: r'uuid',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'uuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'lender': IndexSchema(
      id: -5934600864713985303,
      name: r'lender',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'lender',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'loanType': IndexSchema(
      id: 4357136564429865865,
      name: r'loanType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'loanType',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
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
    ),
    r'nextDueDate': IndexSchema(
      id: -1749684646791026574,
      name: r'nextDueDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'nextDueDate',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'status': IndexSchema(
      id: -107785170620420283,
      name: r'status',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'status',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _loanEntityGetId,
  getLinks: _loanEntityGetLinks,
  attach: _loanEntityAttach,
  version: '3.1.0+1',
);

int _loanEntityEstimateSize(
  LoanEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.accountId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.interestType.length * 3;
  bytesCount += 3 + object.lender.length * 3;
  bytesCount += 3 + object.loanType.length * 3;
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _loanEntitySerialize(
  LoanEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.accountId);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeDouble(offsets[2], object.emiAmount);
  writer.writeDateTime(offsets[3], object.expectedEndDate);
  writer.writeDouble(offsets[4], object.interestRate);
  writer.writeString(offsets[5], object.interestType);
  writer.writeString(offsets[6], object.lender);
  writer.writeString(offsets[7], object.loanType);
  writer.writeString(offsets[8], object.name);
  writer.writeDateTime(offsets[9], object.nextDueDate);
  writer.writeString(offsets[10], object.notes);
  writer.writeDouble(offsets[11], object.outstandingPrincipal);
  writer.writeLong(offsets[12], object.paymentDay);
  writer.writeDouble(offsets[13], object.principalAmount);
  writer.writeDateTime(offsets[14], object.startDate);
  writer.writeString(offsets[15], object.status);
  writer.writeLong(offsets[16], object.tenureMonths);
  writer.writeDouble(offsets[17], object.totalInterestPaid);
  writer.writeDouble(offsets[18], object.totalPrincipalPaid);
  writer.writeDateTime(offsets[19], object.updatedAt);
  writer.writeString(offsets[20], object.uuid);
}

LoanEntity _loanEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LoanEntity();
  object.accountId = reader.readStringOrNull(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.emiAmount = reader.readDouble(offsets[2]);
  object.expectedEndDate = reader.readDateTime(offsets[3]);
  object.id = id;
  object.interestRate = reader.readDouble(offsets[4]);
  object.interestType = reader.readString(offsets[5]);
  object.lender = reader.readString(offsets[6]);
  object.loanType = reader.readString(offsets[7]);
  object.name = reader.readString(offsets[8]);
  object.nextDueDate = reader.readDateTime(offsets[9]);
  object.notes = reader.readStringOrNull(offsets[10]);
  object.outstandingPrincipal = reader.readDouble(offsets[11]);
  object.paymentDay = reader.readLong(offsets[12]);
  object.principalAmount = reader.readDouble(offsets[13]);
  object.startDate = reader.readDateTime(offsets[14]);
  object.status = reader.readString(offsets[15]);
  object.tenureMonths = reader.readLong(offsets[16]);
  object.totalInterestPaid = reader.readDouble(offsets[17]);
  object.totalPrincipalPaid = reader.readDouble(offsets[18]);
  object.updatedAt = reader.readDateTime(offsets[19]);
  object.uuid = reader.readString(offsets[20]);
  return object;
}

P _loanEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readDouble(offset)) as P;
    case 14:
      return (reader.readDateTime(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readLong(offset)) as P;
    case 17:
      return (reader.readDouble(offset)) as P;
    case 18:
      return (reader.readDouble(offset)) as P;
    case 19:
      return (reader.readDateTime(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _loanEntityGetId(LoanEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _loanEntityGetLinks(LoanEntity object) {
  return [];
}

void _loanEntityAttach(IsarCollection<dynamic> col, Id id, LoanEntity object) {
  object.id = id;
}

extension LoanEntityByIndex on IsarCollection<LoanEntity> {
  Future<LoanEntity?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  LoanEntity? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<LoanEntity?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<LoanEntity?> getAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uuid', values);
  }

  Future<int> deleteAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uuid', values);
  }

  int deleteAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uuid', values);
  }

  Future<Id> putByUuid(LoanEntity object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(LoanEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<LoanEntity> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(List<LoanEntity> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension LoanEntityQueryWhereSort
    on QueryBuilder<LoanEntity, LoanEntity, QWhere> {
  QueryBuilder<LoanEntity, LoanEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterWhere> anyStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'startDate'),
      );
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterWhere> anyNextDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'nextDueDate'),
      );
    });
  }
}

extension LoanEntityQueryWhere
    on QueryBuilder<LoanEntity, LoanEntity, QWhereClause> {
  QueryBuilder<LoanEntity, LoanEntity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterWhereClause> uuidEqualTo(
      String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uuid',
        value: [uuid],
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterWhereClause> uuidNotEqualTo(
      String uuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [],
              upper: [uuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [uuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [uuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [],
              upper: [uuid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterWhereClause> nameEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterWhereClause> nameNotEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterWhereClause> lenderEqualTo(
      String lender) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lender',
        value: [lender],
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterWhereClause> lenderNotEqualTo(
      String lender) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lender',
              lower: [],
              upper: [lender],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lender',
              lower: [lender],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lender',
              lower: [lender],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lender',
              lower: [],
              upper: [lender],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterWhereClause> loanTypeEqualTo(
      String loanType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'loanType',
        value: [loanType],
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterWhereClause> loanTypeNotEqualTo(
      String loanType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'loanType',
              lower: [],
              upper: [loanType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'loanType',
              lower: [loanType],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'loanType',
              lower: [loanType],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'loanType',
              lower: [],
              upper: [loanType],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterWhereClause> startDateEqualTo(
      DateTime startDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'startDate',
        value: [startDate],
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterWhereClause> startDateNotEqualTo(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterWhereClause> startDateGreaterThan(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterWhereClause> startDateLessThan(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterWhereClause> startDateBetween(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterWhereClause> nextDueDateEqualTo(
      DateTime nextDueDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nextDueDate',
        value: [nextDueDate],
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterWhereClause> nextDueDateNotEqualTo(
      DateTime nextDueDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nextDueDate',
              lower: [],
              upper: [nextDueDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nextDueDate',
              lower: [nextDueDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nextDueDate',
              lower: [nextDueDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nextDueDate',
              lower: [],
              upper: [nextDueDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterWhereClause>
      nextDueDateGreaterThan(
    DateTime nextDueDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'nextDueDate',
        lower: [nextDueDate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterWhereClause> nextDueDateLessThan(
    DateTime nextDueDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'nextDueDate',
        lower: [],
        upper: [nextDueDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterWhereClause> nextDueDateBetween(
    DateTime lowerNextDueDate,
    DateTime upperNextDueDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'nextDueDate',
        lower: [lowerNextDueDate],
        includeLower: includeLower,
        upper: [upperNextDueDate],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterWhereClause> statusEqualTo(
      String status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [status],
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterWhereClause> statusNotEqualTo(
      String status) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ));
      }
    });
  }
}

extension LoanEntityQueryFilter
    on QueryBuilder<LoanEntity, LoanEntity, QFilterCondition> {
  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      accountIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'accountId',
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      accountIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'accountId',
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> accountIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accountId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      accountIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accountId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> accountIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accountId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> accountIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accountId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      accountIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'accountId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> accountIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'accountId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> accountIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'accountId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> accountIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'accountId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      accountIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accountId',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      accountIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'accountId',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> emiAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emiAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      emiAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'emiAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> emiAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'emiAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> emiAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'emiAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      expectedEndDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expectedEndDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      expectedEndDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expectedEndDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      expectedEndDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expectedEndDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      expectedEndDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expectedEndDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      interestRateEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'interestRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      interestRateGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'interestRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      interestRateLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'interestRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      interestRateBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'interestRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      interestTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'interestType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      interestTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'interestType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      interestTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'interestType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      interestTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'interestType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      interestTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'interestType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      interestTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'interestType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      interestTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'interestType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      interestTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'interestType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      interestTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'interestType',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      interestTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'interestType',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> lenderEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> lenderGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> lenderLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> lenderBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lender',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> lenderStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> lenderEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> lenderContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> lenderMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lender',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> lenderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lender',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      lenderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lender',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> loanTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loanType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      loanTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'loanType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> loanTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'loanType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> loanTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'loanType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      loanTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'loanType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> loanTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'loanType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> loanTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'loanType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> loanTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'loanType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      loanTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loanType',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      loanTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'loanType',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> nameContains(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      nextDueDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nextDueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      nextDueDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nextDueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      nextDueDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nextDueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      nextDueDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nextDueDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> notesEqualTo(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> notesGreaterThan(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> notesLessThan(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> notesBetween(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> notesStartsWith(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> notesEndsWith(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> notesContains(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> notesMatches(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      outstandingPrincipalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'outstandingPrincipal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      outstandingPrincipalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'outstandingPrincipal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      outstandingPrincipalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'outstandingPrincipal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      outstandingPrincipalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'outstandingPrincipal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> paymentDayEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentDay',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      paymentDayGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paymentDay',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      paymentDayLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paymentDay',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> paymentDayBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paymentDay',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      principalAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'principalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      principalAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'principalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      principalAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'principalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      principalAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'principalAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> startDateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> startDateLessThan(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> startDateBetween(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> statusEqualTo(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> statusGreaterThan(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> statusLessThan(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> statusBetween(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> statusStartsWith(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> statusEndsWith(
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

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> statusContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> statusMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      tenureMonthsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tenureMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      tenureMonthsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tenureMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      tenureMonthsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tenureMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      tenureMonthsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tenureMonths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      totalInterestPaidEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalInterestPaid',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      totalInterestPaidGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalInterestPaid',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      totalInterestPaidLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalInterestPaid',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      totalInterestPaidBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalInterestPaid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      totalPrincipalPaidEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalPrincipalPaid',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      totalPrincipalPaidGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalPrincipalPaid',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      totalPrincipalPaidLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalPrincipalPaid',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      totalPrincipalPaidBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalPrincipalPaid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> updatedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> uuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> uuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> uuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> uuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> uuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> uuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> uuidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> uuidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterFilterCondition> uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uuid',
        value: '',
      ));
    });
  }
}

extension LoanEntityQueryObject
    on QueryBuilder<LoanEntity, LoanEntity, QFilterCondition> {}

extension LoanEntityQueryLinks
    on QueryBuilder<LoanEntity, LoanEntity, QFilterCondition> {}

extension LoanEntityQuerySortBy
    on QueryBuilder<LoanEntity, LoanEntity, QSortBy> {
  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByEmiAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emiAmount', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByEmiAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emiAmount', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByExpectedEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedEndDate', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy>
      sortByExpectedEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedEndDate', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByInterestRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestRate', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByInterestRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestRate', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByInterestType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestType', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByInterestTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestType', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByLender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lender', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByLenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lender', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByLoanType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loanType', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByLoanTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loanType', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByNextDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDueDate', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByNextDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDueDate', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy>
      sortByOutstandingPrincipal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outstandingPrincipal', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy>
      sortByOutstandingPrincipalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outstandingPrincipal', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByPaymentDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentDay', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByPaymentDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentDay', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByPrincipalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'principalAmount', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy>
      sortByPrincipalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'principalAmount', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByTenureMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenureMonths', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByTenureMonthsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenureMonths', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByTotalInterestPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalInterestPaid', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy>
      sortByTotalInterestPaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalInterestPaid', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy>
      sortByTotalPrincipalPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPrincipalPaid', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy>
      sortByTotalPrincipalPaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPrincipalPaid', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension LoanEntityQuerySortThenBy
    on QueryBuilder<LoanEntity, LoanEntity, QSortThenBy> {
  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByEmiAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emiAmount', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByEmiAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emiAmount', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByExpectedEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedEndDate', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy>
      thenByExpectedEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedEndDate', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByInterestRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestRate', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByInterestRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestRate', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByInterestType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestType', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByInterestTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestType', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByLender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lender', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByLenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lender', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByLoanType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loanType', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByLoanTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loanType', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByNextDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDueDate', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByNextDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDueDate', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy>
      thenByOutstandingPrincipal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outstandingPrincipal', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy>
      thenByOutstandingPrincipalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outstandingPrincipal', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByPaymentDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentDay', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByPaymentDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentDay', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByPrincipalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'principalAmount', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy>
      thenByPrincipalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'principalAmount', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByTenureMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenureMonths', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByTenureMonthsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenureMonths', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByTotalInterestPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalInterestPaid', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy>
      thenByTotalInterestPaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalInterestPaid', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy>
      thenByTotalPrincipalPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPrincipalPaid', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy>
      thenByTotalPrincipalPaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPrincipalPaid', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QAfterSortBy> thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension LoanEntityQueryWhereDistinct
    on QueryBuilder<LoanEntity, LoanEntity, QDistinct> {
  QueryBuilder<LoanEntity, LoanEntity, QDistinct> distinctByAccountId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accountId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QDistinct> distinctByEmiAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'emiAmount');
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QDistinct> distinctByExpectedEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expectedEndDate');
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QDistinct> distinctByInterestRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'interestRate');
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QDistinct> distinctByInterestType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'interestType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QDistinct> distinctByLender(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lender', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QDistinct> distinctByLoanType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loanType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QDistinct> distinctByNextDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextDueDate');
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QDistinct>
      distinctByOutstandingPrincipal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'outstandingPrincipal');
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QDistinct> distinctByPaymentDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentDay');
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QDistinct> distinctByPrincipalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'principalAmount');
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QDistinct> distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate');
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QDistinct> distinctByTenureMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tenureMonths');
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QDistinct>
      distinctByTotalInterestPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalInterestPaid');
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QDistinct>
      distinctByTotalPrincipalPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalPrincipalPaid');
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<LoanEntity, LoanEntity, QDistinct> distinctByUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension LoanEntityQueryProperty
    on QueryBuilder<LoanEntity, LoanEntity, QQueryProperty> {
  QueryBuilder<LoanEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LoanEntity, String?, QQueryOperations> accountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accountId');
    });
  }

  QueryBuilder<LoanEntity, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<LoanEntity, double, QQueryOperations> emiAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'emiAmount');
    });
  }

  QueryBuilder<LoanEntity, DateTime, QQueryOperations>
      expectedEndDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expectedEndDate');
    });
  }

  QueryBuilder<LoanEntity, double, QQueryOperations> interestRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'interestRate');
    });
  }

  QueryBuilder<LoanEntity, String, QQueryOperations> interestTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'interestType');
    });
  }

  QueryBuilder<LoanEntity, String, QQueryOperations> lenderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lender');
    });
  }

  QueryBuilder<LoanEntity, String, QQueryOperations> loanTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loanType');
    });
  }

  QueryBuilder<LoanEntity, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<LoanEntity, DateTime, QQueryOperations> nextDueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextDueDate');
    });
  }

  QueryBuilder<LoanEntity, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<LoanEntity, double, QQueryOperations>
      outstandingPrincipalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'outstandingPrincipal');
    });
  }

  QueryBuilder<LoanEntity, int, QQueryOperations> paymentDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentDay');
    });
  }

  QueryBuilder<LoanEntity, double, QQueryOperations> principalAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'principalAmount');
    });
  }

  QueryBuilder<LoanEntity, DateTime, QQueryOperations> startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }

  QueryBuilder<LoanEntity, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<LoanEntity, int, QQueryOperations> tenureMonthsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tenureMonths');
    });
  }

  QueryBuilder<LoanEntity, double, QQueryOperations>
      totalInterestPaidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalInterestPaid');
    });
  }

  QueryBuilder<LoanEntity, double, QQueryOperations>
      totalPrincipalPaidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalPrincipalPaid');
    });
  }

  QueryBuilder<LoanEntity, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<LoanEntity, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}
