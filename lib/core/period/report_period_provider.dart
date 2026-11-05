import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'period.dart';

/// The reporting period shared by Home and Insights, so both always show the
/// same window. Defaults to the current month.
final reportPeriodProvider = StateProvider<Period>(
  (ref) => Period.containing(PeriodUnit.month, DateTime.now()),
);
