import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/account.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_segmented_pill.dart';
import '../settings/settings_controller.dart';
import 'accounts_controller.dart';
import 'add_edit_account_sheet.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_menu.dart';
import '../../shared/widgets/ff_progress.dart';
import '../../shared/widgets/ff_surfaces.dart';
import '../../shared/widgets/ff_icon_tile.dart';
import '../../shared/widgets/ff_badge.dart';
import '../../theme/ff_tone.dart';
import '../../shared/widgets/ff_page_scaffold.dart';
import '../../theme/ff.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  bool _showArchived = false;
  String? _highlightedAccountId;

  Future<void> _showAddEditAccountSheet(
    BuildContext context, [
    Account? account,
  ]) async {
    final savedId = await showAddEditAccountSheet<String>(
      context,
      account: account,
    );
    if (savedId != null && mounted) {
      setState(() => _highlightedAccountId = savedId);
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (mounted && _highlightedAccountId == savedId) {
          setState(() => _highlightedAccountId = null);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsWithBalancesProvider);
    final settings = ref.watch(settingsStreamProvider).value;
    final isPrivacyBlur = settings?.isPrivacyBlurEnabled ?? false;

    return FfPageScaffold(
      title: 'Financial Accounts',
      subtitle: 'Balances, on-device',
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'accounts_fab',
        tooltip: 'Add account',
        onPressed: () => _showAddEditAccountSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add account'),
      ),
      body: accountsAsync.when(
        data: (allAccounts) {
          final activeAccounts =
              allAccounts.where((a) => !a.isArchived).toList();
          final archivedAccounts =
              allAccounts.where((a) => a.isArchived).toList();
          final displayAccounts =
              _showArchived ? archivedAccounts : activeAccounts;
          final visibleBalance = activeAccounts.fold<double>(
            0,
            (total, account) => total + account.currentBalance,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              FfSpace.pageMargin,
              FfSpace.md,
              FfSpace.pageMargin,
              104,
            ),
            children: [
              // ── 1. Total Net Balance Hero ────────────────────────────────
              if (!_showArchived) ...[
                FfHeroCard(
                  tone: FfHeroTone.moss,
                  title: 'Net balance',
                  subtitle:
                      'Across ${activeAccounts.length} active on-device ${activeAccounts.length == 1 ? 'account' : 'accounts'}',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: FfAmountText(
                          amount: visibleBalance,
                          size: FfAmountSize.hero,
                          tone: FfTone.neutral,
                          showSign: visibleBalance < 0,
                          isBlurred: isPrivacyBlur,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isPrivacyBlur
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: FfIconSize.lg,
                        ),
                        tooltip:
                            isPrivacyBlur ? 'Show balance' : 'Hide balance',
                        onPressed: () {
                          ref
                              .read(settingsControllerProvider.notifier)
                              .setPrivacyBlurEnabled(!isPrivacyBlur);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: FfSpace.lg),
              ],

              // ── 2. Segmented Pill Tab Bar ────────────────────────────────
              FfSegmentedPill<bool>(
                options: [
                  FfSegmentOption(
                    value: false,
                    label: 'Active (${activeAccounts.length})',
                  ),
                  FfSegmentOption(
                    value: true,
                    label: 'Archived (${archivedAccounts.length})',
                  ),
                ],
                selectedValue: _showArchived,
                onSelected: (val) {
                  setState(() {
                    _showArchived = val;
                  });
                },
              ),

              const SizedBox(height: FfSpace.lg),

              // ── 3. Accounts List Section ─────────────────────────────────
              FfSectionHeader(
                title: _showArchived ? 'Archived Accounts' : 'Active Accounts',
              ),

              if (displayAccounts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: FfSpace.x2l),
                  child: FfEmptyState(
                    icon:
                        _showArchived
                            ? Icons.archive_outlined
                            : Icons.account_balance_wallet_outlined,
                    title:
                        _showArchived
                            ? 'No archived accounts'
                            : 'No active accounts',
                    description:
                        _showArchived
                            ? 'Accounts you archive will be stored here safely without affecting active balances.'
                            : 'Create a local bank account, cash wallet, or card to track balances on-device.',
                    actionLabel: _showArchived ? null : 'Add Account',
                    onAction:
                        _showArchived
                            ? null
                            : () => _showAddEditAccountSheet(context),
                  ),
                )
              else
                FfGroupedContainer(
                  children:
                      displayAccounts.map((acc) {
                        final typeLabel = acc.type.displayName;
                        final institution = acc.institutionName;
                        final masked = acc.maskedIdentifier;

                        final subtitleParts = <String>[];
                        if (institution != null && institution.isNotEmpty) {
                          subtitleParts.add(institution);
                        } else {
                          subtitleParts.add(typeLabel);
                        }
                        if (masked != null && masked.isNotEmpty) {
                          subtitleParts.add(masked);
                        }
                        if (_showArchived) {
                          subtitleParts.add('Archived');
                        }

                        return FfRow(
                          selected: acc.id == _highlightedAccountId,
                          leading: FfIconTile(
                            icon: _getAccountTypeIcon(acc.type),
                          ),
                          title: acc.name,
                          subtitle: subtitleParts.join(' · '),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (acc.isArchived)
                                const Padding(
                                  padding: EdgeInsetsDirectional.only(
                                    end: FfSpace.sm,
                                  ),
                                  child: FfBadge(label: 'Archived'),
                                ),
                              FfAmountText(
                                amount: acc.currentBalance,
                                size: FfAmountSize.sm,
                                showSign: false,
                                isBlurred: isPrivacyBlur,
                              ),
                              const SizedBox(width: FfSpace.xs),
                              FfMenuButton<String>(
                                tooltip: 'Account options',
                                items: [
                                  const FfMenuItem(
                                    value: 'edit',
                                    label: 'Edit details',
                                    icon: Icons.edit_outlined,
                                  ),
                                  FfMenuItem(
                                    value: 'archive',
                                    label:
                                        acc.isArchived
                                            ? 'Restore account'
                                            : 'Archive account',
                                    icon:
                                        acc.isArchived
                                            ? Icons.unarchive_outlined
                                            : Icons.archive_outlined,
                                  ),
                                  const FfMenuItem(
                                    value: 'delete',
                                    label: 'Delete account',
                                    icon: Icons.delete_outline_rounded,
                                    destructive: true,
                                  ),
                                ],
                                onSelected: (val) async {
                                  if (val == 'edit') {
                                    _showAddEditAccountSheet(context, acc);
                                  } else if (val == 'archive') {
                                    await ref
                                        .read(
                                          accountsControllerProvider.notifier,
                                        )
                                        .archiveAccount(
                                          acc.id,
                                          !acc.isArchived,
                                        );
                                    if (context.mounted) {
                                      FfToast.show(
                                        context,
                                        message:
                                            acc.isArchived
                                                ? 'Account restored to active.'
                                                : 'Account archived.',
                                      );
                                    }
                                  } else if (val == 'delete') {
                                    final confirmed = await FfDialog.confirm(
                                      context,
                                      title: 'Delete Account?',
                                      message:
                                          'Are you sure you want to permanently delete "${acc.name}" from this device?',
                                      confirmLabel: 'Delete',
                                      destructive: true,
                                    );
                                    if (confirmed == true && context.mounted) {
                                      await ref
                                          .read(
                                            accountsControllerProvider.notifier,
                                          )
                                          .deleteAccount(acc.id);
                                      if (context.mounted) {
                                        FfToast.show(
                                          context,
                                          message: 'Account deleted.',
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                          onTap: () => _showAddEditAccountSheet(context, acc),
                          showChevron: false,
                        );
                      }).toList(),
                ),
            ],
          );
        },
        loading:
            () => const Center(
              child: Padding(
                padding: EdgeInsets.all(FfSpace.x4l),
                child: FfLoading(),
              ),
            ),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  static IconData _getAccountTypeIcon(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return Icons.account_balance_outlined;
      case AccountType.cash:
        return Icons.payments_outlined;
      case AccountType.creditCard:
        return Icons.credit_card_outlined;
      case AccountType.upi:
        return Icons.qr_code_rounded;
      case AccountType.investment:
        return Icons.show_chart_rounded;
      case AccountType.business:
        return Icons.storefront_outlined;
    }
  }
}
