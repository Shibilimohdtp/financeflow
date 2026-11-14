import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/ff_numeric_keypad.dart';
import '../../../shared/widgets/ff_sheet.dart';
import '../../../shared/widgets/ff_sheet_header.dart';
import '../../../shared/widgets/ff_toast.dart';
import '../../../theme/ff.dart';
import '../../settings/settings_controller.dart';

/// Opens the guided 2-step PIN setup sheet in Stillwater Bloom.
void showGuidedPinSetupSheet(BuildContext context, WidgetRef ref) {
  showFfSheet(context, builder: (ctx) => const _GuidedPinSetupSheet());
}

class _GuidedPinSetupSheet extends ConsumerStatefulWidget {
  const _GuidedPinSetupSheet();

  @override
  ConsumerState<_GuidedPinSetupSheet> createState() =>
      _GuidedPinSetupSheetState();
}

class _GuidedPinSetupSheetState extends ConsumerState<_GuidedPinSetupSheet> {
  String _firstPin = '';
  String _confirmPin = '';
  bool _isConfirmStep = false;
  String? _errorMessage;

  void _onDigit(String digit) {
    if (!_isConfirmStep) {
      if (_firstPin.length < 4) {
        final next = _firstPin + digit;
        setState(() {
          _firstPin = next;
          _errorMessage = null;
        });
        if (next.length == 4) {
          Future.delayed(const Duration(milliseconds: 150), () {
            if (mounted) {
              setState(() {
                _isConfirmStep = true;
              });
            }
          });
        }
      }
    } else {
      if (_confirmPin.length < 4) {
        final next = _confirmPin + digit;
        setState(() {
          _confirmPin = next;
          _errorMessage = null;
        });
        if (next.length == 4) {
          _verifyAndSave(next);
        }
      }
    }
  }

  void _onDelete() {
    if (!_isConfirmStep) {
      if (_firstPin.isNotEmpty) {
        setState(() {
          _firstPin = _firstPin.substring(0, _firstPin.length - 1);
          _errorMessage = null;
        });
      }
    } else {
      if (_confirmPin.isNotEmpty) {
        setState(() {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
          _errorMessage = null;
        });
      } else {
        // Step back to first PIN
        setState(() {
          _isConfirmStep = false;
        });
      }
    }
  }

  Future<void> _verifyAndSave(String confirm) async {
    if (confirm == _firstPin) {
      HapticFeedback.mediumImpact();
      final securityService = ref.read(securityServiceProvider);
      await securityService.setPin(_firstPin);
      await ref.read(settingsControllerProvider.notifier).setPinEnabled(true);

      if (mounted) {
        Navigator.of(context).pop();
        FfToast.show(context, message: 'Security PIN set safely.');
      }
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _errorMessage = 'PINs did not match. Please try again.';
        _confirmPin = '';
        _firstPin = '';
        _isConfirmStep = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final activePin = _isConfirmStep ? _confirmPin : _firstPin;

    return FfSheet(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FfSheetHeader(
          title: _isConfirmStep ? 'Confirm your PIN' : 'Set a PIN',
          subtitle:
              _isConfirmStep
                  ? 'Enter the same 4 digits again'
                  : 'Four digits that unlock FinanceFlow',
        ),
        Padding(
          padding: FfSheetBody.standardPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // PIN Dots (4)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < activePin.length;
                  return AnimatedContainer(
                    duration:
                        MediaQuery.of(context).disableAnimations
                            ? Duration.zero
                            : FfMotion.fast,
                    margin: const EdgeInsets.symmetric(horizontal: FfSpace.xs),
                    width: FfIconSize.sm,
                    height: FfIconSize.sm,
                    decoration: ShapeDecoration(
                      shape: FfShape.of(
                        FfRadius.full,
                        side: BorderSide(
                          color:
                              isFilled
                                  ? ff.color.spark
                                  : ff.color.borderControl,
                          width: FfBorderWidth.regular,
                        ),
                      ),
                      color:
                          isFilled
                              ? ff.color.spark
                              : ff.color.tint(
                                ff.color.textPrimary,
                                FfTint.faint,
                              ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: FfSpace.sm),

              // Error or Step Indicator
              if (_errorMessage != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: FfIconSize.sm,
                      color: ff.color.statusError,
                    ),
                    const SizedBox(width: FfSpace.xs),
                    Flexible(
                      child: Text(
                        _errorMessage!,
                        style: ff.text.bodySm.copyWith(
                          color: ff.color.statusError,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Text(
                  _isConfirmStep ? 'Step 2 of 2' : 'Step 1 of 2',
                  style: ff.text.label.copyWith(color: ff.color.textSecondary),
                ),

              const SizedBox(height: FfSpace.lg),

              // Keypad
              FfNumericKeypad(onDigit: _onDigit, onDelete: _onDelete),

              const SizedBox(height: FfSpace.md),
            ],
          ),
        ),
      ],
    );
  }
}
