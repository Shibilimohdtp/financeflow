class MoneyMath {
  MoneyMath._();

  /// One minor unit for the currencies currently supported by FinanceFlow.
  static const double tolerance = 0.01;

  static bool close(double a, double b, {double tolerance = tolerance}) =>
      (a - b).abs() <= tolerance;

  static double round(double value) => (value * 100).roundToDouble() / 100;
}
