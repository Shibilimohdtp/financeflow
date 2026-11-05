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
import '../accounts/accounts_controller.dart';
import '../categories/categories_controller.dart';
import 'csv_import_controller.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_progress.dart';
import '../../theme/ff.dart';

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
                        horizontal: FfSpace.lg,
                        vertical: FfSpace.md,
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: FfSpace.x2s),
      padding: const EdgeInsets.symmetric(
        horizontal: FfSpace.md,
        vertical: FfSpace.xs,
      ),
      decoration: BoxDecoration(
        color: context.ff.color.surfaceCard,
        borderRadius: BorderRadius.circular(FfRadius.md),
        border: Border.all(
          color: context.ff.color.borderSubtle,
          width: FfBorderWidth.hairline,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: context.ff.text.body.copyWith(fontWeight: FontWeight.w500),
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
            padding: EdgeInsets.only(right: FfSpace.lg),
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
              horizontal: FfSpace.lg,
              vertical: FfSpace.sm,
            ),
            color: context.ff.color.statusSuccess.withValues(
              alpha: FfTint.subtle.alpha,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 18,
                  color: context.ff.color.statusSuccess,
                ),
                const SizedBox(width: FfSpace.sm),
                Expanded(
                  child: Text(
                    'Files are read locally on this device. Statement data never leaves your phone.',
                    style: context.ff.text.labelSm.copyWith(
                      color: context.ff.color.statusSuccess,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 2. Loading / Progress State ──────────────────────────────
          if (state.isLoading) ...[
            FfProgressBar(
              value: null,
              color: context.ff.color.actionPrimary,
              size: FfProgressSize.md,
            ),
            if (state.progressStep != null)
              Padding(
                padding: const EdgeInsets.all(FfSpace.sm),
                child: Text(
                  state.progressStep!,
                  style: context.ff.text.labelSm.copyWith(
                    color: context.ff.color.secondary,
                  ),
                ),
              ),
          ],

          // ── 3. Error Banner ──────────────────────────────────────────
          if (state.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(FfSpace.sm),
              margin: const EdgeInsets.all(FfSpace.md),
              decoration: BoxDecoration(
                color: context.ff.color.statusErrorContainer,
                borderRadius: BorderRadius.circular(FfRadius.sm),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: context.ff.color.statusError,
                    size: 18,
                  ),
                  const SizedBox(width: FfSpace.xs),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: context.ff.text.bodySm.copyWith(
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
    return ListView(
      padding: const EdgeInsets.all(FfSpace.lg),
      children: [
        Container(
          padding: const EdgeInsets.all(FfSpace.xl),
          decoration: BoxDecoration(
            color: context.ff.color.surfaceCard,
            borderRadius: BorderRadius.circular(FfRadius.lg),
            border: Border.all(
              color: context.ff.color.borderSubtle,
              width: FfBorderWidth.hairline,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.ff.color.actionPrimary.withValues(
                    alpha: FfTint.subtle.alpha,
                  ),
                  borderRadius: BorderRadius.circular(FfRadius.md),
                ),
                child: Icon(
                  Icons.file_upload_outlined,
                  size: 24,
                  color: context.ff.color.actionPrimary,
                ),
              ),
              const SizedBox(height: FfSpace.md),
              Text(
                'Select Bank Statement CSV',
                style: context.ff.text.title.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: FfSpace.xs),
              Text(
                'Supports HDFC, ICICI, SBI, Axis, and custom CSV statement formats.',
                style: context.ff.text.bodySm.copyWith(
                  color: context.ff.color.secondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FfSpace.lg),
              FfButton(
                label: 'Choose CSV File',
                leadingIcon: const Icon(Icons.folder_open_rounded, size: 18),
                onPressed: _pickCsvFile,
              ),
            ],
          ),
        ),

        const SizedBox(height: FfSpace.x2l),

        _SectionLabel(label: 'Or Test with Sample Data'),
        const SizedBox(height: FfSpace.xs),
        Row(
          children: [
            Expanded(
              child: FfButton(
                label: 'HDFC Sample',
                variant: FfButtonVariant.outlined,
                onPressed: () => _loadSampleData('hdfc'),
              ),
            ),
            const SizedBox(width: FfSpace.sm),
            Expanded(
              child: FfButton(
                label: 'ICICI Sample',
                variant: FfButtonVariant.outlined,
                onPressed: () => _loadSampleData('icici'),
              ),
            ),
            const SizedBox(width: FfSpace.sm),
            Expanded(
              child: FfButton(
                label: 'General CSV',
                variant: FfButtonVariant.outlined,
                onPressed: () => _loadSampleData('general'),
              ),
            ),
          ],
        ),

        const SizedBox(height: FfSpace.x2l),

        _SectionLabel(label: 'Or Paste Raw CSV Text'),
        const SizedBox(height: FfSpace.xs),
        Container(
          decoration: BoxDecoration(
            color: context.ff.color.surfaceCard,
            borderRadius: BorderRadius.circular(FfRadius.lg),
            border: Border.all(
              color: context.ff.color.borderSubtle,
              width: FfBorderWidth.hairline,
            ),
          ),
          child: Column(
            children: [
              FfRow(
                title: 'Paste Raw CSV Content',
                subtitle: 'Enter CSV text directly from clipboard',
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
                  padding: const EdgeInsets.all(FfSpace.md),
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
                      const SizedBox(height: FfSpace.md),
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

        const SizedBox(height: FfSpace.x4l),
      ],
    );
  }

  Widget _buildReviewSessionView(
    BuildContext context,
    ImportReviewSession session,
    List<Category> categories,
    List<Account> accounts,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: FfSpace.lg,
        vertical: FfSpace.md,
      ),
      children: [
        // Session Summary Card
        Container(
          padding: const EdgeInsets.all(FfSpace.lg),
          decoration: BoxDecoration(
            color: context.ff.color.surfaceCard,
            borderRadius: BorderRadius.circular(FfRadius.lg),
            border: Border.all(
              color: context.ff.color.borderSubtle,
              width: FfBorderWidth.hairline,
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
                      style: context.ff.text.title.copyWith(
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
              const SizedBox(height: FfSpace.sm),
              Row(
                children: [
                  _SummaryPill(
                    label: '${session.totalCount} Total',
                    color: context.ff.color.actionPrimary,
                  ),
                  const SizedBox(width: FfSpace.xs),
                  _SummaryPill(
                    label: '${session.validCount} Valid',
                    color: context.ff.color.statusSuccess,
                  ),
                  if (session.duplicateCount > 0) ...[
                    const SizedBox(width: FfSpace.xs),
                    _SummaryPill(
                      label: '${session.duplicateCount} Duplicates',
                      color: context.ff.color.statusError,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: FfSpace.x2l),

        // Parsed Rows Preview
        _SectionLabel(label: 'Parsed Transactions (${session.items.length})'),
        const SizedBox(height: FfSpace.xs),
        Container(
          decoration: BoxDecoration(
            color: context.ff.color.surfaceCard,
            borderRadius: BorderRadius.circular(FfRadius.lg),
            border: Border.all(
              color: context.ff.color.borderSubtle,
              width: FfBorderWidth.hairline,
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

        const SizedBox(height: FfSpace.x4l),
      ],
    );
  }

  Widget _buildBottomCommitBar(
    BuildContext context,
    ImportReviewSession session,
  ) {
    return Container(
      padding: const EdgeInsets.all(FfSpace.md),
      decoration: BoxDecoration(
        color: context.ff.color.surfaceCard,
        border: Border(
          top: BorderSide(
            color: context.ff.color.borderSubtle,
            width: FfBorderWidth.hairline,
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
            const SizedBox(width: FfSpace.md),
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
    final isIncome = item.type == TransactionType.income;
    final amountColor =
        isIncome ? context.ff.color.moneyIncome : context.ff.color.moneyExpense;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FfSpace.md,
        vertical: FfSpace.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: FfTint.subtle.alpha),
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
          const SizedBox(width: FfSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.normalizedMerchant,
                  style: context.ff.text.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${DateFormatter.formatTransactionDate(item.date)} · ${item.categoryName}',
                  style: context.ff.text.labelSm.copyWith(
                    color: context.ff.color.secondary,
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
                style: context.ff.text.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
              ),
              if (item.duplicateStatus != DuplicateMatchLevel.none)
                Text(
                  'Duplicate',
                  style: context.ff.text.labelSm.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.ff.color.statusError,
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
        horizontal: FfSpace.sm,
        vertical: FfSpace.x3s,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: FfTint.subtle.alpha),
        borderRadius: BorderRadius.circular(FfRadius.full),
      ),
      child: Text(
        label,
        style: context.ff.text.labelSm.copyWith(
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
      padding: const EdgeInsets.only(left: FfSpace.x2s),
      child: Text(
        label.toUpperCase(),
        style: context.ff.text.labelSm.copyWith(
          letterSpacing: 0.8,
          color: context.ff.color.secondary,
        ),
      ),
    );
  }
}
