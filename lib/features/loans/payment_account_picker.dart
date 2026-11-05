import 'package:flutter/material.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../models/account.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../theme/ff.dart';

Future<Account?> showPaymentAccountPicker({
  required BuildContext context,
  required List<Account> accounts,
  String? selectedAccountId,
}) {
  return showFfSheet<Account>(
    context,
    builder:
        (context) => FfSheet(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const FfSheetHeader(title: 'Paying account'),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: FfSpace.md),
                children: [
                  for (final account in accounts.where((a) => !a.isArchived))
                    ListTile(
                      leading: Icon(
                        account.id == selectedAccountId
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                      ),
                      title: Text(account.name),
                      subtitle: Text(
                        '${account.displaySubtitle} · ${CurrencyFormatter.formatAmount(account.currentBalance)}',
                      ),
                      onTap: () => Navigator.of(context).pop(account),
                    ),
                ],
              ),
            ),
          ],
        ),
  );
}
