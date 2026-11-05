import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/financeflow_mark.dart';
import '../settings/settings_controller.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../theme/ff.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingStep> _steps = const [
    OnboardingStep(
      icon: Icons.water_drop_outlined,
      title: 'FinanceFlow',
      subtitle: 'Still water for your financial life',
      body:
          'Track, categorize, and understand your finances in a calm, private space that belongs entirely to you.',
      badgeText: 'Local-First · Offline Core',
    ),
    OnboardingStep(
      icon: Icons.shield_outlined,
      title: 'Your records stay here',
      subtitle: 'Zero cloud servers. Zero data collection.',
      body:
          'Your transactions, accounts, and budgets are encrypted and stored solely on this device. No servers, no tracking, no ad networks.',
      badgeText: '0 Bytes on Servers',
    ),
    OnboardingStep(
      icon: Icons.fingerprint_rounded,
      title: 'Private & Protected',
      subtitle: 'Biometric and PIN protection',
      body:
          'Protect your financial records with device biometrics or a security PIN whenever you choose. Setup is completely optional.',
      badgeText: 'Device Hardware Security',
    ),
    OnboardingStep(
      icon: Icons.check_circle_outline_rounded,
      title: 'You are in full control',
      subtitle: 'Everything works without internet',
      body:
          'No account sign-up is required. You decide if optional integrations are ever enabled.',
      badgeText: '100% Offline Ready',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
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
    return Scaffold(
      backgroundColor: context.ff.color.surfacePage,
      appBar: FfAppBar(
        actions: [
          if (_currentPage < _steps.length - 1)
            TextButton(
              onPressed: _finishOnboarding,
              child: Text(
                'Skip',
                style: context.ff.text.labelLg.copyWith(
                  color: context.ff.color.secondary,
                ),
              ),
            ),
          const SizedBox(width: FfSpace.md),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FfSpace.x2l,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: context.ff.color.actionPrimaryContainer
                                .withValues(alpha: FfOpacity.half),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child:
                                index == 0
                                    ? const FinanceFlowMark(size: 46)
                                    : Icon(
                                      step.icon,
                                      size: 44,
                                      color: context.ff.color.actionPrimary,
                                    ),
                          ),
                        ),
                        const SizedBox(height: FfSpace.x2l),
                        FfPrivacyBadge(label: step.badgeText),
                        const SizedBox(height: FfSpace.md),
                        Text(
                          step.title,
                          style: context.ff.text.displaySm,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: FfSpace.xs),
                        Text(
                          step.subtitle,
                          style: context.ff.text.title.copyWith(
                            color: context.ff.color.actionPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: FfSpace.md),
                        Text(
                          step.body,
                          style: context.ff.text.bodyLg.copyWith(
                            color: context.ff.text.body.color?.withValues(
                              alpha: FfOpacity.high,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(FfSpace.x2l),
              child: Column(
                children: [
                  // Page Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _steps.length,
                      (index) => AnimatedContainer(
                        duration: FfMotion.fast,
                        margin: const EdgeInsets.symmetric(
                          horizontal: FfSpace.x2s,
                        ),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              _currentPage == index
                                  ? context.ff.color.actionPrimary
                                  : context.ff.color.borderSubtle,
                          borderRadius: BorderRadius.circular(FfRadius.full),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: FfSpace.x2l),
                  FfButton(
                    label:
                        _currentPage == _steps.length - 1
                            ? 'Get Started'
                            : 'Continue',
                    onPressed: _nextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingStep {
  final IconData icon;
  final String title;
  final String subtitle;
  final String body;
  final String badgeText;

  const OnboardingStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.badgeText,
  });
}
