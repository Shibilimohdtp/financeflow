import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/ingestion/parsed_transaction.dart';
import '../../models/transaction.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../theme/stillwater_tokens.dart';
import '../accounts/accounts_controller.dart';
import '../categories/categories_controller.dart';
import 'csv_import_controller.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_divider.dart';

class CsvImportScreen extends ConsumerStatefulWidget {
  const CsvImportScreen({super.key});

  @override
  ConsumerState<CsvImportScreen> createState() => _CsvImportScreenState();
}

class _CsvImportScreenState extends ConsumerState<CsvImportScreen> {
  final TextEditingController _pasteController = TextEditingController();
  bool _showPasteArea = false;

  @override
  void dispose() {
    _pasteController.dispose();
    super.dispose();
  }

  Future<void> _pickCsvFile() async {
    try {
      final result = await FilePicker.pickFiles(
        dialogTitle: 'Select Bank Statement CSV',
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        String content = '';
        if (file.bytes != null) {
          content = utf8.decode(file.bytes!);
        } else if (file.path != null) {
          content = await File(file.path!).readAsString();
        }

        if (content.trim().isNotEmpty) {
          ref
              .read(csvImportControllerProvider.notifier)
              .loadCsvContent(content, fileName: file.name);
        } else {
          if (mounted) {
            FfToast.show(
              context,
              tone: FfToastTone.warning,
              message: 'The selected file is empty.',
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        FfToast.show(
          context,
          tone: FfToastTone.error,
          message: 'Could not open CSV file: $e',
        );
      }
    }
  }

  void _loadSampleData(String sampleType) {
    String sampleCsv = '';
    String fileName = '';

    if (sampleType == 'hdfc') {
      fileName = 'HDFC_Bank_Statement.csv';
      sampleCsv =
          '''Date,Narration,Chq/Ref No,Value Dt,Withdrawal Amt,Deposit Amt,Closing Balance
22/08/2026,UPI-SWIGGY-swiggy@icici-42352345,42352345,22/08/2026,450.00,,12450.00
21/08/2026,AMZN PAY INDIA PVT LTD,98765432,21/08/2026,1299.00,,12900.00
20/08/2026,SALARY CREDIT FROM ACME CORP,SAL202608,20/08/2026,,85000.00,14199.00
19/08/2026,INDIAN OIL CORP PETROL PUMP,IOCL8765,19/08/2026,2000.00,,99199.00
18/08/2026,NETFLIX ENTERTAINMENT SERVICES,NFLX1122,18/08/2026,649.00,,101199.00''';
    } else if (sampleType == 'icici') {
      fileName = 'ICICI_Statement.csv';
      sampleCsv = '''Transaction Date,Description,Debit,Credit,Ref Number
22-Aug-2026,Zomato Online Ordering,380.00,,ZOM4412
21-Aug-2026,Uber India Systems Cabs,520.50,,UBR9012
20-Aug-2026,UPI Transfer from Friend,,1500.00,UPI5511
19-Aug-2026,Blinkit Commerce Pvt Ltd,640.00,,BLK7788''';
    } else {
      fileName = 'General_Statement.csv';
      sampleCsv = '''Date,Merchant,Amount,Type,Category
2026-08-22,Starbucks Coffee,350.00,Expense,Dining
2026-08-21,Freelance Project Payment,25000.00,Income,Salary
2026-08-20,Airtel Prepaid Mobile,499.00,Expense,Bills
2026-08-19,DMart Groceries Superstore,2450.00,Expense,Groceries''';
    }

    ref
        .read(csvImportControllerProvider.notifier)
        .loadCsvContent(sampleCsv, fileName: fileName);
  }

  void _showMappingSheet(BuildContext context) {
    final state = ref.read(csvImportControllerProvider);
    final headers = state.headers;
    final mapping = state.columnMapping;

    showFfSheet(
      context,
      builder:
          (ctx) => StatefulBuilder(
            builder: (ctx, setModalState) {
              return FfSheet(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FfSheetHeader(
                    title: 'Map CSV Columns',
                    subtitle:
                        'Select which column in your CSV matches each transaction field',
                  ),
                  const FfDivider(),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: StillwaterTokens.spaceLg,
                        vertical: StillwaterTokens.spaceMd,
                      ),
                      children: [
                        _buildDropdownRow(
                          'Date Column *',
                          mapping.dateIndex,
                          headers,
                          (idx) {
                            final newMap = mapping.copyWith(
                              dateIndex: idx,
                              clearDate: idx == null,
                            );
                            ref
                                .read(csvImportControllerProvider.notifier)
                                .updateMapping(newMap);
                            Navigator.of(ctx).pop();
                          },
                        ),
                        _buildDropdownRow(
                          'Merchant / Narration *',
                          mapping.merchantIndex,
                          headers,
                          (idx) {
                            final newMap = mapping.copyWith(
                              merchantIndex: idx,
                              clearMerchant: idx == null,
                            );
                            ref
                                .read(csvImportControllerProvider.notifier)
                                .updateMapping(newMap);
                            Navigator.of(ctx).pop();
                          },
                        ),
                        _buildDropdownRow(
                          'Debit Column',
                          mapping.debitIndex,
                          headers,
                          (idx) {
                            final newMap = mapping.copyWith(
                              debitIndex: idx,
                              clearDebit: idx == null,
                            );
                            ref
                                .read(csvImportControllerProvider.notifier)
                                .updateMapping(newMap);
                            Navigator.of(ctx).pop();
                          },
                        ),
                        _buildDropdownRow(
                          'Credit Column',
                          mapping.creditIndex,
                          headers,
                          (idx) {
                            final newMap = mapping.copyWith(
                              creditIndex: idx,
                              clearCredit: idx == null,
                            );
                            ref
                                .read(csvImportControllerProvider.notifier)
                                .updateMapping(newMap);
                            Navigator.of(ctx).pop();
                          },
                        ),
                        _buildDropdownRow(
                          'Amount (Single Column)',
                          mapping.amountIndex,
                          headers,
                          (idx) {
                            final newMap = mapping.copyWith(
                              amountIndex: idx,
                              clearAmount: idx == null,
                            );
                            ref
                                .read(csvImportControllerProvider.notifier)
                                .updateMapping(newMap);
                            Navigator.of(ctx).pop();
                          },
                        ),
                        _buildDropdownRow(
                          'Reference / UTR',
                          mapping.referenceIndex,
                          headers,
                          (idx) {
                            final newMap = mapping.copyWith(
                              referenceIndex: idx,
                              clearReference: idx == null,
                            );
                            ref
                                .read(csvImportControllerProvider.notifier)
                                .updateMapping(newMap);
                            Navigator.of(ctx).pop();
                          },
                        ),
                        _buildDropdownRow(
                          'Category',
                          mapping.categoryIndex,
                          headers,
                          (idx) {
                            final newMap = mapping.copyWith(
                              categoryIndex: idx,
                              clearCategory: idx == null,
                            );
                            ref
                                .read(csvImportControllerProvider.notifier)
                                .updateMapping(newMap);
                            Navigator.of(ctx).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }

  Widget _buildDropdownRow(
    String label,
    int? currentIndex,
    List<String> headers,
    ValueChanged<int?> onChanged,
  ) {
    final theme = context.theme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: StillwaterTokens.space2Xs),
      padding: const EdgeInsets.symmetric(
        horizontal: StillwaterTokens.spaceMd,
        vertical: StillwaterTokens.spaceXs,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
        border: Border.all(
          color: theme.dividerColor,
          width: StillwaterTokens.borderWidthHairline,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          DropdownButton<int?>(
            value:
                (currentIndex != null &&
                        currentIndex >= 0 &&
                        currentIndex < headers.length)
                    ? currentIndex
                    : null,
            hint: const Text('Select Column'),
            underline: const SizedBox.shrink(),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('None / Skip'),
              ),
              ...headers.asMap().entries.map((e) {
                return DropdownMenuItem<int?>(
                  value: e.key,
                  child: Text(
                    e.value.length > 20
                        ? '${e.value.substring(0, 18)}...'
                        : e.value,
                  ),
                );
              }),
            ],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final state = ref.watch(csvImportControllerProvider);
    final categories = ref.watch(categoriesStreamProvider).value ?? [];
    final accounts = ref.watch(rawAccountsStreamProvider).value ?? [];

    return Scaffold(
      appBar: FfAppBar(
        title: 'Import CSV Statement',
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceLg),
            child: Center(
              child: FfPrivacyBadge(label: '100% Offline', iconOnly: true),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── 1. Offline Privacy Notice Banner ──────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: StillwaterTokens.spaceLg,
              vertical: StillwaterTokens.spaceSm,
            ),
            color: context.secColors.verified.withValues(alpha: 0.1),
            child: Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 18,
                  color: context.secColors.verified,
                ),
                const SizedBox(width: StillwaterTokens.spaceSm),
                Expanded(
                  child: Text(
                    'Files are read locally on this device. Statement data never leaves your phone.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.secColors.verified,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 2. Loading / Progress State ──────────────────────────────
          if (state.isLoading) ...[
            LinearProgressIndicator(
              backgroundColor: theme.colorScheme.surfaceContainerLow,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
            if (state.progressStep != null)
              Padding(
                padding: const EdgeInsets.all(StillwaterTokens.spaceSm),
                child: Text(
                  state.progressStep!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ),
          ],

          // ── 3. Error Banner ──────────────────────────────────────────
          if (state.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(StillwaterTokens.spaceSm),
              margin: const EdgeInsets.all(StillwaterTokens.spaceMd),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusSm),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 18,
                  ),
                  const SizedBox(width: StillwaterTokens.spaceXs),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── 4. Main Body Content ─────────────────────────────────────
          Expanded(
            child:
                !state.hasSession
                    ? _buildInitialFileSelectionView(context)
                    : _buildReviewSessionView(
                      context,
                      state.session!,
                      categories,
                      accounts,
                    ),
          ),

          // ── 5. Commit Action Bottom Bar ──────────────────────────────
          if (state.hasSession) _buildBottomCommitBar(context, state.session!),
        ],
      ),
    );
  }

  Widget _buildInitialFileSelectionView(BuildContext context) {
    final theme = context.theme;

    return ListView(
      padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
      children: [
        Container(
          padding: const EdgeInsets.all(StillwaterTokens.spaceXl),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
            border: Border.all(
              color: theme.dividerColor,
              width: StillwaterTokens.borderWidthHairline,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(
                    StillwaterTokens.radiusMd,
                  ),
                ),
                child: Icon(
                  Icons.file_upload_outlined,
                  size: 24,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: StillwaterTokens.spaceMd),
              Text(
                'Select Bank Statement CSV',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: StillwaterTokens.spaceXs),
              Text(
                'Supports HDFC, ICICI, SBI, Axis, and custom CSV statement formats.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: StillwaterTokens.spaceLg),
              FfButton(
                label: 'Choose CSV File',
                leadingIcon: const Icon(Icons.folder_open_rounded, size: 18),
                onPressed: _pickCsvFile,
              ),
            ],
          ),
        ),

        const SizedBox(height: StillwaterTokens.space2Xl),

        _SectionLabel(label: 'Or Test with Sample Data'),
        const SizedBox(height: StillwaterTokens.spaceXs),
        Row(
          children: [
            Expanded(
              child: FfButton(
                label: 'HDFC Sample',
                variant: FfButtonVariant.outlined,
                onPressed: () => _loadSampleData('hdfc'),
              ),
            ),
            const SizedBox(width: StillwaterTokens.spaceSm),
            Expanded(
              child: FfButton(
                label: 'ICICI Sample',
                variant: FfButtonVariant.outlined,
                onPressed: () => _loadSampleData('icici'),
              ),
            ),
            const SizedBox(width: StillwaterTokens.spaceSm),
            Expanded(
              child: FfButton(
                label: 'General CSV',
                variant: FfButtonVariant.outlined,
                onPressed: () => _loadSampleData('general'),
              ),
            ),
          ],
        ),

        const SizedBox(height: StillwaterTokens.space2Xl),

        _SectionLabel(label: 'Or Paste Raw CSV Text'),
        const SizedBox(height: StillwaterTokens.spaceXs),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
            border: Border.all(
              color: theme.dividerColor,
              width: StillwaterTokens.borderWidthHairline,
            ),
          ),
          child: Column(
            children: [
              ListTile(
                title: const Text('Paste Raw CSV Content'),
                subtitle: const Text('Enter CSV text directly from clipboard'),
                trailing: Icon(
                  _showPasteArea
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                ),
                onTap: () => setState(() => _showPasteArea = !_showPasteArea),
              ),
              if (_showPasteArea) ...[
                const FfDivider(),
                Padding(
                  padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
                  child: Column(
                    children: [
                      TextField(
                        controller: _pasteController,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          hintText: 'Paste CSV rows here...',
                          border: OutlineInputBorder(),
                        ),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: StillwaterTokens.spaceMd),
                      FfButton(
                        label: 'Parse Pasted CSV',
                        onPressed: () {
                          final text = _pasteController.text.trim();
                          if (text.isNotEmpty) {
                            ref
                                .read(csvImportControllerProvider.notifier)
                                .loadCsvContent(
                                  text,
                                  fileName: 'Pasted_Statement.csv',
                                );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: StillwaterTokens.space4Xl),
      ],
    );
  }

  Widget _buildReviewSessionView(
    BuildContext context,
    ImportReviewSession session,
    List<Category> categories,
    List<Account> accounts,
  ) {
    final theme = context.theme;

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: StillwaterTokens.spaceLg,
        vertical: StillwaterTokens.spaceMd,
      ),
      children: [
        // Session Summary Card
        Container(
          padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
            border: Border.all(
              color: theme.dividerColor,
              width: StillwaterTokens.borderWidthHairline,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      session.sourceName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.tune_rounded, size: 16),
                    label: const Text('Edit Columns'),
                    onPressed: () => _showMappingSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: StillwaterTokens.spaceSm),
              Row(
                children: [
                  _SummaryPill(
                    label: '${session.totalCount} Total',
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: StillwaterTokens.spaceXs),
                  _SummaryPill(
                    label: '${session.validCount} Valid',
                    color: context.secColors.verified,
                  ),
                  if (session.duplicateCount > 0) ...[
                    const SizedBox(width: StillwaterTokens.spaceXs),
                    _SummaryPill(
                      label: '${session.duplicateCount} Duplicates',
                      color: context.theme.colorScheme.error,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: StillwaterTokens.space2Xl),

        // Parsed Rows Preview
        _SectionLabel(label: 'Parsed Transactions (${session.items.length})'),
        const SizedBox(height: StillwaterTokens.spaceXs),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
            border: Border.all(
              color: theme.dividerColor,
              width: StillwaterTokens.borderWidthHairline,
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < session.items.length; i++) ...[
                _ParsedTransactionRow(
                  item: session.items[i],
                  categories: categories,
                ),
                if (i < session.items.length - 1) const FfDivider(),
              ],
            ],
          ),
        ),

        const SizedBox(height: StillwaterTokens.space4Xl),
      ],
    );
  }

  Widget _buildBottomCommitBar(
    BuildContext context,
    ImportReviewSession session,
  ) {
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
            width: StillwaterTokens.borderWidthHairline,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: FfButton(
                label: 'Discard',
                variant: FfButtonVariant.outlined,
                onPressed: () {
                  ref.read(csvImportControllerProvider.notifier).reset();
                },
              ),
            ),
            const SizedBox(width: StillwaterTokens.spaceMd),
            Expanded(
              flex: 2,
              child: FfButton(
                label: 'Import Transactions',
                leadingIcon: const Icon(Icons.check_rounded, size: 18),
                onPressed: () async {
                  final imported =
                      await ref
                          .read(csvImportControllerProvider.notifier)
                          .commitImport();
                  if (context.mounted) {
                    FfToast.show(
                      context,
                      message:
                          'Imported ${imported.length} transactions successfully.',
                    );
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParsedTransactionRow extends StatelessWidget {
  final ParsedTransaction item;
  final List<Category> categories;

  const _ParsedTransactionRow({required this.item, required this.categories});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isIncome = item.type == TransactionType.income;
    final amountColor =
        isIncome ? context.finColors.income : context.finColors.expense;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: StillwaterTokens.spaceMd,
        vertical: StillwaterTokens.spaceSm,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              size: 18,
              color: amountColor,
            ),
          ),
          const SizedBox(width: StillwaterTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.normalizedMerchant,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${DateFormatter.formatTransactionDate(item.date)} · ${item.categoryName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '−'} ${CurrencyFormatter.formatAmount(item.amount)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
              ),
              if (item.duplicateStatus != DuplicateMatchLevel.none)
                Text(
                  'Duplicate',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: context.theme.colorScheme.error,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final Color color;

  const _SummaryPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: StillwaterTokens.spaceSm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: StillwaterTokens.space2Xs),
      child: Text(
        label.toUpperCase(),
        style: context.textTheme.labelSmall?.copyWith(
          letterSpacing: 0.8,
          color: context.theme.colorScheme.secondary,
          fontSize: 10,
        ),
      ),
    );
  }
}
