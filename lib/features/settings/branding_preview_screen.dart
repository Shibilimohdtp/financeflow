import 'package:flutter/material.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_page_scaffold.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/financeflow_mark.dart';
import '../../theme/ff.dart';

/// Internal Branding & Stillwater Bloom Design System Preview Screen (DS-B19).
class BrandingPreviewScreen extends StatelessWidget {
  const BrandingPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FfPageScaffold(
      title: 'Stillwater Branding Showcase',
      subtitle: 'Design system preview',
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: FfSpace.lg,
          vertical: FfSpace.md,
        ),
        children: [
          // ── 1. Hero Brand Presentation ──────────────────────────────
          Container(
            padding: const EdgeInsets.all(FfSpace.xl),
            decoration: BoxDecoration(
              color: context.ff.color.surfaceCard,
              borderRadius: BorderRadius.circular(FfRadius.lg),
              border: Border.all(
                color: context.ff.color.borderSubtle,
                width: FfBorderWidth.hairline,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: FfSpace.sm),
                const FinanceFlowLogo(
                  markSize: 64,
                  fontSize: 28,
                  showTagline: true,
                  axis: Axis.vertical,
                ),
                const SizedBox(height: FfSpace.md),
                Text(
                  'The Stillwater Ripple · Calm Financial Control',
                  style: context.ff.text.bodySm.copyWith(
                    color: context.ff.color.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: FfSpace.x2l),

          // ── 2. Multi-Theme Variants ──────────────────────────────────
          _SectionLabel(label: 'Theme Variants'),
          const SizedBox(height: FfSpace.xs),
          Row(
            children: [
              // Daylight Variant
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(FfSpace.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F2EC),
                    borderRadius: BorderRadius.circular(FfRadius.md),
                    border: Border.all(
                      color: const Color(0xFFE3E3D9),
                    ),
                  ),
                  child: Column(
                    children: [
                      const FinanceFlowMark(size: 44, variant: MarkVariant.daylight),
                      const SizedBox(height: FfSpace.sm),
                      Text(
                        'Daylight',
                        style: context.ff.text.label.copyWith(
                          color: const Color(0xFF1B1D17),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: FfSpace.md),

              // Deep Water Variant
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(FfSpace.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10120E),
                    borderRadius: BorderRadius.circular(FfRadius.md),
                    border: Border.all(
                      color: const Color(0xFF2C3024),
                    ),
                  ),
                  child: Column(
                    children: [
                      const FinanceFlowMark(size: 44, variant: MarkVariant.deepWater),
                      const SizedBox(height: FfSpace.sm),
                      Text(
                        'Deep Water',
                        style: context.ff.text.label.copyWith(
                          color: const Color(0xFFE4E4DC),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: FfSpace.md),

              // Monochrome Variant
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(FfSpace.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1D17),
                    borderRadius: BorderRadius.circular(FfRadius.md),
                  ),
                  child: Column(
                    children: [
                      const FinanceFlowMark(
                        size: 44,
                        variant: MarkVariant.monochrome,
                      ),
                      const SizedBox(height: FfSpace.sm),
                      Text(
                        'Monochrome',
                        style: context.ff.text.label.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: FfSpace.x2l),

          // ── 3. Sizing Ladder ─────────────────────────────────────────
          _SectionLabel(label: 'Sizing & Legibility Ladder'),
          const SizedBox(height: FfSpace.xs),
          Container(
            padding: const EdgeInsets.all(FfSpace.md),
            decoration: BoxDecoration(
              color: context.ff.color.surfaceCard,
              borderRadius: BorderRadius.circular(FfRadius.lg),
              border: Border.all(
                color: context.ff.color.borderSubtle,
                width: FfBorderWidth.hairline,
              ),
            ),
            child: Column(
              children: [
                _buildSizeRow(18, '18dp — Status Bar & Compact Indicators', context),
                const FfDivider(),
                _buildSizeRow(24, '24dp — Standard Navigation & Notification Icon', context),
                const FfDivider(),
                _buildSizeRow(32, '32dp — Inset Tile & Badge Icons', context),
                const FfDivider(),
                _buildSizeRow(48, '48dp — Dialog Headers & Cards', context),
                const FfDivider(),
                _buildSizeRow(72, '72dp — Lock Screen & Keypad Header', context),
                const FfDivider(),
                _buildSizeRow(96, '96dp — Splash & Feature Hero Displays', context),
              ],
            ),
          ),

          const SizedBox(height: FfSpace.x2l),

          // ── 4. Platform Safe Zones ───────────────────────────────────
          _SectionLabel(label: 'Platform Icons & Safe Zones'),
          const SizedBox(height: FfSpace.xs),
          Container(
            decoration: BoxDecoration(
              color: context.ff.color.surfaceCard,
              borderRadius: BorderRadius.circular(FfRadius.lg),
              border: Border.all(
                color: context.ff.color.borderSubtle,
                width: FfBorderWidth.hairline,
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F2EC),
                      borderRadius: BorderRadius.circular(FfRadius.md),
                      border: Border.all(color: context.ff.color.borderSubtle),
                    ),
                    child: const Center(
                      child: FinanceFlowMark(
                        size: 28,
                        variant: MarkVariant.daylight,
                      ),
                    ),
                  ),
                  title: const Text('Squircle Launcher Icon'),
                  subtitle: const Text('Android adaptive 66dp safe zone'),
                  trailing: const FfPrivacyBadge(label: 'Verified'),
                ),
                const FfDivider(),
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F2EC),
                      shape: BoxShape.circle,
                      border: Border.all(color: context.ff.color.borderSubtle),
                    ),
                    child: const Center(
                      child: FinanceFlowMark(
                        size: 28,
                        variant: MarkVariant.daylight,
                      ),
                    ),
                  ),
                  title: const Text('Circular Launcher Icon'),
                  subtitle: const Text('Pixel & Android round mask'),
                  trailing: const FfPrivacyBadge(label: 'Verified'),
                ),
                const FfDivider(),
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1D17),
                      borderRadius: BorderRadius.circular(FfRadius.sm),
                    ),
                    child: const Center(
                      child: FinanceFlowMark(
                        size: 22,
                        variant: MarkVariant.monochrome,
                      ),
                    ),
                  ),
                  title: const Text('Monochrome Notification Icon'),
                  subtitle: const Text('Status bar 24dp white alpha silhouette'),
                  trailing: const FfPrivacyBadge(label: 'Verified'),
                ),
              ],
            ),
          ),
          const SizedBox(height: FfSpace.x4l),
        ],
      ),
    );
  }

  Widget _buildSizeRow(double size, String label, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FfSpace.xs),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Center(child: FinanceFlowMark(size: size)),
          ),
          const SizedBox(width: FfSpace.md),
          Expanded(
            child: Text(
              label,
              style: context.ff.text.bodySm.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: FfSpace.x2s),
      child: Text(
        label,
        style: context.ff.text.titleSm.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
