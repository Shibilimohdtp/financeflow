import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/financeflow_mark.dart';
import '../../theme/stillwater_tokens.dart';
import '../settings/settings_controller.dart';

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
          'No account sign-up is required. You decide if optional integrations or AI features are ever enabled.',
      badgeText: '100% Offline Ready',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: StillwaterTokens.durationBase,
        curve: StillwaterTokens.easeEmphasized,
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
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_currentPage < _steps.length - 1)
            TextButton(
              onPressed: _finishOnboarding,
              child: Text(
                'Skip',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
          const SizedBox(width: StillwaterTokens.spaceMd),
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
                      horizontal: StillwaterTokens.space2Xl,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child:
                                index == 0
                                    ? const FinanceFlowMark(size: 46)
                                    : Icon(
                                      step.icon,
                                      size: 44,
                                      color: theme.colorScheme.primary,
                                    ),
                          ),
                        ),
                        const SizedBox(height: StillwaterTokens.space2Xl),
                        FfPrivacyBadge(label: step.badgeText),
                        const SizedBox(height: StillwaterTokens.spaceMd),
                        Text(
                          step.title,
                          style: theme.textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: StillwaterTokens.spaceXs),
                        Text(
                          step.subtitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: StillwaterTokens.spaceMd),
                        Text(
                          step.body,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.85),
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
              padding: const EdgeInsets.all(StillwaterTokens.space2Xl),
              child: Column(
                children: [
                  // Page Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _steps.length,
                      (index) => AnimatedContainer(
                        duration: StillwaterTokens.durationFast,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              _currentPage == index
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(
                            StillwaterTokens.radiusFull,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: StillwaterTokens.space2Xl),
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
