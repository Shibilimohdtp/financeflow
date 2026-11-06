import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_numeric_keypad.dart';
import '../../shared/widgets/ff_surfaces.dart';
import '../../shared/widgets/financeflow_mark.dart';
import '../../theme/ff.dart';
import '../settings/settings_controller.dart';

/// The app lock screen (Pattern G): sits on dark surfaceInk with a calm aurora
/// wash, a centered squircle mark, clear PIN dots, accessible 48+ dp keypad
/// targets, and status cues with icons and words. Zero static color reads.
class LockScreen extends ConsumerStatefulWidget {
  final VoidCallback onUnlocked;

  const LockScreen({super.key, required this.onUnlocked});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _enteredPin = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryBiometricUnlock();
    });
  }

  Future<void> _tryBiometricUnlock() async {
    final settings = ref.read(settingsStreamProvider).value;
    if (settings?.isBiometricEnabled == true) {
      final securityService = ref.read(securityServiceProvider);
      final success = await securityService.authenticateWithBiometrics(
        reason: 'Unlock FinanceFlow',
      );

      if (success) {
        widget.onUnlocked();
      }
    }
  }

  void _onDigitPressed(String digit) {
    if (_enteredPin.length < 6) {
      final newPin = _enteredPin + digit;
      setState(() {
        _enteredPin = newPin;
        _errorMessage = null;
      });
      if (newPin.length >= 4) {
        _verifyPin(newPin);
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = null;
      });
    }
  }

  Future<void> _verifyPin(String pin) async {
    final securityService = ref.read(securityServiceProvider);
    final isValid = await securityService.verifyPin(pin);
    if (isValid) {
      widget.onUnlocked();
    } else {
      if (pin.length >= 6) {
        setState(() {
          _errorMessage = 'Incorrect PIN. Please try again.';
          _enteredPin = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsStreamProvider).value;
    final isBiometric = settings?.isBiometricEnabled ?? false;
    final isPin = settings?.isPinEnabled ?? false;

    final onInk = context.ff.color.onSurfaceInk;

    return FfAurora(
      child: Scaffold(
        backgroundColor: context.ff.color.surfaceInk,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: FfSpace.x2l,
                vertical: FfSpace.md,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Centered Squircle Mark
                  Container(
                    width: 76,
                    height: 76,
                    decoration: ShapeDecoration(
                      shape: FfShape.of(FfRadius.xl),
                      color: context.ff.color.tint(onInk, FfTint.subtle),
                      shadows: FfElevation.card(
                        context.ff.color.shadow,
                        Brightness.dark,
                      ),
                    ),
                    child: const Center(
                      child: FinanceFlowMark(
                        size: 42,
                        variant: MarkVariant.monochrome,
                      ),
                    ),
                  ),
                  const SizedBox(height: FfSpace.lg),

                  Text(
                    'FinanceFlow Locked',
                    style: context.ff.text.displaySm.copyWith(
                      color: onInk,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: FfSpace.xs),
                  Text(
                    'Your financial data is protected on this device.',
                    style: context.ff.text.bodySm.copyWith(
                      color: context.ff.color.tint(onInk, FfTint.medium),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: FfSpace.x2l),

                  if (isPin) ...[
                    // PIN Dots (4 or 6)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_enteredPin.length > 4 ? 6 : 4, (
                        index,
                      ) {
                        final isFilled = index < _enteredPin.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: FfSpace.x2s,
                          ),
                          width: 14,
                          height: 14,
                          decoration: ShapeDecoration(
                            shape: FfShape.of(
                              FfRadius.full,
                              side: BorderSide(
                                color:
                                    isFilled
                                        ? context.ff.color.spark
                                        : context.ff.color.tint(
                                          onInk,
                                          FfTint.strong,
                                        ),
                                width: FfBorderWidth.regular,
                              ),
                            ),
                            color:
                                isFilled
                                    ? context.ff.color.spark
                                    : context.ff.color.tint(
                                      onInk,
                                      FfTint.faint,
                                    ),
                          ),
                        );
                      }),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: FfSpace.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: context.ff.color.statusError,
                          ),
                          const SizedBox(width: FfSpace.xs),
                          Text(
                            _errorMessage!,
                            style: context.ff.text.bodySm.copyWith(
                              color: context.ff.color.statusError,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: FfSpace.x2l),

                    // Shared Tactile Numeric Keypad
                    FfNumericKeypad(
                      digitColor: onInk,
                      showBiometric: isBiometric,
                      onBiometric: _tryBiometricUnlock,
                      onDigit: _onDigitPressed,
                      onDelete: _onDeletePressed,
                    ),
                  ] else if (isBiometric) ...[
                    const SizedBox(height: FfSpace.x2l),
                    FfButton(
                      label: 'Unlock with Biometrics',
                      onPressed: _tryBiometricUnlock,
                      width: 240,
                    ),
                  ] else ...[
                    const SizedBox(height: FfSpace.x2l),
                    FfButton(
                      label: 'Unlock',
                      onPressed: widget.onUnlocked,
                      width: 200,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
