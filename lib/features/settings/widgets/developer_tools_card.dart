import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/ingestion/ingestion_coordinator.dart';
import '../../../shared/widgets/ff_button.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_toast.dart';
import '../../../theme/ff.dart';
import '../branding_preview_screen.dart';
import '../settings_controller.dart';

/// Collapsible developer tools card for demo dataset injection and UI reviews.
class DeveloperToolsCard extends StatefulWidget {
  const DeveloperToolsCard({super.key});

  @override
  State<DeveloperToolsCard> createState() => _DeveloperToolsCardState();
}

class _DeveloperToolsCardState extends State<DeveloperToolsCard> {
  bool _isExpanded = false;

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(FfRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: FfSpace.xs),
            child: Row(
              children: [
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: ff.color.textSecondary,
                ),
                const SizedBox(width: FfSpace.xs),
                Text(
                  'Developer Tools',
                  style: ff.text.bodySm.copyWith(
                    color: ff.color.actionPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: FfSpace.md),
          Consumer(
            builder: (context, ref, _) {
              return FfCard(
                padding: const EdgeInsets.all(FfSpace.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Seed Demo Dataset', style: ff.text.titleSm),
                    const SizedBox(height: FfSpace.x2s),
                    Text(
                      'Load sample Indian transactions (Swiggy, Netflix, Salary, HDFC EMI) for UI review.',
                      style: ff.text.bodySm.copyWith(
                        color: ff.color.textSecondary,
                      ),
                    ),
                    const SizedBox(height: FfSpace.md),
                    FfButton(
                      label: 'Load Realistic Demo Data',
                      variant: FfButtonVariant.outlined,
                      size: FfButtonSize.sm,
                      onPressed: () async {
                        await ref
                            .read(settingsControllerProvider.notifier)
                            .seedDemoData();
                        if (context.mounted) {
                          FfToast.show(
                            context,
                            message: 'Demo dataset loaded on this device.',
                          );
                        }
                      },
                    ),
                    const SizedBox(height: FfSpace.sm),
                    Wrap(
                      spacing: FfSpace.sm,
                      runSpacing: FfSpace.sm,
                      children: [
                        FfButton(
                          label: 'Inject Sample SMS',
                          variant: FfButtonVariant.outlined,
                          size: FfButtonSize.sm,
                          onPressed: () async {
                            final result =
                                await ref
                                    .read(ingestionCoordinatorProvider)
                                    .injectSampleSms();
                            if (context.mounted) {
                              FfToast.show(
                                context,
                                message:
                                    'Sample SMS: ${result.disposition.name}.',
                              );
                            }
                          },
                        ),
                        FfButton(
                          label: 'Inject Sample Notification',
                          variant: FfButtonVariant.outlined,
                          size: FfButtonSize.sm,
                          onPressed: () async {
                            final result =
                                await ref
                                    .read(ingestionCoordinatorProvider)
                                    .injectSampleNotification();
                            if (context.mounted) {
                              FfToast.show(
                                context,
                                message:
                                    'Sample notification: ${result.disposition.name}.',
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: FfSpace.sm),
                    FfButton(
                      label: 'Stillwater Brand Showcase',
                      variant: FfButtonVariant.text,
                      size: FfButtonSize.sm,
                      leadingIcon: const Icon(Icons.palette_outlined, size: 16),
                      onPressed: () {
                        _push(context, const BrandingPreviewScreen());
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
