class AiActivityLog {
  final String id;
  final DateTime timestamp;
  final String
  featureUsed; // smart_categorization, merchant_recognition, natural_language_query, insights_explanation, forecast_explanation
  final List<String> dataCategoriesSent;
  final String sanitizedPayloadSummary;
  final String resultSummary;
  final bool? userAccepted;
  final String? errorState;

  const AiActivityLog({
    required this.id,
    required this.timestamp,
    required this.featureUsed,
    this.dataCategoriesSent = const [],
    required this.sanitizedPayloadSummary,
    required this.resultSummary,
    this.userAccepted,
    this.errorState,
  });

  bool get isSuccess => errorState == null || errorState!.isEmpty;

  AiActivityLog copyWith({
    String? id,
    DateTime? timestamp,
    String? featureUsed,
    List<String>? dataCategoriesSent,
    String? sanitizedPayloadSummary,
    String? resultSummary,
    bool? userAccepted,
    String? errorState,
  }) {
    return AiActivityLog(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      featureUsed: featureUsed ?? this.featureUsed,
      dataCategoriesSent: dataCategoriesSent ?? this.dataCategoriesSent,
      sanitizedPayloadSummary:
          sanitizedPayloadSummary ?? this.sanitizedPayloadSummary,
      resultSummary: resultSummary ?? this.resultSummary,
      userAccepted: userAccepted ?? this.userAccepted,
      errorState: errorState ?? this.errorState,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'featureUsed': featureUsed,
    'dataCategoriesSent': dataCategoriesSent,
    'sanitizedPayloadSummary': sanitizedPayloadSummary,
    'resultSummary': resultSummary,
    'userAccepted': userAccepted,
    'errorState': errorState,
  };

  factory AiActivityLog.fromJson(Map<String, dynamic> json) => AiActivityLog(
    id: json['id'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    featureUsed: json['featureUsed'] as String,
    dataCategoriesSent:
        (json['dataCategoriesSent'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [],
    sanitizedPayloadSummary: json['sanitizedPayloadSummary'] as String,
    resultSummary: json['resultSummary'] as String,
    userAccepted: json['userAccepted'] as bool?,
    errorState: json['errorState'] as String?,
  );
}
