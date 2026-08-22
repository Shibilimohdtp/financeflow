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
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import '../accounts/accounts_controller.dart';
import '../categories/categories_controller.dart';
import 'csv_import_controller.dart';

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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (ctx) => StatefulBuilder(
            builder: (ctx, setModalState) {
              return Container(
                padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Map CSV Columns',
                          style: context.textTheme.titleMedium,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: StillwaterTokens.spaceSm),
                    Text(
                      'Select which column in your CSV file matches each transaction field.',
                      style: context.textTheme.bodySmall,
                    ),
                    const SizedBox(height: StillwaterTokens.spaceMd),
                    Expanded(
                      child: ListView(
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
                ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: StillwaterTokens.spaceXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: context.textTheme.bodyMedium)),
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
      appBar: AppBar(
        title: const Text('Import CSV Statement'),
        actions: [
          if (state.hasSession)
            IconButton(
              icon: const Icon(Icons.tune_rounded),
              tooltip: 'Adjust Column Mapping',
              onPressed: () => _showMappingSheet(context),
            ),
        ],
      ),
      body: Column(
        children: [
          // 1. Offline Privacy Notice Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: StillwaterTokens.spaceMd,
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
                const SizedBox(width: StillwaterTokens.spaceXs),
                Expanded(
                  child: Text(
                    'Files are read only on this device. No statement data leaves your phone.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.secColors.verified,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Loading / Progress State
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

          // 3. Error Banner
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

          // 4. Main Body Content
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

          // 5. Commit Action Bottom Bar
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
        FfCard(
          variant: FfCardVariant.elevated,
          child: Column(
            children: [
              Icon(
                Icons.file_upload_outlined,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: StillwaterTokens.spaceMd),
              Text(
                'Select Bank Statement CSV',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: StillwaterTokens.spaceXs),
              Text(
                'Supports HDFC, ICICI, SBI, Axis, and custom CSV statement formats.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: StillwaterTokens.spaceLg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FfButton(
                    label: 'Choose CSV File',
                    leadingIcon: const Icon(Icons.folder_open_rounded),
                    onPressed: () {
                      // Demo file chooser trigger: load standard HDFC statement
                      _loadSampleData('hdfc');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: StillwaterTokens.spaceXl),

        Text('Or Test with Sample Data', style: theme.textTheme.titleSmall),
        const SizedBox(height: StillwaterTokens.spaceSm),
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

        const SizedBox(height: StillwaterTokens.spaceXl),

        // Paste CSV text option
        ListTile(
          title: const Text('Paste Raw CSV Text'),
          trailing: Icon(
            _showPasteArea ? Icons.expand_less : Icons.expand_more,
          ),
          onTap: () {
            setState(() {
              _showPasteArea = !_showPasteArea;
            });
          },
        ),

        if (_showPasteArea) ...[
          TextField(
            controller: _pasteController,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Paste CSV content with headers here...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: StillwaterTokens.spaceSm),
          FfButton(
            label: 'Parse Pasted CSV',
            variant: FfButtonVariant.secondary,
            onPressed: () {
              if (_pasteController.text.trim().isNotEmpty) {
                ref
                    .read(csvImportControllerProvider.notifier)
                    .loadCsvContent(
                      _pasteController.text,
                      fileName: 'Pasted_Statement.csv',
                    );
              }
            },
          ),
        ],
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
      padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
      children: [
        // Review Metrics Card
        FfCard(
          variant: FfCardVariant.tinted,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    session.sourceName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showMappingSheet(context),
                    icon: const Icon(Icons.tune, size: 16),
                    label: const Text('Edit Columns'),
                  ),
                ],
              ),
              const Divider(),
              Wrap(
                spacing: StillwaterTokens.spaceSm,
                runSpacing: StillwaterTokens.space3Xs,
                children: [
                  _buildMetricPill(
                    '${session.totalCount} Total',
                    theme.colorScheme.primary,
                  ),
                  _buildMetricPill(
                    '${session.newCount} New',
                    context.secColors.verified,
                  ),
                  if (session.duplicateCount > 0)
                    _buildMetricPill(
                      '${session.duplicateCount} Duplicates',
                      context.aiColors.accent,
                    ),
                  if (session.needsReviewCount > 0)
                    _buildMetricPill(
                      '${session.needsReviewCount} Needs Review',
                      context.aiColors.accent,
                    ),
                  if (session.excludedCount > 0)
                    _buildMetricPill(
                      '${session.excludedCount} Excluded',
                      theme.disabledColor,
                    ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: StillwaterTokens.spaceMd),

        Text(
          'Transactions Preview (${session.includedCount} selected)',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: StillwaterTokens.spaceSm),

        // List of Parsed Rows
        ...session.items.map(
          (item) => _buildRowCard(context, item, categories, accounts),
        ),
      ],
    );
  }

  Widget _buildMetricPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: StillwaterTokens.spaceSm,
        vertical: StillwaterTokens.space3Xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRowCard(
    BuildContext context,
    ParsedTransaction item,
    List<Category> categories,
    List<Account> accounts,
  ) {
    final theme = context.theme;
    final isExpense = item.type == TransactionType.expense;

    return Padding(
      padding: const EdgeInsets.only(bottom: StillwaterTokens.spaceSm),
      child: FfCard(
        padding: const EdgeInsets.all(StillwaterTokens.spaceSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: item.isIncluded,
                  onChanged: (val) {
                    ref
                        .read(csvImportControllerProvider.notifier)
                        .toggleRowInclusion(item.tempId, val ?? false);
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.normalizedMerchant.isNotEmpty
                            ? item.normalizedMerchant
                            : item.rawMerchant,
                        style: theme.textTheme.titleSmall?.copyWith(
                          decoration:
                              item.isIncluded
                                  ? null
                                  : TextDecoration.lineThrough,
                        ),
                      ),
                      if (item.rawMerchant != item.normalizedMerchant &&
                          item.rawMerchant.isNotEmpty)
                        Text(
                          'Raw: ${item.rawMerchant}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                          ),
                        ),
                      Text(
                        DateFormatter.formatTransactionDate(item.date),
                        style: theme.textTheme.bodySmall?.copyWith(
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
                      CurrencyFormatter.format(
                        item.amount,
                        showSign: true,
                        isExpense: isExpense,
                        isIncome: !isExpense,
                      ),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color:
                            isExpense
                                ? context.finColors.expense
                                : context.finColors.income,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.categoryName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Duplicate Alert & Action
            if (item.isDuplicate) ...[
              const SizedBox(height: StillwaterTokens.space3Xs),
              Container(
                padding: const EdgeInsets.all(StillwaterTokens.spaceSm),
                decoration: BoxDecoration(
                  color: context.aiColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    StillwaterTokens.radiusSm,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: context.aiColors.accent,
                        ),
                        const SizedBox(width: StillwaterTokens.space3Xs),
                        Text(
                          item.duplicateStatus.displayName,
                          style: TextStyle(
                            color: context.aiColors.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (item.duplicateReasons.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          item.duplicateReasons.join(' · '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ),
                    const SizedBox(height: StillwaterTokens.space3Xs),
                    Row(
                      children: [
                        const Text('Action: ', style: TextStyle(fontSize: 11)),
                        DropdownButton<DuplicateResolution>(
                          value: item.duplicateResolution,
                          isDense: true,
                          underline: const SizedBox.shrink(),
                          items:
                              DuplicateResolution.values.map((res) {
                                return DropdownMenuItem(
                                  value: res,
                                  child: Text(
                                    res.displayName,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                );
                              }).toList(),
                          onChanged: (res) {
                            if (res != null) {
                              ref
                                  .read(csvImportControllerProvider.notifier)
                                  .updateRowField(
                                    item.tempId,
                                    duplicateResolution: res,
                                  );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Validation Warning
            if (item.warnings.isNotEmpty ||
                item.validationErrors.isNotEmpty) ...[
              const SizedBox(height: StillwaterTokens.space3Xs),
              Text(
                [...item.validationErrors, ...item.warnings].join(' · '),
                style: TextStyle(color: theme.colorScheme.error, fontSize: 10),
              ),
            ],
          ],
        ),
      ),
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
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${session.includedCount} Ready to Import',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Saves directly to local Isar DB',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
            FfButton(
              label: 'Import Transactions',
              leadingIcon: const Icon(Icons.check_circle_outline),
              onPressed:
                  session.includedCount > 0
                      ? () async {
                        try {
                          final committedIds =
                              await ref
                                  .read(csvImportControllerProvider.notifier)
                                  .commitImport();

                          if (context.mounted) {
                            FfSnackbar.show(
                              context,
                              message:
                                  'Successfully imported ${committedIds.length} transactions.',
                              actionLabel: 'Undo',
                              onAction: () async {
                                await ref
                                    .read(csvImportControllerProvider.notifier)
                                    .undoLastImport();
                              },
                            );
                            Navigator.of(context).pop();
                          }
                        } catch (e) {
                          if (context.mounted) {
                            FfSnackbar.show(
                              context,
                              message: 'Import failed: $e',
                            );
                          }
                        }
                      }
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}
