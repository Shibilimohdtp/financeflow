import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_page_scaffold.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/financeflow_mark.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import '../settings/settings_controller.dart';

/// First-run walk-through in Stillwater Bloom (pattern G, on the aurora).
/// Each page has its own small, drawn visual instead of an icon in a circle.
/// Copy only claims what the code does: the live database is not encrypted
/// at rest, but backups are encrypted with a passphrase.
class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingStep> _steps = [
    _OnboardingStep(
      visual: _VisualKind.mark,
      title: 'FinanceFlow',
      subtitle: 'Still water for your financial life',
      body:
          'Track spending, money you lend and borrow, and your loans, in a calm space that lives on this phone.',
      badgeText: 'Local-first',
    ),
    _OnboardingStep(
      visual: _VisualKind.device,
      title: 'Your records stay here',
      subtitle: 'Nothing leaves this phone',
      body:
          'Accounts, transactions and loans are kept only on this device. There are no servers and no account to sign into. Backups are encrypted with a passphrase you choose.',
      badgeText: 'No servers',
    ),
    _OnboardingStep(
      visual: _VisualKind.lock,
      title: 'Lock it if you want',
      subtitle: 'Optional PIN, fingerprint or face',
      body:
          'Lock the app with a PIN, or with your device’s biometrics. Setup is optional, and you can change it later in Settings.',
      badgeText: 'Optional',
    ),
    _OnboardingStep(
      visual: _VisualKind.promises,
      title: 'You stay in control',
      subtitle: 'Works offline, asks only when needed',
      body:
          'No sign-up is needed. Bank message and notification reading is optional, and it asks for permission before it reads anything.',
      badgeText: 'Offline ready',
    ),
  ];

  bool get _isLast => _currentPage == _steps.length - 1;

  void _nextPage() {
    if (!_isLast) {
      _pageController.nextPage(
        duration: FfMotion.base,
        curve: FfMotion.emphasized,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    await ref
        .read(settingsControllerProvider.notifier)
        .setOnboardingCompleted(true);
    widget.onComplete();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    return FfPageScaffold(
      onAurora: true,
      actions: [
        if (!_isLast)
          TextButton(
            onPressed: _finishOnboarding,
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            child: Text(
              'Skip',
              style: ff.text.labelLg.copyWith(color: ff.color.secondary),
            ),
          ),
        const SizedBox(width: FfSpace.md),
      ],
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _steps.length,
              onPageChanged: (page) => setState(() => _currentPage = page),
              itemBuilder: (context, index) {
                final step = _steps[index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FfSpace.pageMargin,
                    vertical: FfSpace.md,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.sizeOf(context).height * 0.5,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StepVisual(kind: step.visual),
                        const SizedBox(height: FfSpace.x2l),
                        FfPrivacyBadge(label: step.badgeText),
                        const SizedBox(height: FfSpace.md),
                        Text(
                          step.title,
                          style: ff.text.displaySm,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: FfSpace.xs),
                        Text(
                          step.subtitle,
                          style: ff.text.title.copyWith(
                            color: ff.color.actionPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: FfSpace.md),
                        Text(
                          step.body,
                          style: ff.text.bodyLg.copyWith(
                            color: ff.color.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              FfSpace.pageMargin,
              FfSpace.md,
              FfSpace.pageMargin,
              FfSpace.x2l,
            ),
            child: Column(
              children: [
                // Pill progress: the current page is the long pill.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _steps.length,
                    (index) => AnimatedContainer(
                      duration: FfMotion.fast,
                      margin: const EdgeInsets.symmetric(
                        horizontal: FfSpace.x2s,
                      ),
                      width: _currentPage == index ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                            _currentPage == index
                                ? ff.color.actionPrimary
                                : ff.color.borderSubtle,
                        borderRadius: BorderRadius.circular(FfRadius.full),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: FfSpace.x2l),
                FfButton(
                  label: _isLast ? 'Get started' : 'Continue',
                  variant:
                      _isLast ? FfButtonVariant.spark : FfButtonVariant.primary,
                  onPressed: _nextPage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _VisualKind { mark, device, lock, promises }

class _OnboardingStep {
  final _VisualKind visual;
  final String title;
  final String subtitle;
  final String body;
  final String badgeText;

  const _OnboardingStep({
    required this.visual,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.badgeText,
  });
}

/// One drawn visual per page, built from the app's own shapes.
class _StepVisual extends StatelessWidget {
  const _StepVisual({required this.kind});

  final _VisualKind kind;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final tone = switch (kind) {
      _VisualKind.mark => FfTone.primary,
      _VisualKind.device => FfTone.success,
      _VisualKind.lock => FfTone.debt,
      _VisualKind.promises => FfTone.accent,
    };
    return SizedBox(
      width: double.infinity,
      child: FfCard(
        variant: FfCardVariant.tinted,
        tone: tone,
        padding: const EdgeInsets.all(FfSpace.xl),
        child: Center(child: _content(context, ff)),
      ),
    );
  }

  Widget _content(BuildContext context, FfThemeData ff) {
    switch (kind) {
      case _VisualKind.mark:
        return const FinanceFlowMark(size: 96);
      case _VisualKind.device:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.smartphone_rounded,
              size: 72,
              color: ff.color.actionPrimary,
            ),
            const SizedBox(width: FfSpace.lg),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final w in const [120.0, 90.0, 104.0])
                  Container(
                    width: w,
                    height: 10,
                    margin: const EdgeInsets.only(bottom: FfSpace.xs),
                    decoration: BoxDecoration(
                      color: ff.color.borderSubtle,
                      borderRadius: BorderRadius.circular(FfRadius.full),
                    ),
                  ),
                const SizedBox(height: FfSpace.xs),
                Icon(
                  Icons.verified_user_outlined,
                  size: 22,
                  color: ff.color.statusSuccess,
                ),
              ],
            ),
          ],
        );
      case _VisualKind.lock:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 4; i++)
                  Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.symmetric(horizontal: FfSpace.x2s),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          i < 3
                              ? ff.color.actionPrimary
                              : ff.color.borderSubtle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: FfSpace.lg),
            Icon(
              Icons.fingerprint_rounded,
              size: 56,
              color: ff.color.actionPrimary,
            ),
          ],
        );
      case _VisualKind.promises:
        const promises = ['No account', 'No servers', 'Works offline'];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final p in promises)
              Container(
                width: 220,
                margin: const EdgeInsets.only(bottom: FfSpace.xs),
                padding: const EdgeInsets.symmetric(
                  horizontal: FfSpace.md,
                  vertical: FfSpace.sm,
                ),
                decoration: BoxDecoration(
                  color: ff.color.surfaceRaised,
                  borderRadius: BorderRadius.circular(FfRadius.full),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: ff.color.statusSuccess,
                    ),
                    const SizedBox(width: FfSpace.xs),
                    Text(p, style: ff.text.label),
                  ],
                ),
              ),
          ],
        );
    }
  }
}
