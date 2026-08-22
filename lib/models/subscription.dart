enum SubscriptionFrequency {
  weekly,
  monthly,
  quarterly,
  yearly,
  custom;

  String get displayName {
    switch (this) {
      case SubscriptionFrequency.weekly:
        return 'Weekly';
      case SubscriptionFrequency.monthly:
        return 'Monthly';
      case SubscriptionFrequency.quarterly:
        return 'Quarterly';
      case SubscriptionFrequency.yearly:
        return 'Yearly';
      case SubscriptionFrequency.custom:
        return 'Custom';
    }
  }

  static SubscriptionFrequency fromString(String value) {
    switch (value.toLowerCase()) {
      case 'weekly':
        return SubscriptionFrequency.weekly;
      case 'quarterly':
        return SubscriptionFrequency.quarterly;
      case 'yearly':
      case 'annually':
        return SubscriptionFrequency.yearly;
      case 'custom':
        return SubscriptionFrequency.custom;
      case 'monthly':
      default:
        return SubscriptionFrequency.monthly;
    }
  }

  String toDbString() => name;
}

enum SubscriptionStatus {
  active,
  paused,
  cancelled,
  needsReview;

  String get displayName {
    switch (this) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.paused:
        return 'Paused';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
      case SubscriptionStatus.needsReview:
        return 'Needs Review';
    }
  }

  static SubscriptionStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'paused':
        return SubscriptionStatus.paused;
      case 'cancelled':
      case 'canceled':
        return SubscriptionStatus.cancelled;
      case 'needs_review':
      case 'needsreview':
        return SubscriptionStatus.needsReview;
      case 'active':
      default:
        return SubscriptionStatus.active;
    }
  }

  String toDbString() {
    switch (this) {
      case SubscriptionStatus.needsReview:
        return 'needs_review';
      default:
        return name;
    }
  }
}

class Subscription {
  final String id;
  final String merchant;
  final String normalizedMerchant;
  final double amount;
  final String currency;
  final SubscriptionFrequency billingFrequency;
  final DateTime nextRenewalDate;
  final DateTime? lastPaymentDate;
  final String? accountId;
  final String category;
  final String? paymentMethod;
  final String? sourceTransactionId;
  final SubscriptionStatus status;
  final int reminderDaysBefore;
  final bool isReminderEnabled;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Subscription({
    required this.id,
    required this.merchant,
    required this.normalizedMerchant,
    required this.amount,
    this.currency = 'INR',
    this.billingFrequency = SubscriptionFrequency.monthly,
    required this.nextRenewalDate,
    this.lastPaymentDate,
    this.accountId,
    this.category = 'Subscriptions',
    this.paymentMethod,
    this.sourceTransactionId,
    this.status = SubscriptionStatus.active,
    this.reminderDaysBefore = 1,
    this.isReminderEnabled = true,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Monthly normalized cost
  double get monthlyEquivalentAmount {
    switch (billingFrequency) {
      case SubscriptionFrequency.weekly:
        return amount * (52.0 / 12.0);
      case SubscriptionFrequency.monthly:
        return amount;
      case SubscriptionFrequency.quarterly:
        return amount / 3.0;
      case SubscriptionFrequency.yearly:
        return amount / 12.0;
      case SubscriptionFrequency.custom:
        return amount;
    }
  }

  /// Yearly normalized cost
  double get yearlyEquivalentAmount {
    switch (billingFrequency) {
      case SubscriptionFrequency.weekly:
        return amount * 52.0;
      case SubscriptionFrequency.monthly:
        return amount * 12.0;
      case SubscriptionFrequency.quarterly:
        return amount * 4.0;
      case SubscriptionFrequency.yearly:
        return amount;
      case SubscriptionFrequency.custom:
        return amount * 12.0;
    }
  }

  int daysUntilRenewal({DateTime? referenceDate}) {
    final ref = referenceDate ?? DateTime.now();
    final today = DateTime(ref.year, ref.month, ref.day);
    final target = DateTime(
      nextRenewalDate.year,
      nextRenewalDate.month,
      nextRenewalDate.day,
    );
    return target.difference(today).inDays;
  }

  bool isDueSoon({int daysThreshold = 3, DateTime? referenceDate}) {
    if (status != SubscriptionStatus.active) return false;
    final diff = daysUntilRenewal(referenceDate: referenceDate);
    return diff >= 0 && diff <= daysThreshold;
  }

  Subscription copyWith({
    String? id,
    String? merchant,
    String? normalizedMerchant,
    double? amount,
    String? currency,
    SubscriptionFrequency? billingFrequency,
    DateTime? nextRenewalDate,
    DateTime? lastPaymentDate,
    String? accountId,
    String? category,
    String? paymentMethod,
    String? sourceTransactionId,
    SubscriptionStatus? status,
    int? reminderDaysBefore,
    bool? isReminderEnabled,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      merchant: merchant ?? this.merchant,
      normalizedMerchant: normalizedMerchant ?? this.normalizedMerchant,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      billingFrequency: billingFrequency ?? this.billingFrequency,
      nextRenewalDate: nextRenewalDate ?? this.nextRenewalDate,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      accountId: accountId ?? this.accountId,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      sourceTransactionId: sourceTransactionId ?? this.sourceTransactionId,
      status: status ?? this.status,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'merchant': merchant,
    'normalizedMerchant': normalizedMerchant,
    'amount': amount,
    'currency': currency,
    'billingFrequency': billingFrequency.name,
    'nextRenewalDate': nextRenewalDate.toIso8601String(),
    'lastPaymentDate': lastPaymentDate?.toIso8601String(),
    'accountId': accountId,
    'category': category,
    'paymentMethod': paymentMethod,
    'sourceTransactionId': sourceTransactionId,
    'status': status.name,
    'reminderDaysBefore': reminderDaysBefore,
    'isReminderEnabled': isReminderEnabled,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
    id: json['id'] as String,
    merchant: json['merchant'] as String,
    normalizedMerchant:
        json['normalizedMerchant'] as String? ??
        (json['merchant'] as String).toLowerCase(),
    amount: (json['amount'] as num).toDouble(),
    currency: json['currency'] as String? ?? 'INR',
    billingFrequency: SubscriptionFrequency.fromString(
      json['billingFrequency'] as String? ?? 'monthly',
    ),
    nextRenewalDate: DateTime.parse(json['nextRenewalDate'] as String),
    lastPaymentDate:
        json['lastPaymentDate'] != null
            ? DateTime.parse(json['lastPaymentDate'] as String)
            : null,
    accountId: json['accountId'] as String?,
    category: json['category'] as String? ?? 'Subscriptions',
    paymentMethod: json['paymentMethod'] as String?,
    sourceTransactionId: json['sourceTransactionId'] as String?,
    status: SubscriptionStatus.fromString(
      json['status'] as String? ?? 'active',
    ),
    reminderDaysBefore: json['reminderDaysBefore'] as int? ?? 1,
    isReminderEnabled: json['isReminderEnabled'] as bool? ?? true,
    notes: json['notes'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}
