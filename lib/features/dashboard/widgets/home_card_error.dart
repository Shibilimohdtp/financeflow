import 'package:flutter/material.dart';

import '../../../shared/widgets/ff_banner.dart';

/// Shown when a Home card's data fails to load: says so plainly and offers a
/// retry. The data itself is untouched.
class HomeCardError extends StatelessWidget {
  final String what;
  final VoidCallback onRetry;

  const HomeCardError({super.key, required this.what, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return FfBanner(
      tone: FfBannerTone.warning,
      title: 'Could not load $what',
      message: 'Your data is safe on this device.',
      actionLabel: 'Try again',
      onAction: onRetry,
    );
  }
}
