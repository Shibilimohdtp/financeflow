import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/date_formatter.dart';
import '../../repositories/ai_activity_log_repository.dart';
import '../../shared/widgets/ff_confirm_dialog.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import 'gemini_controller.dart';

class AiActivityLogScreen extends ConsumerWidget {
  const AiActivityLogScreen({super.key});

  Future<void> _clearLogs(BuildContext context, WidgetRef ref) async {
    final confirmed = await FfConfirmDialog.show(
      context,
      title: 'Clear AI Activity Log?',
      message:
          'This will delete all stored audit records of AI interactions from this device.',
      confirmLabel: 'Clear Log',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      await ref.read(geminiControllerProvider.notifier).clearActivityLogs();
      if (context.mounted) {
        FfSnackbar.show(context, message: 'AI activity log cleared.');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(allAiLogsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Activity Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear Log',
            onPressed: () => _clearLogs(context, ref),
          ),
          const Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceMd),
            child: Center(child: FfPrivacyBadge(label: 'On-device Audit')),
          ),
        ],
      ),
      body: logsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(StillwaterTokens.spaceXl),
                child: FfEmptyState(
                  icon: Icons.history_rounded,
                  title: 'No AI interactions recorded',
                  description:
                      'Every request sent to Gemini or processed via AI assistance is logged here for full auditability and transparency.',
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: StillwaterTokens.spaceLg,
              vertical: StillwaterTokens.spaceMd,
            ),
            children: [
              FfSectionHeader(title: 'Logged Invocations (${logs.length})'),
              FfGroupedContainer(
                children:
                    logs.map((log) {
                      return _AiLogTile(log: log);
                    }).toList(),
              ),
              const SizedBox(height: StillwaterTokens.space4Xl),
            ],
          );
        },
        loading:
            () => const Center(
              child: Padding(
                padding: EdgeInsets.all(StillwaterTokens.space4Xl),
                child: CircularProgressIndicator(),
              ),
            ),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _AiLogTile extends StatelessWidget {
  final dynamic log;
  const _AiLogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isSuccess = log.isSuccess;

    return Padding(
      padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(
                    StillwaterTokens.radiusSm,
                  ),
                ),
                child: Text(
                  log.featureUsed.toString().replaceAll('_', ' ').toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color:
                          isSuccess
                              ? context.secColors.verified
                              : context.secColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isSuccess ? 'Success' : 'Failed',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color:
                          isSuccess
                              ? context.secColors.verified
                              : context.secColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: StillwaterTokens.spaceSm),
          Text(
            log.promptSummary,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (log.responseSummary != null &&
              log.responseSummary!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              log.responseSummary!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            '${DateFormatter.formatTransactionDate(log.timestamp)} · ${log.latencyMs}ms latency',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
