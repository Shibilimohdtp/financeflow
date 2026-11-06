import 'package:flutter/material.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_page_scaffold.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/financeflow_mark.dart';
import '../../theme/ff.dart';
import '../../theme/stillwater_theme.dart';

/// Internal brand and Stillwater Bloom preview (DS-B19, Bloom in B-19h).
/// Each swatch is painted with its own theme, so every colour comes from the
/// design tokens rather than from hard-coded values.
class BrandingPreviewScreen extends StatelessWidget {
  const BrandingPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    return FfPageScaffold(
      onAurora: true,
      title: 'Stillwater Branding Showcase',
      subtitle: 'Design system preview',
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: FfSpace.pageMargin,
          vertical: FfSpace.md,
        ),
        children: [
          // ── 1. Hero brand presentation ──────────────────────────────
          FfCard(
            padding: const EdgeInsets.all(FfSpace.xl),
            child: Column(
              children: [
                const FinanceFlowLogo(
                  markSize: 64,
                  fontSize: 28,
                  showTagline: true,
                  axis: Axis.vertical,
                ),
                const SizedBox(height: FfSpace.md),
                Text(
                  'The Stillwater Ripple · Calm financial control',
                  textAlign: TextAlign.center,
                  style: ff.text.bodySm.copyWith(
                    color: ff.color.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: FfSpace.x2l),

          // ── 2. Theme variants ───────────────────────────────────────
          const FfSectionHeader(title: 'Theme variants'),
          Row(
            children: [
              Expanded(
                child: _Swatch(
                  theme: StillwaterTheme.daylight,
                  mark: const FinanceFlowMark(
                    size: 44,
                    variant: MarkVariant.daylight,
                  ),
                  label: 'Daylight',
                ),
              ),
              const SizedBox(width: FfSpace.md),
              Expanded(
                child: _Swatch(
                  theme: StillwaterTheme.deepWater,
                  mark: const FinanceFlowMark(
                    size: 44,
                    variant: MarkVariant.deepWater,
                  ),
                  label: 'Deep Water',
                ),
              ),
              const SizedBox(width: FfSpace.md),
              Expanded(
                child: _Swatch(
                  theme: StillwaterTheme.deepWater,
                  mark: const FinanceFlowMark(
                    size: 44,
                    variant: MarkVariant.monochrome,
                  ),
                  label: 'Monochrome',
                ),
              ),
            ],
          ),

          const SizedBox(height: FfSpace.x2l),

          // ── 3. Sizing ladder ────────────────────────────────────────
          const FfSectionHeader(title: 'Sizing and legibility'),
          FfCard(
            padding: const EdgeInsets.symmetric(
              horizontal: FfSpace.md,
              vertical: FfSpace.xs,
            ),
            child: Column(
              children: [
                _buildSizeRow(18, 'Status bar and compact indicators', context),
                _buildSizeRow(24, 'Navigation and notification icon', context),
                _buildSizeRow(32, 'Inset tile and badge icons', context),
                _buildSizeRow(48, 'Dialog headers and cards', context),
                _buildSizeRow(72, 'Lock screen and keypad header', context),
                _buildSizeRow(96, 'Splash and feature heroes', context),
              ],
            ),
          ),

          const SizedBox(height: FfSpace.x2l),

          // ── 4. Platform icons and safe zones ────────────────────────
          const FfSectionHeader(title: 'Platform icons and safe zones'),
          FfCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _IconRow(
                  title: 'Squircle launcher icon',
                  subtitle: 'Android adaptive, 66 dp safe zone',
                  mark: const FinanceFlowMark(
                    size: 28,
                    variant: MarkVariant.daylight,
                  ),
                  shape: BoxShape.rectangle,
                ),
                _IconRow(
                  title: 'Circular launcher icon',
                  subtitle: 'Pixel and Android round mask',
                  mark: const FinanceFlowMark(
                    size: 28,
                    variant: MarkVariant.daylight,
                  ),
                  shape: BoxShape.circle,
                ),
                _IconRow(
                  title: 'Monochrome notification icon',
                  subtitle: 'Status bar, 24 dp white silhouette',
                  mark: const FinanceFlowMark(
                    size: 22,
                    variant: MarkVariant.monochrome,
                  ),
                  shape: BoxShape.rectangle,
                  dark: true,
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
          Expanded(child: Text(label, style: context.ff.text.bodySm)),
        ],
      ),
    );
  }
}

/// One swatch painted with its own theme, so its colours are tokens.
class _Swatch extends StatelessWidget {
  const _Swatch({required this.theme, required this.mark, required this.label});

  final ThemeData theme;
  final Widget mark;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme,
      child: Builder(
        builder: (context) {
          final ff = context.ff;
          return Container(
            padding: const EdgeInsets.all(FfSpace.md),
            decoration: ShapeDecoration(
              color: ff.color.surfacePage,
              shape: FfShape.of(
                FfRadius.lg,
                side: BorderSide(
                  color: ff.color.borderSubtle,
                  width: FfBorderWidth.hairline,
                ),
              ),
            ),
            child: Column(
              children: [
                mark,
                const SizedBox(height: FfSpace.sm),
                Text(
                  label,
                  style: ff.text.label.copyWith(
                    color: ff.color.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _IconRow extends StatelessWidget {
  const _IconRow({
    required this.title,
    required this.subtitle,
    required this.mark,
    required this.shape,
    this.dark = false,
  });

  final String title;
  final String subtitle;
  final Widget mark;
  final BoxShape shape;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final tile = Theme(
      data: dark ? StillwaterTheme.deepWater : StillwaterTheme.daylight,
      child: Builder(
        builder: (context) {
          final ff = context.ff;
          return Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: ff.color.surfacePage,
              shape:
                  shape == BoxShape.circle
                      ? const CircleBorder()
                      : FfShape.of(
                        FfRadius.md,
                        side: BorderSide(
                          color: ff.color.borderSubtle,
                          width: FfBorderWidth.hairline,
                        ),
                      ),
            ),
            child: mark,
          );
        },
      ),
    );
    return FfRow(
      leading: tile,
      title: title,
      subtitle: subtitle,
      trailing: const FfPrivacyBadge(label: 'Verified'),
    );
  }
}
