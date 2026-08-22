import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/date_formatter.dart';
import '../../repositories/ai_activity_log_repository.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_confirm_dialog.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
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
    final theme = context.theme;
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
            padding: EdgeInsets.only(right: StillwaterTokens.spaceLg),
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
                      'Every request sent to Gemini or processed via AI assistance is logged here for full transparency.',
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
            itemCount: logs.length,
            separatorBuilder:
                (_, __) => const SizedBox(height: StillwaterTokens.spaceSm),
            itemBuilder: (context, index) {
              final log = logs[index];
              final isSuccess = log.isSuccess;

              return FfCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          log.featureUsed.replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          DateFormatter.formatTransactionDate(log.timestamp),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: StillwaterTokens.spaceXs),
                    Text(
                      'Payload: ${log.sanitizedPayloadSummary}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: StillwaterTokens.space2Xs),
                    Text(
                      'Result: ${log.resultSummary}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            isSuccess
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.error,
                      ),
                    ),
                    if (log.errorState != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Error: ${log.errorState}',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
