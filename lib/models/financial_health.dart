enum HealthScoreGrade {
  excellent,
  strong,
  balanced,
  needsAttention,
  insufficientData;

  String get label {
    switch (this) {
      case HealthScoreGrade.excellent:
        return 'Excellent';
      case HealthScoreGrade.strong:
        return 'Strong';
      case HealthScoreGrade.balanced:
        return 'Balanced';
      case HealthScoreGrade.needsAttention:
        return 'Needs Attention';
      case HealthScoreGrade.insufficientData:
        return 'Building History';
    }
  }

  String get description {
    switch (this) {
      case HealthScoreGrade.excellent:
        return 'Your spending, savings, and budget discipline are in great alignment.';
      case HealthScoreGrade.strong:
        return 'You have solid cash flow and are consistently meeting your financial targets.';
      case HealthScoreGrade.balanced:
        return 'Your finances are steady with healthy room for savings growth.';
      case HealthScoreGrade.needsAttention:
        return 'Expenses are outpacing income or budgets are exceeding planned targets.';
      case HealthScoreGrade.insufficientData:
        return 'Keep logging transactions and budgets to see a personalized health score.';
    }
  }
}

class HealthScoreComponent {
  final String key;
  final String title;
  final double score; // 0 to 25
  final double maxScore; // 25
  final bool hasSufficientData;
  final String summary;
  final String detail;

  const HealthScoreComponent({
    required this.key,
    required this.title,
    required this.score,
    this.maxScore = 25.0,
    required this.hasSufficientData,
    required this.summary,
    required this.detail,
  });

  double get percentage =>
      hasSufficientData ? (score / maxScore).clamp(0.0, 1.0) : 0.0;
}

class FinancialHealthReport {
  final double totalScore; // 0 to 100
  final HealthScoreGrade grade;
  final List<HealthScoreComponent> components;
  final bool hasOverallSufficientData;
  final DateTime calculatedAt;

  const FinancialHealthReport({
    required this.totalScore,
    required this.grade,
    required this.components,
    required this.hasOverallSufficientData,
    required this.calculatedAt,
  });
}
