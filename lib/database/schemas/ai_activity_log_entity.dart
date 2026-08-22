import 'package:isar/isar.dart';

part 'ai_activity_log_entity.g.dart';

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
