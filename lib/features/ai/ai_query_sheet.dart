import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../services/gemini_service.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../theme/stillwater_tokens.dart';
import 'gemini_controller.dart';

class AiQuerySheet extends ConsumerStatefulWidget {
  const AiQuerySheet({super.key});

  @override
  ConsumerState<AiQuerySheet> createState() => _AiQuerySheetState();
}

class _AiQuerySheetState extends ConsumerState<AiQuerySheet> {
  final _queryController = TextEditingController();
  GeminiNaturalQueryResult? _result;
  bool _isLoading = false;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _submitQuery(String q) async {
    final query = q.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final res = await ref
          .read(geminiControllerProvider.notifier)
          .queryFinance(query);
      setState(() {
        _result = res;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: StillwaterTokens.spaceLg,
        right: StillwaterTokens.spaceLg,
        top: StillwaterTokens.spaceLg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: context.aiColors.accent,
                      size: 20,
                    ),
                    const SizedBox(width: StillwaterTokens.spaceSm),
                    Text(
                      'Ask Your Finances',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: StillwaterTokens.spaceXs),
            Text(
              'Questions are resolved locally on your device first.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: StillwaterTokens.spaceMd),

            // Query Input
            TextField(
              controller: _queryController,
              decoration: InputDecoration(
                hintText: 'e.g. "Swiggy", "Coffee", "Subscriptions"',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded),
                  onPressed: () => _submitQuery(_queryController.text),
                ),
              ),
              onSubmitted: _submitQuery,
            ),

            const SizedBox(height: StillwaterTokens.spaceMd),

            // Quick suggestion chips
            Wrap(
              spacing: StillwaterTokens.spaceSm,
              runSpacing: StillwaterTokens.spaceXs,
              children: [
                ActionChip(
                  label: const Text('Swiggy'),
                  onPressed: () {
                    _queryController.text = 'Swiggy';
                    _submitQuery('Swiggy');
                  },
                ),
                ActionChip(
                  label: const Text('Food & Dining'),
                  onPressed: () {
                    _queryController.text = 'Food & Dining';
                    _submitQuery('Food & Dining');
                  },
                ),
                ActionChip(
                  label: const Text('Subscriptions'),
                  onPressed: () {
                    _queryController.text = 'Subscriptions';
                    _submitQuery('Subscriptions');
                  },
                ),
              ],
            ),

            const SizedBox(height: StillwaterTokens.spaceLg),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(StillwaterTokens.spaceXl),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_result != null) ...[
              FfCard(
                variant: FfCardVariant.elevated,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Result Summary',
                          style: theme.textTheme.titleSmall,
                        ),
                        FfPrivacyBadge(
                          label:
                              _result!.isFromGemini
                                  ? 'AI Assisted'
                                  : 'On-device',
                        ),
                      ],
                    ),
                    const SizedBox(height: StillwaterTokens.spaceSm),
                    Text(
                      _result!.answerSummary,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_result!.computedTotal != null &&
                        _result!.computedTotal! > 0) ...[
                      const SizedBox(height: StillwaterTokens.spaceSm),
                      Text(
                        'Total: ${CurrencyFormatter.formatINR(_result!.computedTotal!)}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: StillwaterTokens.space2Xl),
          ],
        ),
      ),
    );
  }
}
