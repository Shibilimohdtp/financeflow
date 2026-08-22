enum AlertType {
  budgetApproachingLimit,
  budgetExceeded,
  upcomingSubscriptionRenewal,
  upcomingEmi,
  largeExpense,
  unusualSpending,
  savingsGoalReminder,
  incomeReceived,
  needsReviewCount,
  backupReminder;

  String get displayName {
    switch (this) {
      case AlertType.budgetApproachingLimit:
        return 'Budget Nearing Limit';
      case AlertType.budgetExceeded:
        return 'Budget Exceeded';
      case AlertType.upcomingSubscriptionRenewal:
        return 'Subscription Renewal';
      case AlertType.upcomingEmi:
        return 'Upcoming EMI Due';
      case AlertType.largeExpense:
        return 'Large Expense';
      case AlertType.unusualSpending:
        return 'Unusual Spending';
      case AlertType.savingsGoalReminder:
        return 'Savings Goal Reminder';
      case AlertType.incomeReceived:
        return 'Income Received';
      case AlertType.needsReviewCount:
        return 'Transactions Need Review';
      case AlertType.backupReminder:
        return 'Backup Reminder';
    }
  }

  static AlertType fromString(String val) {
    switch (val.toLowerCase()) {
      case 'budget_approaching_limit':
      case 'budgetapproachinglimit':
        return AlertType.budgetApproachingLimit;
      case 'budget_exceeded':
      case 'budgetexceeded':
        return AlertType.budgetExceeded;
      case 'upcoming_subscription_renewal':
      case 'upcomingsubscriptionrenewal':
        return AlertType.upcomingSubscriptionRenewal;
      case 'upcoming_emi':
      case 'upcomingemi':
        return AlertType.upcomingEmi;
      case 'large_expense':
      case 'largeexpense':
        return AlertType.largeExpense;
      case 'unusual_spending':
      case 'unusualspending':
        return AlertType.unusualSpending;
      case 'savings_goal_reminder':
      case 'savingsgoalreminder':
        return AlertType.savingsGoalReminder;
      case 'income_received':
      case 'incomereceived':
        return AlertType.incomeReceived;
      case 'needs_review_count':
      case 'needsreviewcount':
        return AlertType.needsReviewCount;
      case 'backup_reminder':
      case 'backupreminder':
      default:
        return AlertType.backupReminder;
    }
  }

  String toDbString() {
    switch (this) {
      case AlertType.budgetApproachingLimit:
        return 'budget_approaching_limit';
      case AlertType.budgetExceeded:
        return 'budget_exceeded';
      case AlertType.upcomingSubscriptionRenewal:
        return 'upcoming_subscription_renewal';
      case AlertType.upcomingEmi:
        return 'upcoming_emi';
      case AlertType.largeExpense:
        return 'large_expense';
      case AlertType.unusualSpending:
        return 'unusual_spending';
      case AlertType.savingsGoalReminder:
        return 'savings_goal_reminder';
      case AlertType.incomeReceived:
        return 'income_received';
      case AlertType.needsReviewCount:
        return 'needs_review_count';
      case AlertType.backupReminder:
        return 'backup_reminder';
    }
  }
}

enum AlertSeverity {
  informational,
  attention,
  urgent;

  String get displayName {
    switch (this) {
      case AlertSeverity.informational:
        return 'Info';
      case AlertSeverity.attention:
        return 'Attention';
      case AlertSeverity.urgent:
        return 'Urgent';
    }
  }

  static AlertSeverity fromString(String val) {
    switch (val.toLowerCase()) {
      case 'urgent':
        return AlertSeverity.urgent;
      case 'attention':
        return AlertSeverity.attention;
      case 'informational':
      default:
        return AlertSeverity.informational;
    }
  }

  String toDbString() => name;
}

class AlertItem {
  final String id;
  final AlertType type;
  final String title;
  final String message;
  final AlertSeverity severity;
  final String? relatedEntityType;
  final String? relatedEntityId;
  final DateTime scheduledAt;
  final DateTime createdAt;
  final bool isRead;
  final bool isDismissed;
  final int? localNotificationId;

  const AlertItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.severity = AlertSeverity.informational,
    this.relatedEntityType,
    this.relatedEntityId,
    required this.scheduledAt,
    required this.createdAt,
    this.isRead = false,
    this.isDismissed = false,
    this.localNotificationId,
  });

  AlertItem copyWith({
    String? id,
    AlertType? type,
    String? title,
    String? message,
    AlertSeverity? severity,
    String? relatedEntityType,
    String? relatedEntityId,
    DateTime? scheduledAt,
    DateTime? createdAt,
    bool? isRead,
    bool? isDismissed,
    int? localNotificationId,
  }) {
    return AlertItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isDismissed: isDismissed ?? this.isDismissed,
      localNotificationId: localNotificationId ?? this.localNotificationId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'message': message,
    'severity': severity.name,
    'relatedEntityType': relatedEntityType,
    'relatedEntityId': relatedEntityId,
    'scheduledAt': scheduledAt.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
    'isDismissed': isDismissed,
    'localNotificationId': localNotificationId,
  };

  factory AlertItem.fromJson(Map<String, dynamic> json) => AlertItem(
    id: json['id'] as String,
    type: AlertType.fromString(json['type'] as String),
    title: json['title'] as String,
    message: json['message'] as String,
    severity: AlertSeverity.fromString(
      json['severity'] as String? ?? 'informational',
    ),
    relatedEntityType: json['relatedEntityType'] as String?,
    relatedEntityId: json['relatedEntityId'] as String?,
    scheduledAt: DateTime.parse(json['scheduledAt'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
    isRead: json['isRead'] as bool? ?? false,
    isDismissed: json['isDismissed'] as bool? ?? false,
    localNotificationId: json['localNotificationId'] as int?,
  );
}
