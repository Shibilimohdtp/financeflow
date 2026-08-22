import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/date_formatter.dart';
import '../../services/export_service.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import '../transactions/transactions_controller.dart';
import 'export_controller.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  ExportFormat _selectedFormat = ExportFormat.csv;
  ExportScope _selectedScope = ExportScope.allTransactions;
  DateTimeRange? _dateRange;
  bool _includeSensitive = false;
  String? _exportedPath;

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
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
        FfSnackbar.show(context, message: 'Export generated locally at: $path');
      }
    } catch (e) {
      if (mounted) {
        FfSnackbar.show(context, message: 'Export failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final transactions = ref.watch(filteredTransactionsProvider).value ?? [];
    final state = ref.watch(exportControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceLg),
            child: Center(child: FfPrivacyBadge(label: '100% Local')),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
        children: [
          // Local Only Promise Card
          FfCard(
            variant: FfCardVariant.tinted,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'On-Device Processing',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: context.secColors.verified,
                      ),
                    ),
                    Icon(
                      Icons.shield_outlined,
                      color: context.secColors.verified,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: StillwaterTokens.spaceXs),
                Text(
                  'Exports are generated completely on this device. FinanceFlow never uploads or syncs your data to any remote server.',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // Format Selection
          Text('Choose Export Format', style: theme.textTheme.titleMedium),
          const SizedBox(height: StillwaterTokens.spaceSm),
          FfCard(
            padding: EdgeInsets.zero,
            child: Column(
              children:
                  ExportFormat.values.map((f) {
                    return RadioListTile<ExportFormat>(
                      title: Text(f.displayName),
                      subtitle: Text('.${f.fileExtension} format'),
                      value: f,
                      groupValue: _selectedFormat,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedFormat = val);
                      },
                    );
                  }).toList(),
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // Scope Selection
          Text('Data Scope', style: theme.textTheme.titleMedium),
          const SizedBox(height: StillwaterTokens.spaceSm),
          FfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<ExportScope>(
                  value: _selectedScope,
                  decoration: const InputDecoration(labelText: 'Scope'),
                  items:
                      ExportScope.values.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(s.displayName),
                        );
                      }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedScope = val);
                  },
                ),
                const SizedBox(height: StillwaterTokens.spaceMd),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.date_range_outlined),
                  title: const Text('Filter by Date Range (Optional)'),
                  subtitle: Text(
                    _dateRange != null
                        ? '${DateFormatter.formatFullDate(_dateRange!.start)} to ${DateFormatter.formatFullDate(_dateRange!.end)}'
                        : 'All dates included',
                  ),
                  trailing: TextButton(
                    onPressed: _selectDateRange,
                    child: Text(_dateRange == null ? 'Set Dates' : 'Change'),
                  ),
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Include Sensitive Account Identifiers'),
                  subtitle: const Text(
                    'When unchecked, account numbers are masked',
                  ),
                  value: _includeSensitive,
                  activeColor: theme.colorScheme.primary,
                  onChanged: (val) => setState(() => _includeSensitive = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // Summary Preview Card
          FfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Export Summary', style: theme.textTheme.titleSmall),
                const SizedBox(height: StillwaterTokens.spaceSm),
                Text(
                  '• Total transactions on device: ${transactions.length}',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  '• Format: ${_selectedFormat.displayName}',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  '• Destination: Local documents folder',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          if (_exportedPath != null) ...[
            const SizedBox(height: StillwaterTokens.spaceLg),
            FfCard(
              variant: FfCardVariant.tinted,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: context.secColors.verified,
                        size: 20,
                      ),
                      const SizedBox(width: StillwaterTokens.spaceSm),
                      Text(
                        'File Saved Locally',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: context.secColors.verified,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: StillwaterTokens.spaceXs),
                  Text(
                    _exportedPath!,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: StillwaterTokens.space2Xl),

          FfButton(
            label:
                state.isLoading
                    ? 'Generating Export...'
                    : 'Generate Local Export',
            isLoading: state.isLoading,
            onPressed: state.isLoading ? null : _runExport,
          ),

          const SizedBox(height: StillwaterTokens.space4Xl),
        ],
      ),
    );
  }
}
