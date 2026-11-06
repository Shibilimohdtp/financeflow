import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/ingestion/parsed_transaction.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_banner.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_progress.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_surfaces.dart';
import '../../shared/widgets/ff_text_field.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../theme/ff.dart';
import '../accounts/accounts_controller.dart';
import '../categories/categories_controller.dart';
import 'csv_import_controller.dart';
import 'widgets/csv_bank_presets_card.dart';
import 'widgets/csv_column_mapper_sheet.dart';
import 'widgets/csv_preview_list.dart';

/// Screen for importing bank statement CSV files with offline on-device parsing.
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
    showFfSheet(
      context,
      builder:
          (ctx) => CsvColumnMapperSheet(
            headers: state.headers,
            initialMapping: state.columnMapping,
            onApply: (newMap) {
              ref
                  .read(csvImportControllerProvider.notifier)
                  .updateMapping(newMap);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final state = ref.watch(csvImportControllerProvider);
    final categories = ref.watch(categoriesStreamProvider).value ?? [];
    final accounts = ref.watch(rawAccountsStreamProvider).value ?? [];

    return FfAurora(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const FfAppBar(
          title: 'Import CSV Statement',
          actions: [
            Padding(
              padding: EdgeInsets.only(right: FfSpace.md),
              child: Center(
                child: FfPrivacyBadge(label: '100% Offline', iconOnly: true),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // ── 1. Offline Privacy Notice Banner ──────────────────────────
            const FfBanner(
              tone: FfBannerTone.success,
              message:
                  'Files are parsed locally on this device. Statement data never leaves your phone.',
            ),

            // ── 2. Loading State ─────────────────────────────────────────
            if (state.isLoading) ...[
              FfProgressBar(
                value: null,
                color: ff.color.actionPrimary,
                size: FfProgressSize.md,
              ),
              if (state.progressStep != null)
                Padding(
                  padding: const EdgeInsets.all(FfSpace.sm),
                  child: Text(
                    state.progressStep!,
                    style: ff.text.labelSm.copyWith(
                      color: ff.color.textSecondary,
                    ),
                  ),
                ),
            ],

            // ── 3. Error Banner ──────────────────────────────────────────
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(FfSpace.md),
                child: FfBanner(
                  tone: FfBannerTone.error,
                  message: state.errorMessage!,
                ),
              ),

            // ── 4. Main Body ─────────────────────────────────────────────
            Expanded(
              child:
                  !state.hasSession
                      ? _buildFileSelectionView(context)
                      : CsvPreviewList(
                        session: state.session!,
                        categories: categories,
                        accounts: accounts,
                        onEditColumns: () => _showMappingSheet(context),
                      ),
            ),

            // ── 5. Sticky Bottom Commit Bar ──────────────────────────────
            if (state.hasSession)
              _buildBottomCommitBar(context, state.session!),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelectionView(BuildContext context) {
    final ff = context.ff;

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: FfSpace.pageMargin,
        vertical: FfSpace.md,
      ),
      children: [
        // File Pick Hero Card
        FfCard(
          padding: const EdgeInsets.all(FfSpace.xl),
          child: Column(
            children: [
              Icon(
                Icons.file_upload_outlined,
                size: 36,
                color: ff.color.actionPrimary,
              ),
              const SizedBox(height: FfSpace.md),
              Text(
                'Select Bank Statement CSV',
                style: ff.text.titleSm,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FfSpace.xs),
              Text(
                'Supports HDFC, ICICI, SBI, Axis, and custom CSV statement formats.',
                style: ff.text.bodySm.copyWith(color: ff.color.textSecondary),
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

        const SizedBox(height: FfSpace.xl),

        // Presets Card
        CsvBankPresetsCard(onSelectPreset: _loadSampleData),

        const SizedBox(height: FfSpace.xl),

        // Collapsible Raw CSV Paste Card
        FfCard(
          padding: const EdgeInsets.all(FfSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FfRow(
                title: 'Paste Raw CSV Content',
                subtitle: 'Enter CSV text directly from clipboard',
                trailing: Icon(
                  _showPasteArea
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: ff.color.textSecondary,
                ),
                onTap: () => setState(() => _showPasteArea = !_showPasteArea),
              ),
              if (_showPasteArea) ...[
                const SizedBox(height: FfSpace.sm),
                const FfDivider(),
                const SizedBox(height: FfSpace.md),
                FfTextField(
                  controller: _pasteController,
                  maxLines: 5,
                  hint: 'Paste CSV rows here...',
                ),
                const SizedBox(height: FfSpace.md),
                FfButton(
                  label: 'Parse Pasted CSV',
                  variant: FfButtonVariant.primary,
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
    final ff = context.ff;

    return Container(
      padding: const EdgeInsets.all(FfSpace.md),
      decoration: BoxDecoration(
        color: ff.color.surfaceCard,
        border: Border(
          top: BorderSide(
            color: ff.color.borderSubtle,
            width: FfBorderWidth.hairline,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
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
