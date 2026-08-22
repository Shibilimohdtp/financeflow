enum InsightType {
  spendingComparison,
  topCategory,
  savingsRate,
  budgetExhaustion,
  frequencyChange,
  anomaly;

  String get displayName {
    switch (this) {
      case InsightType.spendingComparison:
        return 'Spending Trend';
      case InsightType.topCategory:
        return 'Top Category';
      case InsightType.savingsRate:
        return 'Savings Rate';
      case InsightType.budgetExhaustion:
        return 'Budget Pace';
      case InsightType.frequencyChange:
        return 'Activity Pace';
      case InsightType.anomaly:
        return 'Unusual Spending';
    }
  }
}

enum InsightSeverity { info, warning, success, neutral }

class Insight {
  final String id;
  final InsightType type;
  final String title;
  final String description;
  final InsightSeverity severity;
  final String? dateRange;
  final Map<String, dynamic> supportingValues;
  final DateTime createdAt;
  final bool isDismissed;

  const Insight({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.severity = InsightSeverity.info,
    this.dateRange,
    this.supportingValues = const {},
    required this.createdAt,
    this.isDismissed = false,
  });

  Insight copyWith({
    String? id,
    InsightType? type,
    String? title,
    String? description,
    InsightSeverity? severity,
    String? dateRange,
    Map<String, dynamic>? supportingValues,
    DateTime? createdAt,
    bool? isDismissed,
  }) {
    return Insight(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      dateRange: dateRange ?? this.dateRange,
      supportingValues: supportingValues ?? this.supportingValues,
      createdAt: createdAt ?? this.createdAt,
      isDismissed: isDismissed ?? this.isDismissed,
    );
  }
}
