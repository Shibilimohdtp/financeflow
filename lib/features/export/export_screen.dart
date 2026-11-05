import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/date_formatter.dart';
import '../../services/export_service.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_segmented_pill.dart';
import '../../theme/stillwater_tokens.dart';
import '../backup/backup_screen.dart';
import 'export_controller.dart';
import '../accounts/accounts_controller.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_pickers.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_divider.dart';

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
    final theme = context.theme;
    final transactions = ref.watch(allTransactionsStreamProvider).value ?? [];

    return Scaffold(
      appBar: FfAppBar(
        title: 'Export Reports',
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceLg),
            child: Center(
              child: FfPrivacyBadge(label: '100% Local', iconOnly: true),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: StillwaterTokens.spaceLg,
          vertical: StillwaterTokens.spaceMd,
        ),
        children: [
          // ── Device Migration & Disaster Recovery Notice ───────────────
          Container(
            padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: StillwaterTokens.borderWidthHairline,
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
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: StillwaterTokens.spaceSm),
                    Text(
                      'Migrating to a New Phone?',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: StillwaterTokens.spaceXs),
                Text(
                  'Exports below are designed for external spreadsheets and reports. To transfer 100% of your data (all accounts, loans, settings, and histories) to another device, use Encrypted Backup & Restore.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: StillwaterTokens.spaceSm),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BackupScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(
                    StillwaterTokens.radiusSm,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Open Backup & Restore',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // ── 1. Local Processing Guarantee ─────────────────────────────
          FfCard(
            variant: FfCardVariant.tinted,
            padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.secColors.verified.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(
                      StillwaterTokens.radiusMd,
                    ),
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    color: context.secColors.verified,
                    size: 20,
                  ),
                ),
                const SizedBox(width: StillwaterTokens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'On-Device Report Generator',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.secColors.verified,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Spreadsheets and summaries are compiled strictly on this device without uploading to remote servers.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

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

          const SizedBox(height: StillwaterTokens.spaceLg),

          // ── 3. Export Scope ───────────────────────────────────────────
          const FfSectionHeader(title: 'Data Scope'),
          FfGroupedContainer(
            children: [
              RadioListTile<ExportScope>(
                title: const Text('All Recorded Transactions'),
                subtitle: Text(
                  '${transactions.length} transactions across all accounts and categories',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
                value: ExportScope.allTransactions,
                groupValue: _selectedScope,
                activeColor: theme.colorScheme.primary,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedScope = val);
                },
              ),
              const FfDivider(),
              RadioListTile<ExportScope>(
                title: const Text('Specific Date Range'),
                subtitle: Text(
                  _dateRange != null
                      ? '${DateFormatter.formatShortDate(_dateRange!.start)} – ${DateFormatter.formatShortDate(_dateRange!.end)}'
                      : 'Tap to pick date boundaries',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        _dateRange != null
                            ? theme.colorScheme.primary
                            : theme.colorScheme.secondary,
                    fontWeight:
                        _dateRange != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                  ),
                ),
                value: ExportScope.dateRangeTransactions,
                groupValue: _selectedScope,
                activeColor: theme.colorScheme.primary,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedScope = val);
                    _selectDateRange();
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // ── 4. Export Action Button ───────────────────────────────────
          FfButton(
            label: 'Generate & Save Export',
            isLoading: _isExporting,
            leadingIcon: const Icon(Icons.file_download_outlined, size: 18),
            onPressed: _isExporting ? null : _runExport,
          ),

          if (_exportedPath != null) ...[
            const SizedBox(height: StillwaterTokens.spaceLg),
            FfCard(
              variant: FfCardVariant.elevated,
              padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: context.finColors.income,
                        size: 20,
                      ),
                      const SizedBox(width: StillwaterTokens.spaceSm),
                      Expanded(
                        child: Text(
                          'Export Report Generated',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.finColors.income,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: StillwaterTokens.spaceSm),
                  Text(
                    'File: ${_exportedPath!.split(RegExp(r'[/\\]')).last}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Reports are for external analysis (Excel/Sheets/Tax). To move all data to a new device, use Full Backup & Migration.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: StillwaterTokens.spaceMd),
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

          const SizedBox(height: StillwaterTokens.space4Xl),
        ],
      ),
    );
  }
}
