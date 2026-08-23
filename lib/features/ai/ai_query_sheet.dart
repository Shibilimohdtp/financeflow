import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../services/gemini_service.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../theme/stillwater_tokens.dart';
import '../../theme/stillwater_typography.dart';
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

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(StillwaterTokens.radius2Xl),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FfSheetHeader(
                title: 'Ask Your Finances',
                subtitle: 'Natural language queries scrubbed on-device',
              ),
              const Divider(height: 1, thickness: 1),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    StillwaterTokens.spaceLg,
                    StillwaterTokens.spaceMd,
                    StillwaterTokens.spaceLg,
                    StillwaterTokens.spaceXl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search field
                      TextField(
                        controller: _queryController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'e.g. "Swiggy", "Dining", "Groceries"',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.arrow_forward_rounded),
                            onPressed:
                                () => _submitQuery(_queryController.text),
                          ),
                        ),
                        onSubmitted: _submitQuery,
                      ),

                      const SizedBox(height: StillwaterTokens.spaceMd),

                      // Quick Chips
                      Wrap(
                        spacing: StillwaterTokens.spaceSm,
                        runSpacing: StillwaterTokens.spaceXs,
                        children: [
                          _SuggestionChip(
                            label: 'Swiggy',
                            onTap: () {
                              _queryController.text = 'Swiggy';
                              _submitQuery('Swiggy');
                            },
                          ),
                          _SuggestionChip(
                            label: 'Dining this month',
                            onTap: () {
                              _queryController.text = 'Dining this month';
                              _submitQuery('Dining this month');
                            },
                          ),
                          _SuggestionChip(
                            label: 'Total groceries',
                            onTap: () {
                              _queryController.text = 'Total groceries';
                              _submitQuery('Total groceries');
                            },
                          ),
                          _SuggestionChip(
                            label: 'Highest expense',
                            onTap: () {
                              _queryController.text = 'Highest expense';
                              _submitQuery('Highest expense');
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: StillwaterTokens.spaceLg),

                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(StillwaterTokens.space2Xl),
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
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    color: context.aiColors.accent,
                                    size: 18,
                                  ),
                                  const SizedBox(
                                    width: StillwaterTokens.spaceXs,
                                  ),
                                  Text(
                                    'AI Summary',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: context.aiColors.accent,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: StillwaterTokens.spaceSm),
                              Text(
                                _result!.answerSummary,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  height: 1.4,
                                ),
                              ),
                              if (_result!.computedTotal != null) ...[
                                const SizedBox(
                                  height: StillwaterTokens.spaceMd,
                                ),
                                Text(
                                  CurrencyFormatter.formatINR(
                                    _result!.computedTotal!,
                                  ),
                                  style: StillwaterTypography.numLg(
                                    color: theme.colorScheme.primary,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: theme.cardColor,
      side: BorderSide(
        color: theme.dividerColor,
        width: StillwaterTokens.borderWidthHairline,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusFull),
      ),
    );
  }
}
