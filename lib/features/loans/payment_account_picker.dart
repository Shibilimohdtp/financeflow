import 'package:flutter/material.dart';

import '../../models/account.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_consequence_line.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';

/// Pick the account an EMI is paid from. Each account is a tile with its
/// live balance, and the selected one carries a check and a short line.
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
              subtitle: 'Where the EMI is taken from each month.',
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(
                  FfSpace.lg,
                  FfSpace.xs,
                  FfSpace.lg,
                  FfSpace.lg,
                ),
                itemCount: usable.length,
                separatorBuilder: (_, __) => const SizedBox(height: FfSpace.sm),
                itemBuilder: (context, index) {
                  final account = usable[index];
                  final selected = account.id == selectedAccountId;
                  return FfCard(
                    padding: const EdgeInsets.all(FfSpace.md),
                    onTap: () => Navigator.of(context).pop(account),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              context.ff.color.actionPrimaryContainer,
                          child: Icon(
                            selected
                                ? Icons.check_rounded
                                : Icons.account_balance_wallet_outlined,
                            size: 18,
                            color: context.ff.color.onActionPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: FfSpace.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                account.name,
                                style: context.ff.text.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: FfSpace.x3s),
                              Text(
                                selected
                                    ? 'Currently selected · ${account.displaySubtitle}'
                                    : account.displaySubtitle,
                                style: context.ff.text.labelSm.copyWith(
                                  color: context.ff.color.secondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        FfAmountText(
                          amount: account.currentBalance,
                          size: FfAmountSize.sm,
                          showSign: false,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                FfSpace.lg,
                0,
                FfSpace.lg,
                FfSpace.lg,
              ),
              child: FfConsequenceLine(
                text: 'Choosing an account here does not move any money yet.',
                icon: Icons.info_outline_rounded,
                tone: FfTone.neutral,
              ),
            ),
          ],
        ),
  );
}
