// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emi_payment_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEmiPaymentEntityCollection on Isar {
  IsarCollection<EmiPaymentEntity> get emiPaymentEntitys => this.collection();
}

const EmiPaymentEntitySchema = CollectionSchema(
  name: r'EmiPaymentEntity',
  id: -8534281702680084310,
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
    r'dueDate': PropertySchema(
      id: 2,
      name: r'dueDate',
      type: IsarType.dateTime,
    ),
    r'emiAmount': PropertySchema(
      id: 3,
      name: r'emiAmount',
      type: IsarType.double,
    ),
    r'installmentNumber': PropertySchema(
      id: 4,
      name: r'installmentNumber',
      type: IsarType.long,
    ),
    r'interestPaid': PropertySchema(
      id: 5,
      name: r'interestPaid',
      type: IsarType.double,
    ),
    r'isHistoricalStatusOnly': PropertySchema(
      id: 6,
      name: r'isHistoricalStatusOnly',
      type: IsarType.bool,
    ),
    r'loanId': PropertySchema(id: 7, name: r'loanId', type: IsarType.string),
    r'notes': PropertySchema(id: 8, name: r'notes', type: IsarType.string),
    r'paymentDate': PropertySchema(
      id: 9,
      name: r'paymentDate',
      type: IsarType.dateTime,
    ),
    r'principalPaid': PropertySchema(
      id: 10,
      name: r'principalPaid',
      type: IsarType.double,
    ),
    r'transactionId': PropertySchema(
      id: 11,
      name: r'transactionId',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 12,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'uuid': PropertySchema(id: 13, name: r'uuid', type: IsarType.string),
  },
  estimateSize: _emiPaymentEntityEstimateSize,
  serialize: _emiPaymentEntitySerialize,
  deserialize: _emiPaymentEntityDeserialize,
  deserializeProp: _emiPaymentEntityDeserializeProp,
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
        ),
      ],
    ),
    r'loanId': IndexSchema(
      id: -2433238998242736672,
      name: r'loanId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'loanId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'installmentNumber': IndexSchema(
      id: 3609773167037300425,
      name: r'installmentNumber',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'installmentNumber',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'dueDate': IndexSchema(
      id: -7871003637559820552,
      name: r'dueDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dueDate',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'paymentDate': IndexSchema(
      id: 2770231740271717250,
      name: r'paymentDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'paymentDate',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'transactionId': IndexSchema(
      id: 8561542235958051982,
      name: r'transactionId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'transactionId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _emiPaymentEntityGetId,
  getLinks: _emiPaymentEntityGetLinks,
  attach: _emiPaymentEntityAttach,
  version: '3.1.0+1',
);

int _emiPaymentEntityEstimateSize(
  EmiPaymentEntity object,
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
  bytesCount += 3 + object.loanId.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.transactionId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _emiPaymentEntitySerialize(
  EmiPaymentEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.accountId);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeDateTime(offsets[2], object.dueDate);
  writer.writeDouble(offsets[3], object.emiAmount);
  writer.writeLong(offsets[4], object.installmentNumber);
  writer.writeDouble(offsets[5], object.interestPaid);
  writer.writeBool(offsets[6], object.isHistoricalStatusOnly);
  writer.writeString(offsets[7], object.loanId);
  writer.writeString(offsets[8], object.notes);
  writer.writeDateTime(offsets[9], object.paymentDate);
  writer.writeDouble(offsets[10], object.principalPaid);
  writer.writeString(offsets[11], object.transactionId);
  writer.writeDateTime(offsets[12], object.updatedAt);
  writer.writeString(offsets[13], object.uuid);
}

EmiPaymentEntity _emiPaymentEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EmiPaymentEntity();
  object.accountId = reader.readStringOrNull(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.dueDate = reader.readDateTime(offsets[2]);
  object.emiAmount = reader.readDouble(offsets[3]);
  object.id = id;
  object.installmentNumber = reader.readLong(offsets[4]);
  object.interestPaid = reader.readDouble(offsets[5]);
  object.isHistoricalStatusOnly = reader.readBool(offsets[6]);
  object.loanId = reader.readString(offsets[7]);
  object.notes = reader.readStringOrNull(offsets[8]);
  object.paymentDate = reader.readDateTime(offsets[9]);
  object.principalPaid = reader.readDouble(offsets[10]);
  object.transactionId = reader.readStringOrNull(offsets[11]);
  object.updatedAt = reader.readDateTime(offsets[12]);
  object.uuid = reader.readString(offsets[13]);
  return object;
}

P _emiPaymentEntityDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readDouble(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readDateTime(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _emiPaymentEntityGetId(EmiPaymentEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _emiPaymentEntityGetLinks(EmiPaymentEntity object) {
  return [];
}

void _emiPaymentEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  EmiPaymentEntity object,
) {
  object.id = id;
}

extension EmiPaymentEntityByIndex on IsarCollection<EmiPaymentEntity> {
  Future<EmiPaymentEntity?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  EmiPaymentEntity? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<EmiPaymentEntity?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<EmiPaymentEntity?> getAllByUuidSync(List<String> uuidValues) {
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

  Future<Id> putByUuid(EmiPaymentEntity object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(EmiPaymentEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<EmiPaymentEntity> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(
    List<EmiPaymentEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension EmiPaymentEntityQueryWhereSort
    on QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QWhere> {
  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhere>
  anyInstallmentNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'installmentNumber'),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhere> anyDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'dueDate'),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhere>
  anyPaymentDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'paymentDate'),
      );
    });
  }
}

extension EmiPaymentEntityQueryWhere
    on QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QWhereClause> {
  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause>
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

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause>
  uuidEqualTo(String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'uuid', value: [uuid]),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause>
  uuidNotEqualTo(String uuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [],
                upper: [uuid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [uuid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [uuid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [],
                upper: [uuid],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause>
  loanIdEqualTo(String loanId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'loanId', value: [loanId]),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause>
  loanIdNotEqualTo(String loanId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'loanId',
                lower: [],
                upper: [loanId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'loanId',
                lower: [loanId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'loanId',
                lower: [loanId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'loanId',
                lower: [],
                upper: [loanId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause>
  installmentNumberEqualTo(int installmentNumber) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'installmentNumber',
          value: [installmentNumber],
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause>
  installmentNumberNotEqualTo(int installmentNumber) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'installmentNumber',
                lower: [],
                upper: [installmentNumber],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'installmentNumber',
                lower: [installmentNumber],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'installmentNumber',
                lower: [installmentNumber],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'installmentNumber',
                lower: [],
                upper: [installmentNumber],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause>
  installmentNumberGreaterThan(int installmentNumber, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'installmentNumber',
          lower: [installmentNumber],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause>
  installmentNumberLessThan(int installmentNumber, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'installmentNumber',
          lower: [],
          upper: [installmentNumber],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause>
  installmentNumberBetween(
    int lowerInstallmentNumber,
    int upperInstallmentNumber, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'installmentNumber',
          lower: [lowerInstallmentNumber],
          includeLower: includeLower,
          upper: [upperInstallmentNumber],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause>
  dueDateEqualTo(DateTime dueDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'dueDate', value: [dueDate]),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause>
  dueDateNotEqualTo(DateTime dueDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dueDate',
                lower: [],
                upper: [dueDate],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dueDate',
                lower: [dueDate],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dueDate',
                lower: [dueDate],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dueDate',
                lower: [],
                upper: [dueDate],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause>
  dueDateGreaterThan(DateTime dueDate, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'dueDate',
          lower: [dueDate],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause>
  dueDateLessThan(DateTime dueDate, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'dueDate',
          lower: [],
          upper: [dueDate],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause>
  dueDateBetween(
    DateTime lowerDueDate,
    DateTime upperDueDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'dueDate',
          lower: [lowerDueDate],
          includeLower: includeLower,
          upper: [upperDueDate],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause>
  paymentDateEqualTo(DateTime paymentDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'paymentDate',
          value: [paymentDate],
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause>
  paymentDateNotEqualTo(DateTime paymentDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'paymentDate',
                lower: [],
                upper: [paymentDate],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'paymentDate',
                lower: [paymentDate],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'paymentDate',
                lower: [paymentDate],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'paymentDate',
                lower: [],
                upper: [paymentDate],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause>
  paymentDateGreaterThan(DateTime paymentDate, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'paymentDate',
          lower: [paymentDate],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause>
  paymentDateLessThan(DateTime paymentDate, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'paymentDate',
          lower: [],
          upper: [paymentDate],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause>
  paymentDateBetween(
    DateTime lowerPaymentDate,
    DateTime upperPaymentDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'paymentDate',
          lower: [lowerPaymentDate],
          includeLower: includeLower,
          upper: [upperPaymentDate],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause>
  transactionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'transactionId', value: [null]),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause>
  transactionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'transactionId',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause>
  transactionIdEqualTo(String? transactionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'transactionId',
          value: [transactionId],
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterWhereClause>
  transactionIdNotEqualTo(String? transactionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transactionId',
                lower: [],
                upper: [transactionId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transactionId',
                lower: [transactionId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transactionId',
                lower: [transactionId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transactionId',
                lower: [],
                upper: [transactionId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension EmiPaymentEntityQueryFilter
    on QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QFilterCondition> {
  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  accountIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'accountId'),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  accountIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'accountId'),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  accountIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'accountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  accountIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'accountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  accountIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'accountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  accountIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'accountId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  accountIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'accountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  accountIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'accountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  accountIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'accountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  accountIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'accountId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  accountIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'accountId', value: ''),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  accountIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'accountId', value: ''),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  dueDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dueDate', value: value),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  dueDateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dueDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  dueDateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dueDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  dueDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dueDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  emiAmountEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'emiAmount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  emiAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'emiAmount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  emiAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'emiAmount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  emiAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'emiAmount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
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

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
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

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
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

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  installmentNumberEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'installmentNumber', value: value),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  installmentNumberGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'installmentNumber',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  installmentNumberLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'installmentNumber',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  installmentNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'installmentNumber',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  interestPaidEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'interestPaid',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  interestPaidGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'interestPaid',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  interestPaidLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'interestPaid',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  interestPaidBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'interestPaid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  isHistoricalStatusOnlyEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'isHistoricalStatusOnly',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  loanIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'loanId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  loanIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'loanId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  loanIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'loanId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  loanIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'loanId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  loanIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'loanId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  loanIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'loanId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  loanIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'loanId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  loanIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'loanId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  loanIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'loanId', value: ''),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  loanIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'loanId', value: ''),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  notesEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'notes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  notesStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  notesEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'notes',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  paymentDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'paymentDate', value: value),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  paymentDateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'paymentDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  paymentDateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'paymentDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  paymentDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'paymentDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  principalPaidEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'principalPaid',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  principalPaidGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'principalPaid',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  principalPaidLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'principalPaid',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  principalPaidBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'principalPaid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  transactionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'transactionId'),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  transactionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'transactionId'),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  transactionIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'transactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  transactionIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'transactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  transactionIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'transactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  transactionIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'transactionId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  transactionIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'transactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  transactionIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'transactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  transactionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'transactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  transactionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'transactionId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  transactionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'transactionId', value: ''),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  transactionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'transactionId', value: ''),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  updatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  uuidEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  uuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  uuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  uuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'uuid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  uuidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  uuidEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  uuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  uuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'uuid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uuid', value: ''),
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterFilterCondition>
  uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uuid', value: ''),
      );
    });
  }
}

extension EmiPaymentEntityQueryObject
    on QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QFilterCondition> {}

extension EmiPaymentEntityQueryLinks
    on QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QFilterCondition> {}

extension EmiPaymentEntityQuerySortBy
    on QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QSortBy> {
  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  sortByAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  sortByAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  sortByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  sortByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  sortByEmiAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emiAmount', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  sortByEmiAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emiAmount', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  sortByInstallmentNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installmentNumber', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  sortByInstallmentNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installmentNumber', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  sortByInterestPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestPaid', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  sortByInterestPaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestPaid', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  sortByIsHistoricalStatusOnly() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHistoricalStatusOnly', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  sortByIsHistoricalStatusOnlyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHistoricalStatusOnly', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  sortByLoanId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loanId', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  sortByLoanIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loanId', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  sortByPaymentDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentDate', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  sortByPaymentDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentDate', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  sortByPrincipalPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'principalPaid', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  sortByPrincipalPaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'principalPaid', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  sortByTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  sortByTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension EmiPaymentEntityQuerySortThenBy
    on QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QSortThenBy> {
  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByEmiAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emiAmount', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByEmiAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emiAmount', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByInstallmentNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installmentNumber', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByInstallmentNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installmentNumber', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByInterestPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestPaid', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByInterestPaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestPaid', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByIsHistoricalStatusOnly() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHistoricalStatusOnly', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByIsHistoricalStatusOnlyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHistoricalStatusOnly', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByLoanId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loanId', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByLoanIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loanId', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByPaymentDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentDate', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByPaymentDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentDate', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByPrincipalPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'principalPaid', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByPrincipalPaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'principalPaid', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QAfterSortBy>
  thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension EmiPaymentEntityQueryWhereDistinct
    on QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QDistinct> {
  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QDistinct>
  distinctByAccountId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accountId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QDistinct>
  distinctByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dueDate');
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QDistinct>
  distinctByEmiAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'emiAmount');
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QDistinct>
  distinctByInstallmentNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'installmentNumber');
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QDistinct>
  distinctByInterestPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'interestPaid');
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QDistinct>
  distinctByIsHistoricalStatusOnly() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isHistoricalStatusOnly');
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QDistinct> distinctByLoanId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loanId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QDistinct> distinctByNotes({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QDistinct>
  distinctByPaymentDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentDate');
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QDistinct>
  distinctByPrincipalPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'principalPaid');
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QDistinct>
  distinctByTransactionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'transactionId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QDistinct> distinctByUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension EmiPaymentEntityQueryProperty
    on QueryBuilder<EmiPaymentEntity, EmiPaymentEntity, QQueryProperty> {
  QueryBuilder<EmiPaymentEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<EmiPaymentEntity, String?, QQueryOperations>
  accountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accountId');
    });
  }

  QueryBuilder<EmiPaymentEntity, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<EmiPaymentEntity, DateTime, QQueryOperations> dueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dueDate');
    });
  }

  QueryBuilder<EmiPaymentEntity, double, QQueryOperations> emiAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'emiAmount');
    });
  }

  QueryBuilder<EmiPaymentEntity, int, QQueryOperations>
  installmentNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'installmentNumber');
    });
  }

  QueryBuilder<EmiPaymentEntity, double, QQueryOperations>
  interestPaidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'interestPaid');
    });
  }

  QueryBuilder<EmiPaymentEntity, bool, QQueryOperations>
  isHistoricalStatusOnlyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isHistoricalStatusOnly');
    });
  }

  QueryBuilder<EmiPaymentEntity, String, QQueryOperations> loanIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loanId');
    });
  }

  QueryBuilder<EmiPaymentEntity, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<EmiPaymentEntity, DateTime, QQueryOperations>
  paymentDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentDate');
    });
  }

  QueryBuilder<EmiPaymentEntity, double, QQueryOperations>
  principalPaidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'principalPaid');
    });
  }

  QueryBuilder<EmiPaymentEntity, String?, QQueryOperations>
  transactionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transactionId');
    });
  }

  QueryBuilder<EmiPaymentEntity, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<EmiPaymentEntity, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}
