import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/financeflow_mark.dart';
import '../../theme/stillwater_colors.dart';
import '../../theme/stillwater_tokens.dart';

/// Internal Branding & Stillwater Design System Preview Screen
class BrandingPreviewScreen extends StatelessWidget {
  const BrandingPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Stillwater Branding Showcase')),
      body: ListView(
        padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
        children: [
          // 1. Hero Brand Presentation
          FfCard(
            variant: FfCardVariant.tinted,
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          // 2. Multi-Theme Variants
          Text('Theme Variants', style: theme.textTheme.titleMedium),
          const SizedBox(height: StillwaterTokens.spaceSm),
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
                      FinanceFlowMark(size: 48, variant: MarkVariant.daylight),
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
                      FinanceFlowMark(size: 48, variant: MarkVariant.deepWater),
                      SizedBox(height: StillwaterTokens.spaceSm),
                      Text(
                        'Deep Water',
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

              // Security Variant
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
                        size: 48,
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

          // 3. Sizing Ladder (Legibility at all scales)
          Text(
            'Sizing & Legibility Ladder',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: StillwaterTokens.spaceSm),
          FfCard(
            child: Column(
              children: [
                _buildSizeRow(18, '18dp — Status Bar / Tiny Glyphs'),
                const Divider(),
                _buildSizeRow(24, '24dp — Standard Action / Tab Icon'),
                const Divider(),
                _buildSizeRow(32, '32dp — Inset Badge / Tile Icon'),
                const Divider(),
                _buildSizeRow(48, '48dp — Card Header / Dialog Icon'),
                const Divider(),
                _buildSizeRow(72, '72dp — Onboarding / Lock Screen'),
                const Divider(),
                _buildSizeRow(96, '96dp — Splash & Master Preview'),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          // 4. Launcher & Notification Previews
          Text(
            'Platform Icons & Safe Zones',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: StillwaterTokens.spaceSm),
          FfCard(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: StillwaterColors.lightPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: FinanceFlowMark(
                        size: 32,
                        variant: MarkVariant.monochrome,
                      ),
                    ),
                  ),
                  title: const Text('Squircle Launcher Icon'),
                  subtitle: const Text('Android / iOS standard mask'),
                  trailing: const FfPrivacyBadge(label: 'Safe Zone Pass'),
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: StillwaterColors.lightPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: FinanceFlowMark(
                        size: 32,
                        variant: MarkVariant.monochrome,
                      ),
                    ),
                  ),
                  title: const Text('Circular Launcher Icon'),
                  subtitle: const Text('Pixel & Android round mask'),
                  trailing: const FfPrivacyBadge(label: 'Safe Zone Pass'),
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? const Color(0xFF1E2624)
                              : const Color(0xFF37413E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: FinanceFlowMark(
                        size: 24,
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
