import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../models/transaction.dart';
import '../../../../services/ingestion/transaction_merge_service.dart';
import '../../../../shared/widgets/ff_card.dart';
import '../../../../shared/widgets/ff_section_header.dart';
import '../../../../shared/widgets/ff_toast.dart';
import '../../../../theme/ff.dart';

/// On-device provenance, UTR reference, and raw bank evidence card
/// for [TransactionDetailScreen].
class TransactionProvenanceCard extends StatefulWidget {
  final Transaction transaction;

  const TransactionProvenanceCard({super.key, required this.transaction});

  @override
  State<TransactionProvenanceCard> createState() =>
      _TransactionProvenanceCardState();
}

class _TransactionProvenanceCardState extends State<TransactionProvenanceCard> {
  bool _isRawEvidenceExpanded = false;

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.selectionClick();
    FfToast.show(context, message: '$label copied to clipboard.');
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final tx = widget.transaction;
    final provenanceSummary = TransactionMergeService.formatProvenanceSummary(
      tx,
    );

    final hasReference =
        tx.sourceReference != null && tx.sourceReference!.isNotEmpty;
    final hasRawPayee =
        tx.originalMerchant != null &&
        tx.originalMerchant!.isNotEmpty &&
        tx.originalMerchant != tx.merchant;
    final hasMergedSources = tx.mergedSources.isNotEmpty;
    final hasRawEvidence =
        tx.sourceMessageId != null && tx.sourceMessageId!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FfSectionHeader(title: 'Provenance & Audit'),
        const SizedBox(height: FfSpace.xs),
        FfCard(
          padding: const EdgeInsets.all(FfSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. On-Device Ingestion Badge Row ───────────────────
              Row(
                children: [
                  Icon(
                    tx.mergedSources.length > 1
                        ? Icons.call_merge_rounded
                        : Icons.verified_user_outlined,
                    size: 18,
                    color: ff.color.actionPrimary,
                  ),
                  const SizedBox(width: FfSpace.xs),
                  Expanded(
                    child: Text(
                      provenanceSummary,
                      style: ff.text.titleSm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ff.color.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FfSpace.x3s),
              Text(
                'Processed 100% locally on this device · 0 bytes sent off-device',
                style: ff.text.bodySm.copyWith(color: ff.color.textTertiary),
              ),

              // ── 2. Merged Sources Pills ────────────────────────────
              if (hasMergedSources) ...[
                const SizedBox(height: FfSpace.md),
                Text(
                  'SOURCES MERGED',
                  style: ff.text.labelSm.copyWith(
                    color: ff.color.textSecondary,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: FfSpace.xs),
                Wrap(
                  spacing: FfSpace.xs,
                  runSpacing: FfSpace.xs,
                  children:
                      tx.mergedSources.map((source) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: FfSpace.sm,
                            vertical: FfSpace.x3s,
                          ),
                          decoration: BoxDecoration(
                            color: ff.color.surfaceCard,
                            border: Border.all(color: ff.color.borderSubtle),
                            borderRadius: BorderRadius.circular(FfRadius.full),
                          ),
                          child: Text(source, style: ff.text.labelSm),
                        );
                      }).toList(),
                ),
              ],

              // ── 3. Reference / UTR Number ──────────────────────────
              if (hasReference) ...[
                const SizedBox(height: FfSpace.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REFERENCE / UTR',
                            style: ff.text.labelSm.copyWith(
                              color: ff.color.textSecondary,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: FfSpace.x3s),
                          SelectableText(
                            tx.sourceReference!,
                            style: ff.text.bodySm.copyWith(
                              fontWeight: FontWeight.w600,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      tooltip: 'Copy Reference',
                      onPressed:
                          () => _copyToClipboard(
                            context,
                            tx.sourceReference!,
                            'Reference',
                          ),
                    ),
                  ],
                ),
              ],

              // ── 4. Raw Unnormalized Payee ──────────────────────────
              if (hasRawPayee) ...[
                const SizedBox(height: FfSpace.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STATEMENT PAYEE',
                            style: ff.text.labelSm.copyWith(
                              color: ff.color.textSecondary,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: FfSpace.x3s),
                          Text(
                            tx.originalMerchant!,
                            style: ff.text.bodySm.copyWith(
                              color: ff.color.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      tooltip: 'Copy Raw Payee',
                      onPressed:
                          () => _copyToClipboard(
                            context,
                            tx.originalMerchant!,
                            'Raw Payee',
                          ),
                    ),
                  ],
                ),
              ],

              // ── 5. Raw Evidence Disclosure (SMS ID / Fingerprint) ──
              if (hasRawEvidence) ...[
                const SizedBox(height: FfSpace.sm),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isRawEvidenceExpanded = !_isRawEvidenceExpanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(FfRadius.md),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: FfSpace.xs),
                    child: Row(
                      children: [
                        Icon(
                          _isRawEvidenceExpanded
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          size: 18,
                          color: ff.color.textSecondary,
                        ),
                        const SizedBox(width: FfSpace.xs),
                        Text(
                          _isRawEvidenceExpanded
                              ? 'Hide raw message metadata'
                              : 'Show raw message metadata',
                          style: ff.text.bodySm.copyWith(
                            color: ff.color.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isRawEvidenceExpanded) ...[
                  const SizedBox(height: FfSpace.xs),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(FfSpace.sm),
                    decoration: BoxDecoration(
                      color: ff.color.surfaceCard,
                      borderRadius: BorderRadius.circular(FfRadius.sm),
                      border: Border.all(color: ff.color.borderSubtle),
                    ),
                    child: SelectableText(
                      'Source ID: ${tx.sourceMessageId}\n'
                      'Fingerprint: ${tx.fingerprint ?? 'none'}\n'
                      'Ingested: ${tx.createdAt}',
                      style: ff.text.labelSm.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: ff.color.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
