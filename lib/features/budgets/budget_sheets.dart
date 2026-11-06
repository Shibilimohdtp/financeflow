import 'package:flutter/material.dart';

import '../../models/budget.dart';
import '../../shared/widgets/ff_sheet.dart';
import 'add_edit_budget_sheet.dart';

/// Opens the add/edit budget sheet: the one place that opens it.
Future<void> openBudgetSheet(BuildContext context, {Budget? initial}) =>
    showFfSheet<void>(
      context,
      builder: (_) => AddEditBudgetSheet(initialBudget: initial),
    );
