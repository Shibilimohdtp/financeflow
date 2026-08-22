enum AccountType {
  bank,
  cash,
  creditCard,
  upi,
  investment,
  business;

  String get displayName {
    switch (this) {
      case AccountType.bank:
        return 'Bank Account';
      case AccountType.cash:
        return 'Cash Wallet';
      case AccountType.creditCard:
        return 'Credit Card';
      case AccountType.upi:
        return 'UPI Account';
      case AccountType.investment:
        return 'Investment';
      case AccountType.business:
        return 'Business Account';
    }
  }

  static AccountType fromString(String val) {
    switch (val.toLowerCase()) {
      case 'bank':
        return AccountType.bank;
      case 'cash':
        return AccountType.cash;
      case 'credit_card':
      case 'creditcard':
        return AccountType.creditCard;
      case 'upi':
        return AccountType.upi;
      case 'investment':
        return AccountType.investment;
      case 'business':
        return AccountType.business;
      default:
        return AccountType.bank;
    }
  }

  String toDbString() {
    switch (this) {
      case AccountType.bank:
        return 'bank';
      case AccountType.cash:
        return 'cash';
      case AccountType.creditCard:
        return 'credit_card';
      case AccountType.upi:
        return 'upi';
      case AccountType.investment:
        return 'investment';
      case AccountType.business:
        return 'business';
    }
  }
}

class Account {
  final String id;
  final String name;
  final AccountType type;
  final String? institutionName;
  final String? maskedIdentifier;
  final double openingBalance;
  final double currentBalance;
  final String currency;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Account({
    required this.id,
    required this.name,
    required this.type,
    this.institutionName,
    this.maskedIdentifier,
    this.openingBalance = 0.0,
    this.currentBalance = 0.0,
    this.currency = 'INR',
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Account copyWith({
    String? id,
    String? name,
    AccountType? type,
    String? institutionName,
    String? maskedIdentifier,
    double? openingBalance,
    double? currentBalance,
    String? currency,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      institutionName: institutionName ?? this.institutionName,
      maskedIdentifier: maskedIdentifier ?? this.maskedIdentifier,
      openingBalance: openingBalance ?? this.openingBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      currency: currency ?? this.currency,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displaySubtitle {
    final parts = <String>[];
    if (institutionName != null && institutionName!.isNotEmpty) {
      parts.add(institutionName!);
    }
    if (maskedIdentifier != null && maskedIdentifier!.isNotEmpty) {
      parts.add(maskedIdentifier!);
    }
    if (parts.isEmpty) {
      return type.displayName;
    }
    return parts.join(' · ');
  }
}
