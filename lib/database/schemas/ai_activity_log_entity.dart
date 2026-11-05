import 'package:isar/isar.dart';

part 'ai_activity_log_entity.g.dart';

// Retired: the AI feature was removed. The collection stays registered so the
// on-disk schema is unchanged; remove in the next backup-gated migration.
@collection
class AiActivityLogEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late DateTime timestamp;

  late String
  featureUsed; // smart_categorization, merchant_recognition, natural_language_query, insights_explanation, forecast_explanation

  List<String> dataCategoriesSent = [];

  late String sanitizedPayloadSummary;

  late String resultSummary;

  bool? userAccepted;

  String? errorState;
}
