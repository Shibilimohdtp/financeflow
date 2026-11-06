import 'package:flutter/material.dart';
import '../../theme/ff.dart';

/// Animated shimmer skeleton loader for loading states.
///
/// Renders a pulsing placeholder that matches the app's card background.
/// Compose [FfSkeletonBlock]s inside a [FfSkeletonLoader] for rich layouts.
class FfSkeletonLoader extends StatefulWidget {
  final Widget child;

  const FfSkeletonLoader({super.key, required this.child});

  @override
  State<FfSkeletonLoader> createState() => _FfSkeletonLoaderState();
}

class _FfSkeletonLoaderState extends State<FfSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: FfMotion.deliberate,
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder:
          (context, child) => Opacity(opacity: _opacity.value, child: child),
      child: widget.child,
    );
  }
}

/// A single placeholder block used inside [FfSkeletonLoader].
class FfSkeletonBlock extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const FfSkeletonBlock({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = FfRadius.sm,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = context.ff.color.surfaceContainerHigh;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Pre-built skeleton that mimics the [TotalBalanceHero] card.
class FfHeroSkeletonCard extends StatelessWidget {
  const FfHeroSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FfSkeletonLoader(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: FfSpace.lg),
        padding: const EdgeInsets.all(FfSpace.lg),
        decoration: BoxDecoration(
          color: context.ff.color.surfaceCard,
          borderRadius: BorderRadius.circular(FfRadius.xl),
          border: Border.all(
            color: context.ff.color.borderSubtle,
            width: FfBorderWidth.hairline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FfSkeletonBlock(width: 100, height: 12),
            const SizedBox(height: FfSpace.sm),
            const FfSkeletonBlock(width: 220, height: 44),
            const SizedBox(height: FfSpace.md),
            // Flexible, so the three pills shrink on narrow phones instead
            // of overflowing (fixed 88 dp blocks overflowed below ~370 dp).
            Row(
              children: const [
                Flexible(
                  child: FfSkeletonBlock(
                    width: 88,
                    height: 30,
                    borderRadius: 20,
                  ),
                ),
                SizedBox(width: FfSpace.sm),
                Flexible(
                  child: FfSkeletonBlock(
                    width: 88,
                    height: 30,
                    borderRadius: 20,
                  ),
                ),
                SizedBox(width: FfSpace.sm),
                Flexible(
                  child: FfSkeletonBlock(
                    width: 88,
                    height: 30,
                    borderRadius: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Pre-built skeleton that mimics a single transaction row.
class FfTransactionSkeletonRow extends StatelessWidget {
  const FfTransactionSkeletonRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FfSpace.md,
        vertical: FfSpace.sm,
      ),
      child: Row(
        children: [
          const FfSkeletonBlock(width: 36, height: 36, borderRadius: 10),
          const SizedBox(width: FfSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                FfSkeletonBlock(height: 13),
                SizedBox(height: FfSpace.x3s),
                FfSkeletonBlock(width: 90, height: 11),
              ],
            ),
          ),
          const SizedBox(width: FfSpace.md),
          const FfSkeletonBlock(width: 60, height: 14),
        ],
      ),
    );
  }
}

/// Pre-built skeleton that mimics the Analytics metrics hero card.
class FfMetricSkeletonCard extends StatelessWidget {
  const FfMetricSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FfSkeletonLoader(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: FfSpace.lg),
        padding: const EdgeInsets.all(FfSpace.lg),
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
            Row(
              children: const [
                Expanded(child: FfSkeletonBlock(height: 52)),
                SizedBox(width: FfSpace.sm),
                Expanded(child: FfSkeletonBlock(height: 52)),
                SizedBox(width: FfSpace.sm),
                Expanded(child: FfSkeletonBlock(height: 52)),
              ],
            ),
            const SizedBox(height: FfSpace.sm),
            Row(
              children: const [
                Expanded(child: FfSkeletonBlock(height: 52)),
                SizedBox(width: FfSpace.sm),
                Expanded(child: FfSkeletonBlock(height: 52)),
                SizedBox(width: FfSpace.sm),
                Expanded(child: FfSkeletonBlock(height: 52)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
