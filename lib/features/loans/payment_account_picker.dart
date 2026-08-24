import 'package:flutter/material.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../models/account.dart';
import '../../theme/stillwater_tokens.dart';

Future<Account?> showPaymentAccountPicker({
  required BuildContext context,
  required List<Account> accounts,
  String? selectedAccountId,
}) {
  return showModalBottomSheet<Account>(
    context: context,
    showDragHandle: true,
    builder:
        (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: StillwaterTokens.spaceMd),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: StillwaterTokens.spaceLg,
                  ),
                  child: Text(
                    'Paying account',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: StillwaterTokens.spaceXs),
                ...accounts
                    .where((account) => !account.isArchived)
                    .map(
                      (account) => ListTile(
                        leading: Icon(
                          account.id == selectedAccountId
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                        ),
                        title: Text(account.name),
                        subtitle: Text(
                          '${account.displaySubtitle} · ${CurrencyFormatter.formatINR(account.currentBalance)}',
                        ),
                        onTap: () => Navigator.of(context).pop(account),
                      ),
                    ),
              ],
            ),
          ),
        ),
  );
}
