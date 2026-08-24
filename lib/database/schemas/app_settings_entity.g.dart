// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppSettingsEntityCollection on Isar {
  IsarCollection<AppSettingsEntity> get appSettingsEntitys => this.collection();
}

const AppSettingsEntitySchema = CollectionSchema(
  name: r'AppSettingsEntity',
  id: 5506238605616873742,
  properties: {
    r'autoLockTimeoutMinutes': PropertySchema(
      id: 0,
      name: r'autoLockTimeoutMinutes',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currencyCode': PropertySchema(
      id: 2,
      name: r'currencyCode',
      type: IsarType.string,
    ),
    r'dismissedInsightIds': PropertySchema(
      id: 3,
      name: r'dismissedInsightIds',
      type: IsarType.stringList,
    ),
    r'geminiConsentDate': PropertySchema(
      id: 4,
      name: r'geminiConsentDate',
      type: IsarType.dateTime,
    ),
    r'geminiConsentGranted': PropertySchema(
      id: 5,
      name: r'geminiConsentGranted',
      type: IsarType.bool,
    ),
    r'hasCompletedOnboarding': PropertySchema(
      id: 6,
      name: r'hasCompletedOnboarding',
      type: IsarType.bool,
    ),
    r'ingestionDuplicateCount': PropertySchema(
      id: 7,
      name: r'ingestionDuplicateCount',
      type: IsarType.long,
    ),
    r'ingestionLastError': PropertySchema(
      id: 8,
      name: r'ingestionLastError',
      type: IsarType.string,
    ),
    r'ingestionParsedCount': PropertySchema(
      id: 9,
      name: r'ingestionParsedCount',
      type: IsarType.long,
    ),
    r'ingestionRejectedCount': PropertySchema(
      id: 10,
      name: r'ingestionRejectedCount',
      type: IsarType.long,
    ),
    r'isAlertsEnabled': PropertySchema(
      id: 11,
      name: r'isAlertsEnabled',
      type: IsarType.bool,
    ),
    r'isBackupReminderEnabled': PropertySchema(
      id: 12,
      name: r'isBackupReminderEnabled',
      type: IsarType.bool,
    ),
    r'isBiometricEnabled': PropertySchema(
      id: 13,
      name: r'isBiometricEnabled',
      type: IsarType.bool,
    ),
    r'isBudgetAlertsEnabled': PropertySchema(
      id: 14,
      name: r'isBudgetAlertsEnabled',
      type: IsarType.bool,
    ),
    r'isDenseMode': PropertySchema(
      id: 15,
      name: r'isDenseMode',
      type: IsarType.bool,
    ),
    r'isGeminiEnabled': PropertySchema(
      id: 16,
      name: r'isGeminiEnabled',
      type: IsarType.bool,
    ),
    r'isLoanAlertsEnabled': PropertySchema(
      id: 17,
      name: r'isLoanAlertsEnabled',
      type: IsarType.bool,
    ),
    r'isNeedsReviewAlertsEnabled': PropertySchema(
      id: 18,
      name: r'isNeedsReviewAlertsEnabled',
      type: IsarType.bool,
    ),
    r'isNotificationDetectionEnabled': PropertySchema(
      id: 19,
      name: r'isNotificationDetectionEnabled',
      type: IsarType.bool,
    ),
    r'isPinEnabled': PropertySchema(
      id: 20,
      name: r'isPinEnabled',
      type: IsarType.bool,
    ),
    r'isPrivacyBlurEnabled': PropertySchema(
      id: 21,
      name: r'isPrivacyBlurEnabled',
      type: IsarType.bool,
    ),
    r'isScreenshotProtectionEnabled': PropertySchema(
      id: 22,
      name: r'isScreenshotProtectionEnabled',
      type: IsarType.bool,
    ),
    r'isSmsDetectionEnabled': PropertySchema(
      id: 23,
      name: r'isSmsDetectionEnabled',
      type: IsarType.bool,
    ),
    r'isSubscriptionAlertsEnabled': PropertySchema(
      id: 24,
      name: r'isSubscriptionAlertsEnabled',
      type: IsarType.bool,
    ),
    r'lastAlertScan': PropertySchema(
      id: 25,
      name: r'lastAlertScan',
      type: IsarType.dateTime,
    ),
    r'lastBackupDate': PropertySchema(
      id: 26,
      name: r'lastBackupDate',
      type: IsarType.dateTime,
    ),
    r'lastGmailScan': PropertySchema(
      id: 27,
      name: r'lastGmailScan',
      type: IsarType.dateTime,
    ),
    r'lastIngestionScan': PropertySchema(
      id: 28,
      name: r'lastIngestionScan',
      type: IsarType.dateTime,
    ),
    r'lastSuccessfulNotificationEvent': PropertySchema(
      id: 29,
      name: r'lastSuccessfulNotificationEvent',
      type: IsarType.dateTime,
    ),
    r'lastSuccessfulSmsEvent': PropertySchema(
      id: 30,
      name: r'lastSuccessfulSmsEvent',
      type: IsarType.dateTime,
    ),
    r'selectedNotificationPackages': PropertySchema(
      id: 31,
      name: r'selectedNotificationPackages',
      type: IsarType.stringList,
    ),
    r'selectedSmsSenders': PropertySchema(
      id: 32,
      name: r'selectedSmsSenders',
      type: IsarType.stringList,
    ),
    r'themeMode': PropertySchema(
      id: 33,
      name: r'themeMode',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 34,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },
  estimateSize: _appSettingsEntityEstimateSize,
  serialize: _appSettingsEntitySerialize,
  deserialize: _appSettingsEntityDeserialize,
  deserializeProp: _appSettingsEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _appSettingsEntityGetId,
  getLinks: _appSettingsEntityGetLinks,
  attach: _appSettingsEntityAttach,
  version: '3.1.0+1',
);

int _appSettingsEntityEstimateSize(
  AppSettingsEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.currencyCode.length * 3;
  bytesCount += 3 + object.dismissedInsightIds.length * 3;
  {
    for (var i = 0; i < object.dismissedInsightIds.length; i++) {
      final value = object.dismissedInsightIds[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.ingestionLastError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.selectedNotificationPackages.length * 3;
  {
    for (var i = 0; i < object.selectedNotificationPackages.length; i++) {
      final value = object.selectedNotificationPackages[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.selectedSmsSenders.length * 3;
  {
    for (var i = 0; i < object.selectedSmsSenders.length; i++) {
      final value = object.selectedSmsSenders[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.themeMode.length * 3;
  return bytesCount;
}

void _appSettingsEntitySerialize(
  AppSettingsEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.autoLockTimeoutMinutes);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.currencyCode);
  writer.writeStringList(offsets[3], object.dismissedInsightIds);
  writer.writeDateTime(offsets[4], object.geminiConsentDate);
  writer.writeBool(offsets[5], object.geminiConsentGranted);
  writer.writeBool(offsets[6], object.hasCompletedOnboarding);
  writer.writeLong(offsets[7], object.ingestionDuplicateCount);
  writer.writeString(offsets[8], object.ingestionLastError);
  writer.writeLong(offsets[9], object.ingestionParsedCount);
  writer.writeLong(offsets[10], object.ingestionRejectedCount);
  writer.writeBool(offsets[11], object.isAlertsEnabled);
  writer.writeBool(offsets[12], object.isBackupReminderEnabled);
  writer.writeBool(offsets[13], object.isBiometricEnabled);
  writer.writeBool(offsets[14], object.isBudgetAlertsEnabled);
  writer.writeBool(offsets[15], object.isDenseMode);
  writer.writeBool(offsets[16], object.isGeminiEnabled);
  writer.writeBool(offsets[17], object.isLoanAlertsEnabled);
  writer.writeBool(offsets[18], object.isNeedsReviewAlertsEnabled);
  writer.writeBool(offsets[19], object.isNotificationDetectionEnabled);
  writer.writeBool(offsets[20], object.isPinEnabled);
  writer.writeBool(offsets[21], object.isPrivacyBlurEnabled);
  writer.writeBool(offsets[22], object.isScreenshotProtectionEnabled);
  writer.writeBool(offsets[23], object.isSmsDetectionEnabled);
  writer.writeBool(offsets[24], object.isSubscriptionAlertsEnabled);
  writer.writeDateTime(offsets[25], object.lastAlertScan);
  writer.writeDateTime(offsets[26], object.lastBackupDate);
  writer.writeDateTime(offsets[27], object.lastGmailScan);
  writer.writeDateTime(offsets[28], object.lastIngestionScan);
  writer.writeDateTime(offsets[29], object.lastSuccessfulNotificationEvent);
  writer.writeDateTime(offsets[30], object.lastSuccessfulSmsEvent);
  writer.writeStringList(offsets[31], object.selectedNotificationPackages);
  writer.writeStringList(offsets[32], object.selectedSmsSenders);
  writer.writeString(offsets[33], object.themeMode);
  writer.writeDateTime(offsets[34], object.updatedAt);
}

AppSettingsEntity _appSettingsEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppSettingsEntity();
  object.autoLockTimeoutMinutes = reader.readLong(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.currencyCode = reader.readString(offsets[2]);
  object.dismissedInsightIds = reader.readStringList(offsets[3]) ?? [];
  object.geminiConsentDate = reader.readDateTimeOrNull(offsets[4]);
  object.geminiConsentGranted = reader.readBool(offsets[5]);
  object.hasCompletedOnboarding = reader.readBool(offsets[6]);
  object.id = id;
  object.ingestionDuplicateCount = reader.readLong(offsets[7]);
  object.ingestionLastError = reader.readStringOrNull(offsets[8]);
  object.ingestionParsedCount = reader.readLong(offsets[9]);
  object.ingestionRejectedCount = reader.readLong(offsets[10]);
  object.isAlertsEnabled = reader.readBool(offsets[11]);
  object.isBackupReminderEnabled = reader.readBool(offsets[12]);
  object.isBiometricEnabled = reader.readBool(offsets[13]);
  object.isBudgetAlertsEnabled = reader.readBool(offsets[14]);
  object.isDenseMode = reader.readBool(offsets[15]);
  object.isGeminiEnabled = reader.readBool(offsets[16]);
  object.isLoanAlertsEnabled = reader.readBool(offsets[17]);
  object.isNeedsReviewAlertsEnabled = reader.readBool(offsets[18]);
  object.isNotificationDetectionEnabled = reader.readBool(offsets[19]);
  object.isPinEnabled = reader.readBool(offsets[20]);
  object.isPrivacyBlurEnabled = reader.readBool(offsets[21]);
  object.isScreenshotProtectionEnabled = reader.readBool(offsets[22]);
  object.isSmsDetectionEnabled = reader.readBool(offsets[23]);
  object.isSubscriptionAlertsEnabled = reader.readBool(offsets[24]);
  object.lastAlertScan = reader.readDateTimeOrNull(offsets[25]);
  object.lastBackupDate = reader.readDateTimeOrNull(offsets[26]);
  object.lastGmailScan = reader.readDateTimeOrNull(offsets[27]);
  object.lastIngestionScan = reader.readDateTimeOrNull(offsets[28]);
  object.lastSuccessfulNotificationEvent = reader.readDateTimeOrNull(
    offsets[29],
  );
  object.lastSuccessfulSmsEvent = reader.readDateTimeOrNull(offsets[30]);
  object.selectedNotificationPackages =
      reader.readStringList(offsets[31]) ?? [];
  object.selectedSmsSenders = reader.readStringList(offsets[32]) ?? [];
  object.themeMode = reader.readString(offsets[33]);
  object.updatedAt = reader.readDateTime(offsets[34]);
  return object;
}

P _appSettingsEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (reader.readBool(offset)) as P;
    case 16:
      return (reader.readBool(offset)) as P;
    case 17:
      return (reader.readBool(offset)) as P;
    case 18:
      return (reader.readBool(offset)) as P;
    case 19:
      return (reader.readBool(offset)) as P;
    case 20:
      return (reader.readBool(offset)) as P;
    case 21:
      return (reader.readBool(offset)) as P;
    case 22:
      return (reader.readBool(offset)) as P;
    case 23:
      return (reader.readBool(offset)) as P;
    case 24:
      return (reader.readBool(offset)) as P;
    case 25:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 26:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 27:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 28:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 29:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 30:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 31:
      return (reader.readStringList(offset) ?? []) as P;
    case 32:
      return (reader.readStringList(offset) ?? []) as P;
    case 33:
      return (reader.readString(offset)) as P;
    case 34:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appSettingsEntityGetId(AppSettingsEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appSettingsEntityGetLinks(
  AppSettingsEntity object,
) {
  return [];
}

void _appSettingsEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  AppSettingsEntity object,
) {
  object.id = id;
}

extension AppSettingsEntityQueryWhereSort
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QWhere> {
  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppSettingsEntityQueryWhere
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QWhereClause> {
  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterWhereClause>
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

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterWhereClause>
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
}

extension AppSettingsEntityQueryFilter
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QFilterCondition> {
  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  autoLockTimeoutMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'autoLockTimeoutMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  autoLockTimeoutMinutesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'autoLockTimeoutMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  autoLockTimeoutMinutesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'autoLockTimeoutMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  autoLockTimeoutMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'autoLockTimeoutMinutes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
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

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
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

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
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

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  currencyCodeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currencyCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  currencyCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currencyCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  currencyCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currencyCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  currencyCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currencyCode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  currencyCodeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'currencyCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  currencyCodeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'currencyCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  currencyCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'currencyCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  currencyCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'currencyCode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  currencyCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currencyCode', value: ''),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  currencyCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'currencyCode', value: ''),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  dismissedInsightIdsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'dismissedInsightIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  dismissedInsightIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dismissedInsightIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  dismissedInsightIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dismissedInsightIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  dismissedInsightIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dismissedInsightIds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  dismissedInsightIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'dismissedInsightIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  dismissedInsightIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'dismissedInsightIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  dismissedInsightIdsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'dismissedInsightIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  dismissedInsightIdsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'dismissedInsightIds',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  dismissedInsightIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dismissedInsightIds', value: ''),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  dismissedInsightIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'dismissedInsightIds',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  dismissedInsightIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dismissedInsightIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  dismissedInsightIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'dismissedInsightIds', 0, true, 0, true);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  dismissedInsightIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'dismissedInsightIds', 0, false, 999999, true);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  dismissedInsightIdsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'dismissedInsightIds', 0, true, length, include);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  dismissedInsightIdsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dismissedInsightIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  dismissedInsightIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dismissedInsightIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  geminiConsentDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'geminiConsentDate'),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  geminiConsentDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'geminiConsentDate'),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  geminiConsentDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'geminiConsentDate', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  geminiConsentDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'geminiConsentDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  geminiConsentDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'geminiConsentDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  geminiConsentDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'geminiConsentDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  geminiConsentGrantedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'geminiConsentGranted',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  hasCompletedOnboardingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'hasCompletedOnboarding',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
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

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
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

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
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

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  ingestionDuplicateCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'ingestionDuplicateCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  ingestionDuplicateCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ingestionDuplicateCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  ingestionDuplicateCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ingestionDuplicateCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  ingestionDuplicateCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ingestionDuplicateCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  ingestionLastErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'ingestionLastError'),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  ingestionLastErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'ingestionLastError'),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  ingestionLastErrorEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'ingestionLastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  ingestionLastErrorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ingestionLastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  ingestionLastErrorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ingestionLastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  ingestionLastErrorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ingestionLastError',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  ingestionLastErrorStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'ingestionLastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  ingestionLastErrorEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'ingestionLastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  ingestionLastErrorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'ingestionLastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  ingestionLastErrorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'ingestionLastError',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  ingestionLastErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ingestionLastError', value: ''),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  ingestionLastErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'ingestionLastError', value: ''),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  ingestionParsedCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'ingestionParsedCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  ingestionParsedCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ingestionParsedCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  ingestionParsedCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ingestionParsedCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  ingestionParsedCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ingestionParsedCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  ingestionRejectedCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'ingestionRejectedCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  ingestionRejectedCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ingestionRejectedCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  ingestionRejectedCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ingestionRejectedCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  ingestionRejectedCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ingestionRejectedCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  isAlertsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isAlertsEnabled', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  isBackupReminderEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'isBackupReminderEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  isBiometricEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isBiometricEnabled', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  isBudgetAlertsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'isBudgetAlertsEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  isDenseModeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isDenseMode', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  isGeminiEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isGeminiEnabled', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  isLoanAlertsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isLoanAlertsEnabled', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  isNeedsReviewAlertsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'isNeedsReviewAlertsEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  isNotificationDetectionEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'isNotificationDetectionEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  isPinEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isPinEnabled', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  isPrivacyBlurEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'isPrivacyBlurEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  isScreenshotProtectionEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'isScreenshotProtectionEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  isSmsDetectionEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'isSmsDetectionEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  isSubscriptionAlertsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'isSubscriptionAlertsEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastAlertScanIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastAlertScan'),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastAlertScanIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastAlertScan'),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastAlertScanEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastAlertScan', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastAlertScanGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastAlertScan',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastAlertScanLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastAlertScan',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastAlertScanBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastAlertScan',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastBackupDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastBackupDate'),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastBackupDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastBackupDate'),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastBackupDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastBackupDate', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastBackupDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastBackupDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastBackupDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastBackupDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastBackupDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastBackupDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastGmailScanIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastGmailScan'),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastGmailScanIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastGmailScan'),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastGmailScanEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastGmailScan', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastGmailScanGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastGmailScan',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastGmailScanLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastGmailScan',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastGmailScanBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastGmailScan',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastIngestionScanIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastIngestionScan'),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastIngestionScanIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastIngestionScan'),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastIngestionScanEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastIngestionScan', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastIngestionScanGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastIngestionScan',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastIngestionScanLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastIngestionScan',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastIngestionScanBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastIngestionScan',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastSuccessfulNotificationEventIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(
          property: r'lastSuccessfulNotificationEvent',
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastSuccessfulNotificationEventIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(
          property: r'lastSuccessfulNotificationEvent',
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastSuccessfulNotificationEventEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lastSuccessfulNotificationEvent',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastSuccessfulNotificationEventGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastSuccessfulNotificationEvent',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastSuccessfulNotificationEventLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastSuccessfulNotificationEvent',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastSuccessfulNotificationEventBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastSuccessfulNotificationEvent',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastSuccessfulSmsEventIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastSuccessfulSmsEvent'),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastSuccessfulSmsEventIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastSuccessfulSmsEvent'),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastSuccessfulSmsEventEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lastSuccessfulSmsEvent',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastSuccessfulSmsEventGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastSuccessfulSmsEvent',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastSuccessfulSmsEventLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastSuccessfulSmsEvent',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastSuccessfulSmsEventBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastSuccessfulSmsEvent',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedNotificationPackagesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'selectedNotificationPackages',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedNotificationPackagesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'selectedNotificationPackages',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedNotificationPackagesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'selectedNotificationPackages',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedNotificationPackagesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'selectedNotificationPackages',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedNotificationPackagesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'selectedNotificationPackages',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedNotificationPackagesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'selectedNotificationPackages',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedNotificationPackagesElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'selectedNotificationPackages',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedNotificationPackagesElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'selectedNotificationPackages',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedNotificationPackagesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'selectedNotificationPackages',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedNotificationPackagesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'selectedNotificationPackages',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedNotificationPackagesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'selectedNotificationPackages',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedNotificationPackagesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'selectedNotificationPackages',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedNotificationPackagesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'selectedNotificationPackages',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedNotificationPackagesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'selectedNotificationPackages',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedNotificationPackagesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'selectedNotificationPackages',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedNotificationPackagesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'selectedNotificationPackages',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedSmsSendersElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'selectedSmsSenders',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedSmsSendersElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'selectedSmsSenders',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedSmsSendersElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'selectedSmsSenders',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedSmsSendersElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'selectedSmsSenders',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedSmsSendersElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'selectedSmsSenders',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedSmsSendersElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'selectedSmsSenders',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedSmsSendersElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'selectedSmsSenders',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedSmsSendersElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'selectedSmsSenders',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedSmsSendersElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'selectedSmsSenders', value: ''),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedSmsSendersElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'selectedSmsSenders', value: ''),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedSmsSendersLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'selectedSmsSenders',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedSmsSendersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'selectedSmsSenders', 0, true, 0, true);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedSmsSendersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'selectedSmsSenders', 0, false, 999999, true);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedSmsSendersLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'selectedSmsSenders', 0, true, length, include);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedSmsSendersLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'selectedSmsSenders',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  selectedSmsSendersLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'selectedSmsSenders',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  themeModeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'themeMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  themeModeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'themeMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  themeModeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'themeMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  themeModeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'themeMode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  themeModeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'themeMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  themeModeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'themeMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  themeModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'themeMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  themeModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'themeMode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  themeModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'themeMode', value: ''),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  themeModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'themeMode', value: ''),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
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

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
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

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
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
}

extension AppSettingsEntityQueryObject
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QFilterCondition> {}

extension AppSettingsEntityQueryLinks
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QFilterCondition> {}

extension AppSettingsEntityQuerySortBy
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QSortBy> {
  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByAutoLockTimeoutMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoLockTimeoutMinutes', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByAutoLockTimeoutMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoLockTimeoutMinutes', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByCurrencyCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyCode', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByCurrencyCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyCode', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByGeminiConsentDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'geminiConsentDate', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByGeminiConsentDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'geminiConsentDate', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByGeminiConsentGranted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'geminiConsentGranted', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByGeminiConsentGrantedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'geminiConsentGranted', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByHasCompletedOnboarding() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCompletedOnboarding', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByHasCompletedOnboardingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCompletedOnboarding', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIngestionDuplicateCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingestionDuplicateCount', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIngestionDuplicateCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingestionDuplicateCount', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIngestionLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingestionLastError', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIngestionLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingestionLastError', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIngestionParsedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingestionParsedCount', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIngestionParsedCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingestionParsedCount', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIngestionRejectedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingestionRejectedCount', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIngestionRejectedCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingestionRejectedCount', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsAlertsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAlertsEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsAlertsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAlertsEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsBackupReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBackupReminderEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsBackupReminderEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBackupReminderEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsBiometricEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBiometricEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsBiometricEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBiometricEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsBudgetAlertsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBudgetAlertsEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsBudgetAlertsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBudgetAlertsEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsDenseMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDenseMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsDenseModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDenseMode', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsGeminiEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGeminiEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsGeminiEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGeminiEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsLoanAlertsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLoanAlertsEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsLoanAlertsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLoanAlertsEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsNeedsReviewAlertsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNeedsReviewAlertsEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsNeedsReviewAlertsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNeedsReviewAlertsEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsNotificationDetectionEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNotificationDetectionEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsNotificationDetectionEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNotificationDetectionEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsPinEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsPinEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsPrivacyBlurEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPrivacyBlurEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsPrivacyBlurEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPrivacyBlurEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsScreenshotProtectionEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isScreenshotProtectionEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsScreenshotProtectionEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isScreenshotProtectionEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsSmsDetectionEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSmsDetectionEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsSmsDetectionEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSmsDetectionEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsSubscriptionAlertsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSubscriptionAlertsEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIsSubscriptionAlertsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSubscriptionAlertsEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByLastAlertScan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAlertScan', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByLastAlertScanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAlertScan', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByLastBackupDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupDate', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByLastBackupDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupDate', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByLastGmailScan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastGmailScan', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByLastGmailScanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastGmailScan', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByLastIngestionScan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastIngestionScan', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByLastIngestionScanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastIngestionScan', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByLastSuccessfulNotificationEvent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSuccessfulNotificationEvent', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByLastSuccessfulNotificationEventDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSuccessfulNotificationEvent', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByLastSuccessfulSmsEvent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSuccessfulSmsEvent', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByLastSuccessfulSmsEventDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSuccessfulSmsEvent', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AppSettingsEntityQuerySortThenBy
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QSortThenBy> {
  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByAutoLockTimeoutMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoLockTimeoutMinutes', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByAutoLockTimeoutMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoLockTimeoutMinutes', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByCurrencyCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyCode', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByCurrencyCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyCode', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByGeminiConsentDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'geminiConsentDate', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByGeminiConsentDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'geminiConsentDate', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByGeminiConsentGranted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'geminiConsentGranted', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByGeminiConsentGrantedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'geminiConsentGranted', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByHasCompletedOnboarding() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCompletedOnboarding', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByHasCompletedOnboardingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCompletedOnboarding', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIngestionDuplicateCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingestionDuplicateCount', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIngestionDuplicateCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingestionDuplicateCount', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIngestionLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingestionLastError', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIngestionLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingestionLastError', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIngestionParsedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingestionParsedCount', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIngestionParsedCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingestionParsedCount', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIngestionRejectedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingestionRejectedCount', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIngestionRejectedCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingestionRejectedCount', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsAlertsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAlertsEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsAlertsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAlertsEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsBackupReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBackupReminderEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsBackupReminderEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBackupReminderEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsBiometricEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBiometricEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsBiometricEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBiometricEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsBudgetAlertsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBudgetAlertsEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsBudgetAlertsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBudgetAlertsEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsDenseMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDenseMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsDenseModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDenseMode', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsGeminiEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGeminiEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsGeminiEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGeminiEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsLoanAlertsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLoanAlertsEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsLoanAlertsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLoanAlertsEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsNeedsReviewAlertsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNeedsReviewAlertsEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsNeedsReviewAlertsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNeedsReviewAlertsEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsNotificationDetectionEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNotificationDetectionEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsNotificationDetectionEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNotificationDetectionEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsPinEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsPinEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsPrivacyBlurEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPrivacyBlurEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsPrivacyBlurEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPrivacyBlurEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsScreenshotProtectionEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isScreenshotProtectionEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsScreenshotProtectionEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isScreenshotProtectionEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsSmsDetectionEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSmsDetectionEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsSmsDetectionEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSmsDetectionEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsSubscriptionAlertsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSubscriptionAlertsEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIsSubscriptionAlertsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSubscriptionAlertsEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByLastAlertScan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAlertScan', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByLastAlertScanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAlertScan', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByLastBackupDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupDate', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByLastBackupDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupDate', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByLastGmailScan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastGmailScan', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByLastGmailScanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastGmailScan', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByLastIngestionScan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastIngestionScan', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByLastIngestionScanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastIngestionScan', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByLastSuccessfulNotificationEvent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSuccessfulNotificationEvent', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByLastSuccessfulNotificationEventDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSuccessfulNotificationEvent', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByLastSuccessfulSmsEvent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSuccessfulSmsEvent', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByLastSuccessfulSmsEventDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSuccessfulSmsEvent', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AppSettingsEntityQueryWhereDistinct
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct> {
  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByAutoLockTimeoutMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoLockTimeoutMinutes');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByCurrencyCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currencyCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByDismissedInsightIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dismissedInsightIds');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByGeminiConsentDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'geminiConsentDate');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByGeminiConsentGranted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'geminiConsentGranted');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByHasCompletedOnboarding() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasCompletedOnboarding');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByIngestionDuplicateCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ingestionDuplicateCount');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByIngestionLastError({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'ingestionLastError',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByIngestionParsedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ingestionParsedCount');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByIngestionRejectedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ingestionRejectedCount');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByIsAlertsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAlertsEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByIsBackupReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isBackupReminderEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByIsBiometricEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isBiometricEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByIsBudgetAlertsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isBudgetAlertsEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByIsDenseMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDenseMode');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByIsGeminiEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isGeminiEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByIsLoanAlertsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isLoanAlertsEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByIsNeedsReviewAlertsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isNeedsReviewAlertsEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByIsNotificationDetectionEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isNotificationDetectionEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByIsPinEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPinEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByIsPrivacyBlurEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPrivacyBlurEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByIsScreenshotProtectionEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isScreenshotProtectionEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByIsSmsDetectionEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSmsDetectionEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByIsSubscriptionAlertsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSubscriptionAlertsEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByLastAlertScan() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastAlertScan');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByLastBackupDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastBackupDate');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByLastGmailScan() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastGmailScan');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByLastIngestionScan() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastIngestionScan');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByLastSuccessfulNotificationEvent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSuccessfulNotificationEvent');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByLastSuccessfulSmsEvent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSuccessfulSmsEvent');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctBySelectedNotificationPackages() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'selectedNotificationPackages');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctBySelectedSmsSenders() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'selectedSmsSenders');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByThemeMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'themeMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension AppSettingsEntityQueryProperty
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QQueryProperty> {
  QueryBuilder<AppSettingsEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppSettingsEntity, int, QQueryOperations>
  autoLockTimeoutMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoLockTimeoutMinutes');
    });
  }

  QueryBuilder<AppSettingsEntity, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<AppSettingsEntity, String, QQueryOperations>
  currencyCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currencyCode');
    });
  }

  QueryBuilder<AppSettingsEntity, List<String>, QQueryOperations>
  dismissedInsightIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dismissedInsightIds');
    });
  }

  QueryBuilder<AppSettingsEntity, DateTime?, QQueryOperations>
  geminiConsentDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'geminiConsentDate');
    });
  }

  QueryBuilder<AppSettingsEntity, bool, QQueryOperations>
  geminiConsentGrantedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'geminiConsentGranted');
    });
  }

  QueryBuilder<AppSettingsEntity, bool, QQueryOperations>
  hasCompletedOnboardingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasCompletedOnboarding');
    });
  }

  QueryBuilder<AppSettingsEntity, int, QQueryOperations>
  ingestionDuplicateCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ingestionDuplicateCount');
    });
  }

  QueryBuilder<AppSettingsEntity, String?, QQueryOperations>
  ingestionLastErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ingestionLastError');
    });
  }

  QueryBuilder<AppSettingsEntity, int, QQueryOperations>
  ingestionParsedCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ingestionParsedCount');
    });
  }

  QueryBuilder<AppSettingsEntity, int, QQueryOperations>
  ingestionRejectedCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ingestionRejectedCount');
    });
  }

  QueryBuilder<AppSettingsEntity, bool, QQueryOperations>
  isAlertsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAlertsEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, bool, QQueryOperations>
  isBackupReminderEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isBackupReminderEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, bool, QQueryOperations>
  isBiometricEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isBiometricEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, bool, QQueryOperations>
  isBudgetAlertsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isBudgetAlertsEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, bool, QQueryOperations>
  isDenseModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDenseMode');
    });
  }

  QueryBuilder<AppSettingsEntity, bool, QQueryOperations>
  isGeminiEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isGeminiEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, bool, QQueryOperations>
  isLoanAlertsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isLoanAlertsEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, bool, QQueryOperations>
  isNeedsReviewAlertsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isNeedsReviewAlertsEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, bool, QQueryOperations>
  isNotificationDetectionEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isNotificationDetectionEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, bool, QQueryOperations>
  isPinEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPinEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, bool, QQueryOperations>
  isPrivacyBlurEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPrivacyBlurEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, bool, QQueryOperations>
  isScreenshotProtectionEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isScreenshotProtectionEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, bool, QQueryOperations>
  isSmsDetectionEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSmsDetectionEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, bool, QQueryOperations>
  isSubscriptionAlertsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSubscriptionAlertsEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, DateTime?, QQueryOperations>
  lastAlertScanProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastAlertScan');
    });
  }

  QueryBuilder<AppSettingsEntity, DateTime?, QQueryOperations>
  lastBackupDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastBackupDate');
    });
  }

  QueryBuilder<AppSettingsEntity, DateTime?, QQueryOperations>
  lastGmailScanProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastGmailScan');
    });
  }

  QueryBuilder<AppSettingsEntity, DateTime?, QQueryOperations>
  lastIngestionScanProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastIngestionScan');
    });
  }

  QueryBuilder<AppSettingsEntity, DateTime?, QQueryOperations>
  lastSuccessfulNotificationEventProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSuccessfulNotificationEvent');
    });
  }

  QueryBuilder<AppSettingsEntity, DateTime?, QQueryOperations>
  lastSuccessfulSmsEventProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSuccessfulSmsEvent');
    });
  }

  QueryBuilder<AppSettingsEntity, List<String>, QQueryOperations>
  selectedNotificationPackagesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'selectedNotificationPackages');
    });
  }

  QueryBuilder<AppSettingsEntity, List<String>, QQueryOperations>
  selectedSmsSendersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'selectedSmsSenders');
    });
  }

  QueryBuilder<AppSettingsEntity, String, QQueryOperations>
  themeModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'themeMode');
    });
  }

  QueryBuilder<AppSettingsEntity, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
