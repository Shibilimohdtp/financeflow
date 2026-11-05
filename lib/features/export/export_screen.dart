import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/formatting/date_formatter.dart';
import '../../services/export_service.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_segmented_pill.dart';
import '../backup/backup_screen.dart';
import 'export_controller.dart';
import '../accounts/accounts_controller.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_pickers.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_row.dart';
import '../../theme/ff.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  ExportFormat _selectedFormat = ExportFormat.csv;
  ExportScope _selectedScope = ExportScope.allTransactions;
  DateTimeRange? _dateRange;
  final bool _includeSensitive = false;
  String? _exportedPath;
  bool _isExporting = false;

  Future<void> _selectDateRange() async {
    final picked = await pickFfDateRange(
      context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange:
          _dateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
    );
    if (picked != null) {
      setState(() {
        _dateRange = picked;
        _selectedScope = ExportScope.dateRangeTransactions;
      });
    }
  }

  Future<void> _runExport() async {
    setState(() => _isExporting = true);
    try {
      final req = ExportRequest(
        format: _selectedFormat,
        scope: _selectedScope,
        startDate: _dateRange?.start,
        endDate: _dateRange?.end,
        includeSensitiveFields: _includeSensitive,
      );

      final path = await ref
          .read(exportControllerProvider.notifier)
          .exportData(req);
      setState(() => _exportedPath = path);

      if (mounted) {
        FfToast.show(context, message: 'Export saved locally to: $path');
      }
    } catch (e) {
      if (mounted) {
        FfToast.show(
          context,
          tone: FfToastTone.error,
          message: 'Export failed: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(allTransactionsStreamProvider).value ?? [];

    return Scaffold(
      appBar: FfAppBar(
        title: 'Export Reports',
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: FfSpace.lg),
            child: Center(
              child: FfPrivacyBadge(label: '100% Local', iconOnly: true),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: FfSpace.lg,
          vertical: FfSpace.md,
        ),
        children: [
          // ── Device Migration & Disaster Recovery Notice ───────────────
          Container(
            padding: const EdgeInsets.all(FfSpace.md),
            decoration: BoxDecoration(
              color: context.ff.color.actionPrimaryContainer.withValues(
                alpha: FfTint.strong.alpha,
              ),
              borderRadius: BorderRadius.circular(FfRadius.lg),
              border: Border.all(
                color: context.ff.color.actionPrimary.withValues(
                  alpha: FfTint.strong.alpha,
                ),
                width: FfBorderWidth.hairline,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.phonelink_setup_rounded,
                      size: 20,
                      color: context.ff.color.actionPrimary,
                    ),
                    const SizedBox(width: FfSpace.sm),
                    Text(
                      'Migrating to a New Phone?',
                      style: context.ff.text.titleSm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.ff.color.actionPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FfSpace.xs),
                Text(
                  'Exports below are designed for external spreadsheets and reports. To transfer 100% of your data (all accounts, loans, settings, and histories) to another device, use Encrypted Backup & Restore.',
                  style: context.ff.text.bodySm.copyWith(
                    color: context.ff.color.textSecondary,
                  ),
                ),
                const SizedBox(height: FfSpace.sm),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BackupScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(FfRadius.sm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: FfSpace.x2s),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Open Backup & Restore',
                          style: context.ff.text.label.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.ff.color.actionPrimary,
                          ),
                        ),
                        const SizedBox(width: FfSpace.x2s),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: context.ff.color.actionPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: FfSpace.lg),

          // ── 1. Local Processing Guarantee ─────────────────────────────
          FfCard(
            variant: FfCardVariant.tinted,
            padding: const EdgeInsets.all(FfSpace.md),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.ff.color.statusSuccess.withValues(
                      alpha: FfTint.subtle.alpha,
                    ),
                    borderRadius: BorderRadius.circular(FfRadius.md),
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    color: context.ff.color.statusSuccess,
                    size: 20,
                  ),
                ),
                const SizedBox(width: FfSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'On-Device Report Generator',
                        style: context.ff.text.titleSm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.ff.color.statusSuccess,
                        ),
                      ),
                      const SizedBox(height: FfSpace.x3s),
                      Text(
                        'Spreadsheets and summaries are compiled strictly on this device without uploading to remote servers.',
                        style: context.ff.text.bodySm.copyWith(
                          color: context.ff.color.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: FfSpace.lg),

          // ── 2. Format Selection ───────────────────────────────────────
          const FfSectionHeader(title: 'Export Format'),
          FfSegmentedPill<ExportFormat>(
            options: const [
              FfSegmentOption(
                value: ExportFormat.csv,
                label: 'CSV (Excel / Sheets)',
              ),
              FfSegmentOption(
                value: ExportFormat.json,
                label: 'JSON (Raw Data)',
              ),
            ],
            selectedValue: _selectedFormat,
            onSelected: (format) {
              setState(() => _selectedFormat = format);
            },
          ),

          const SizedBox(height: FfSpace.lg),

          // ── 3. Export Scope ───────────────────────────────────────────
          const FfSectionHeader(title: 'Data Scope'),
          FfGroupedContainer(
            children: [
              FfRow.radio(
                title: 'All Recorded Transactions',
                subtitle:
                    '${transactions.length} transactions across all accounts and categories',
                selected: _selectedScope == ExportScope.allTransactions,
                onTap:
                    () => setState(
                      () => _selectedScope = ExportScope.allTransactions,
                    ),
              ),
              const FfDivider(),
              FfRow.radio(
                title: 'Specific Date Range',
                subtitle:
                    _dateRange != null
                        ? '${DateFormatter.formatShortDate(_dateRange!.start)} – ${DateFormatter.formatShortDate(_dateRange!.end)}'
                        : 'Tap to pick date boundaries',
                selected: _selectedScope == ExportScope.dateRangeTransactions,
                onTap: () {
                  setState(
                    () => _selectedScope = ExportScope.dateRangeTransactions,
                  );
                  _selectDateRange();
                },
              ),
            ],
          ),

          const SizedBox(height: FfSpace.lg),

          // ── 4. Export Action Button ───────────────────────────────────
          FfButton(
            label: 'Generate & Save Export',
            isLoading: _isExporting,
            leadingIcon: const Icon(Icons.file_download_outlined, size: 18),
            onPressed: _isExporting ? null : _runExport,
          ),

          if (_exportedPath != null) ...[
            const SizedBox(height: FfSpace.lg),
            FfCard(
              variant: FfCardVariant.elevated,
              padding: const EdgeInsets.all(FfSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: context.ff.color.moneyIncome,
                        size: 20,
                      ),
                      const SizedBox(width: FfSpace.sm),
                      Expanded(
                        child: Text(
                          'Export Report Generated',
                          style: context.ff.text.titleSm.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.ff.color.moneyIncome,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: FfSpace.sm),
                  Text(
                    'File: ${_exportedPath!.split(RegExp(r'[/\\]')).last}',
                    style: context.ff.text.bodySm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: FfSpace.x3s),
                  Text(
                    'Reports are for external analysis (Excel/Sheets/Tax). To move all data to a new device, use Full Backup & Migration.',
                    style: context.ff.text.bodySm.copyWith(
                      color: context.ff.color.secondary,
                    ),
                  ),
                  const SizedBox(height: FfSpace.md),
                  FfButton(
                    label: 'Share / Save to Downloads',
                    leadingIcon: const Icon(Icons.share_rounded, size: 16),
                    onPressed: () {
                      SharePlus.instance.share(
                        ShareParams(
                          files: [XFile(_exportedPath!)],
                          subject: 'FinanceFlow Financial Report',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: FfSpace.x4l),
        ],
      ),
    );
  }
}
