import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/financeflow_mark.dart';
import '../../theme/stillwater_colors.dart';
import '../../theme/stillwater_tokens.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_divider.dart';

/// Internal Branding & Stillwater Design System Preview Screen
class BrandingPreviewScreen extends StatelessWidget {
  const BrandingPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: FfAppBar(
        title: 'Stillwater Branding Showcase',
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceLg),
            child: Center(
              child: FfPrivacyBadge(label: 'Design Showcase', iconOnly: true),
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
          // ── 1. Hero Brand Presentation ──────────────────────────────
          Container(
            padding: const EdgeInsets.all(StillwaterTokens.spaceXl),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
              border: Border.all(
                color: theme.dividerColor,
                width: StillwaterTokens.borderWidthHairline,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: StillwaterTokens.spaceSm),
                const FinanceFlowLogo(
                  markSize: 64,
                  fontSize: 28,
                  showTagline: true,
                  axis: Axis.vertical,
                ),
                const SizedBox(height: StillwaterTokens.spaceMd),
                Text(
                  'The Stillwater Mark · Calm Financial Control',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          // ── 2. Multi-Theme Variants ──────────────────────────────────
          _SectionLabel(label: 'Theme Variants'),
          const SizedBox(height: StillwaterTokens.spaceXs),
          Row(
            children: [
              // Daylight Variant
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
                  decoration: BoxDecoration(
                    color: StillwaterColors.lightSurfaceApp,
                    borderRadius: BorderRadius.circular(
                      StillwaterTokens.radiusMd,
                    ),
                    border: Border.all(
                      color: StillwaterColors.lightBorderHairline,
                    ),
                  ),
                  child: const Column(
                    children: [
                      FinanceFlowMark(size: 44, variant: MarkVariant.daylight),
                      SizedBox(height: StillwaterTokens.spaceSm),
                      Text(
                        'Daylight',
                        style: TextStyle(
                          color: StillwaterColors.lightTextPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: StillwaterTokens.spaceMd),

              // Deep Water Variant
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
                  decoration: BoxDecoration(
                    color: StillwaterColors.darkSurfaceApp,
                    borderRadius: BorderRadius.circular(
                      StillwaterTokens.radiusMd,
                    ),
                    border: Border.all(
                      color: StillwaterColors.darkBorderHairline,
                    ),
                  ),
                  child: const Column(
                    children: [
                      FinanceFlowMark(size: 44, variant: MarkVariant.deepWater),
                      SizedBox(height: StillwaterTokens.spaceSm),
                      Text(
                        'Lichen Ledger · Dark',
                        style: TextStyle(
                          color: StillwaterColors.darkTextPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: StillwaterTokens.spaceMd),

              // Monochrome Variant
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
                  decoration: BoxDecoration(
                    color: StillwaterColors.lightSecInk,
                    borderRadius: BorderRadius.circular(
                      StillwaterTokens.radiusMd,
                    ),
                  ),
                  child: const Column(
                    children: [
                      FinanceFlowMark(
                        size: 44,
                        variant: MarkVariant.monochrome,
                      ),
                      SizedBox(height: StillwaterTokens.spaceSm),
                      Text(
                        'Monochrome',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          // ── 3. Sizing Ladder ─────────────────────────────────────────
          _SectionLabel(label: 'Sizing & Legibility Ladder'),
          const SizedBox(height: StillwaterTokens.spaceXs),
          Container(
            padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
              border: Border.all(
                color: theme.dividerColor,
                width: StillwaterTokens.borderWidthHairline,
              ),
            ),
            child: Column(
              children: [
                _buildSizeRow(18, '18dp — Status Bar & Compact Indicators'),
                _Divider(),
                _buildSizeRow(24, '24dp — Standard Navigation & Tab Icons'),
                _Divider(),
                _buildSizeRow(32, '32dp — Inset Tile & Badge Icons'),
                _Divider(),
                _buildSizeRow(48, '48dp — Dialog Headers & Cards'),
                _Divider(),
                _buildSizeRow(72, '72dp — Lock Screen & Keypad Header'),
                _Divider(),
                _buildSizeRow(96, '96dp — Splash & Feature Hero Displays'),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          // ── 4. Platform Safe Zones ───────────────────────────────────
          _SectionLabel(label: 'Platform Icons & Safe Zones'),
          const SizedBox(height: StillwaterTokens.spaceXs),
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
              border: Border.all(
                color: theme.dividerColor,
                width: StillwaterTokens.borderWidthHairline,
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: StillwaterColors.lightPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: FinanceFlowMark(
                        size: 28,
                        variant: MarkVariant.monochrome,
                      ),
                    ),
                  ),
                  title: const Text('Squircle Launcher Icon'),
                  subtitle: const Text('Android & iOS adaptive mask'),
                  trailing: const FfPrivacyBadge(label: 'Verified'),
                ),
                _Divider(),
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: StillwaterColors.lightPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: FinanceFlowMark(
                        size: 28,
                        variant: MarkVariant.monochrome,
                      ),
                    ),
                  ),
                  title: const Text('Circular Launcher Icon'),
                  subtitle: const Text('Pixel & Android round mask'),
                  trailing: const FfPrivacyBadge(label: 'Verified'),
                ),
                _Divider(),
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? const Color(0xFF1E2624)
                              : const Color(0xFF37413E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: FinanceFlowMark(
                        size: 22,
                        variant: MarkVariant.monochrome,
                      ),
                    ),
                  ),
                  title: const Text('Monochrome Notification Icon'),
                  subtitle: const Text('Status bar 24dp white silhouette'),
                  trailing: const FfPrivacyBadge(label: 'Verified'),
                ),
              ],
            ),
          ),
          const SizedBox(height: StillwaterTokens.space4Xl),
        ],
      ),
    );
  }

  Widget _buildSizeRow(double size, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: StillwaterTokens.spaceXs),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Center(child: FinanceFlowMark(size: size)),
          ),
          const SizedBox(width: StillwaterTokens.spaceMd),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const FfDivider();
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: StillwaterTokens.space2Xs),
      child: Text(
        label,
        style: context.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
