enum AssetType {
  stocks,
  mutualFunds,
  fixedDeposits,
  recurringDeposits,
  ppf,
  nps,
  gold,
  crypto,
  realEstate,
  other;

  String get displayName {
    switch (this) {
      case AssetType.stocks:
        return 'Stocks & Equity';
      case AssetType.mutualFunds:
        return 'Mutual Funds';
      case AssetType.fixedDeposits:
        return 'Fixed Deposit (FD)';
      case AssetType.recurringDeposits:
        return 'Recurring Deposit (RD)';
      case AssetType.ppf:
        return 'Public Provident Fund (PPF)';
      case AssetType.nps:
        return 'National Pension Scheme (NPS)';
      case AssetType.gold:
        return 'Gold & Precious Metals';
      case AssetType.crypto:
        return 'Crypto';
      case AssetType.realEstate:
        return 'Real Estate';
      case AssetType.other:
        return 'Other Asset';
    }
  }

  static AssetType fromString(String val) {
    switch (val.toLowerCase()) {
      case 'stocks':
      case 'stock':
      case 'equity':
        return AssetType.stocks;
      case 'mutual_funds':
      case 'mutualfunds':
      case 'mf':
        return AssetType.mutualFunds;
      case 'fixed_deposits':
      case 'fixeddeposits':
      case 'fd':
        return AssetType.fixedDeposits;
      case 'recurring_deposits':
      case 'recurringdeposits':
      case 'rd':
        return AssetType.recurringDeposits;
      case 'ppf':
        return AssetType.ppf;
      case 'nps':
        return AssetType.nps;
      case 'gold':
        return AssetType.gold;
      case 'crypto':
        return AssetType.crypto;
      case 'real_estate':
      case 'realestate':
        return AssetType.realEstate;
      default:
        return AssetType.other;
    }
  }

  String toDbString() {
    switch (this) {
      case AssetType.stocks:
        return 'stocks';
      case AssetType.mutualFunds:
        return 'mutual_funds';
      case AssetType.fixedDeposits:
        return 'fixed_deposits';
      case AssetType.recurringDeposits:
        return 'recurring_deposits';
      case AssetType.ppf:
        return 'ppf';
      case AssetType.nps:
        return 'nps';
      case AssetType.gold:
        return 'gold';
      case AssetType.crypto:
        return 'crypto';
      case AssetType.realEstate:
        return 'real_estate';
      case AssetType.other:
        return 'other';
    }
  }
}

class Investment {
  final String id;
  final String name;
  final AssetType assetType;
  final String? accountId;
  final double quantityOrUnits;
  final double purchasePrice;
  final DateTime purchaseDate;
  final double currentValue; // User-entered value
  final double investedAmount;
  final double? realizedProfitLoss;
  final double unrealizedProfitLoss;
  final DateTime? lastValuationDate;
  final String? notes;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Investment({
    required this.id,
    required this.name,
    required this.assetType,
    this.accountId,
    this.quantityOrUnits = 1.0,
    required this.purchasePrice,
    required this.purchaseDate,
    required this.currentValue,
    required this.investedAmount,
    this.realizedProfitLoss,
    required this.unrealizedProfitLoss,
    this.lastValuationDate,
    this.notes,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Absolute gain / loss amount
  double get absoluteReturn => currentValue - investedAmount;

  /// Percentage gain / loss
  double get percentageReturn {
    if (investedAmount <= 0) return 0.0;
    return (absoluteReturn / investedAmount) * 100.0;
  }

  bool get isProfitable => absoluteReturn >= 0;

  Investment copyWith({
    String? id,
    String? name,
    AssetType? assetType,
    String? accountId,
    double? quantityOrUnits,
    double? purchasePrice,
    DateTime? purchaseDate,
    double? currentValue,
    double? investedAmount,
    double? realizedProfitLoss,
    double? unrealizedProfitLoss,
    DateTime? lastValuationDate,
    String? notes,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Investment(
      id: id ?? this.id,
      name: name ?? this.name,
      assetType: assetType ?? this.assetType,
      accountId: accountId ?? this.accountId,
      quantityOrUnits: quantityOrUnits ?? this.quantityOrUnits,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      currentValue: currentValue ?? this.currentValue,
      investedAmount: investedAmount ?? this.investedAmount,
      realizedProfitLoss: realizedProfitLoss ?? this.realizedProfitLoss,
      unrealizedProfitLoss: unrealizedProfitLoss ?? this.unrealizedProfitLoss,
      lastValuationDate: lastValuationDate ?? this.lastValuationDate,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'assetType': assetType.name,
    'accountId': accountId,
    'quantityOrUnits': quantityOrUnits,
    'purchasePrice': purchasePrice,
    'purchaseDate': purchaseDate.toIso8601String(),
    'currentValue': currentValue,
    'investedAmount': investedAmount,
    'realizedProfitLoss': realizedProfitLoss,
    'unrealizedProfitLoss': unrealizedProfitLoss,
    'lastValuationDate': lastValuationDate?.toIso8601String(),
    'notes': notes,
    'isArchived': isArchived,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Investment.fromJson(Map<String, dynamic> json) => Investment(
    id: json['id'] as String,
    name: json['name'] as String,
    assetType: AssetType.fromString(json['assetType'] as String? ?? 'other'),
    accountId: json['accountId'] as String?,
    quantityOrUnits: (json['quantityOrUnits'] as num?)?.toDouble() ?? 1.0,
    purchasePrice: (json['purchasePrice'] as num).toDouble(),
    purchaseDate: DateTime.parse(json['purchaseDate'] as String),
    currentValue: (json['currentValue'] as num).toDouble(),
    investedAmount: (json['investedAmount'] as num).toDouble(),
    realizedProfitLoss: (json['realizedProfitLoss'] as num?)?.toDouble(),
    unrealizedProfitLoss:
        (json['unrealizedProfitLoss'] as num?)?.toDouble() ?? 0.0,
    lastValuationDate:
        json['lastValuationDate'] != null
            ? DateTime.parse(json['lastValuationDate'] as String)
            : null,
    notes: json['notes'] as String?,
    isArchived: json['isArchived'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}
