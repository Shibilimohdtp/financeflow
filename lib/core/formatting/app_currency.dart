/// Display currencies the app supports. FinanceFlow keeps a single currency
/// for all amounts; switching it changes how amounts are shown, not their
/// values (there is no conversion).
enum AppCurrency {
  inr('INR', '₹', 'Indian Rupee'),
  usd('USD', r'$', 'US Dollar'),
  eur('EUR', '€', 'Euro'),
  gbp('GBP', '£', 'British Pound');

  final String code;
  final String symbol;
  final String displayName;

  const AppCurrency(this.code, this.symbol, this.displayName);

  /// Indian lakh/crore digit grouping (1,23,456) instead of thousands.
  bool get usesIndianGrouping => this == AppCurrency.inr;

  static AppCurrency fromCode(String? code) => AppCurrency.values.firstWhere(
    (c) => c.code == code,
    orElse: () => AppCurrency.inr,
  );
}
