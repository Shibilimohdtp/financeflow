import 'package:flutter/material.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../models/account.dart';
import '../../shared/widgets/ff_account_visuals.dart';
import '../../shared/widgets/ff_consequence_line.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';

/// Pick the account an EMI is paid from (sheet archetype C, choice). One
/// grouped list of accounts with their live balance; the current one has a
/// check. Tapping a row picks it and closes the sheet.
Future<Account?> showPaymentAccountPicker({
  required BuildContext context,
  required List<Account> accounts,
  String? selectedAccountId,
}) {
  final usable = accounts.where((a) => !a.isArchived).toList();
  return showFfSheet<Account>(
    context,
    builder:
        (context) => FfSheet(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const FfSheetHeader(
              title: 'Paying account',
              subtitle: 'Where the EMI is taken from each month',
            ),
            FfSheetBody(
              children: [
                FfGroupedContainer(
                  children: [
                    for (final account in usable)
                      FfRow(
                        title: account.name,
                        subtitle:
                            '${account.displaySubtitle} · '
                            '${CurrencyFormatter.formatAmount(account.currentBalance)}',
                        icon: FfAccountVisuals.iconFor(account.type),
                        iconTone: FfTone.neutral,
                        selected: account.id == selectedAccountId,
                        onTap: () => Navigator.of(context).pop(account),
                      ),
                  ],
                ),
                const SizedBox(height: FfSheetTokens.itemGap),
                const FfConsequenceLine(
                  text: 'Choosing an account here does not move any money yet.',
                  icon: Icons.info_outline_rounded,
                  tone: FfTone.neutral,
                ),
              ],
            ),
          ],
        ),
  );
}
