class MoneyMath {
  MoneyMath._();

  /// One minor unit for the currencies currently supported by FinanceFlow.
  static const double tolerance = 0.01;

  /// Minor units per major unit (paise per rupee, cents per dollar…).
  static const int minorPerMajor = 100;

  static bool close(double a, double b, {double tolerance = tolerance}) =>
      (a - b).abs() <= tolerance;

  static double round(double value) => (value * 100).roundToDouble() / 100;

  /// Converts a ledger amount to integer minor units, rounding half away from
  /// zero. This is the only place a `double` amount becomes an integer, so
  /// every feature that sums in minor units agrees to the cent.
  static int toMinor(double value) => (value * minorPerMajor).round();

  static double fromMinor(int minor) => minor / minorPerMajor;

  /// Sums ledger amounts exactly: each value is rounded once, then added as
  /// integers, so the result never depends on summation order.
  static int sumMinor(Iterable<double> values) {
    var total = 0;
    for (final v in values) {
      total += toMinor(v);
    }
    return total;
  }

  /// Rounds a positive amount up to a "nice" figure for suggestions: about
  /// two significant steps, independent of currency (6,350 → 6,500;
  /// 2,700 → 2,800; 1,234 → 1,300; 85 → 85). Zero and negatives stay as is.
  static int niceCeilMinor(int minor) {
    if (minor <= 0) return minor;
    final major = (minor + minorPerMajor - 1) ~/ minorPerMajor;
    var magnitude = 1;
    while (magnitude * 10 <= major) {
      magnitude *= 10;
    }
    final int step;
    if (major >= 5 * magnitude) {
      step = magnitude ~/ 2;
    } else if (major >= 2 * magnitude) {
      step = magnitude ~/ 5;
    } else {
      step = magnitude ~/ 10;
    }
    if (step <= 1) return major * minorPerMajor;
    final rounded = ((major + step - 1) ~/ step) * step;
    return rounded * minorPerMajor;
  }
}
