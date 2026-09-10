import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/financeflow_mark.dart';
import '../../theme/stillwater_colors.dart';
import '../../theme/stillwater_tokens.dart';
import '../settings/settings_controller.dart';

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

    return Scaffold(
      backgroundColor: StillwaterColors.darkSecInk,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: StillwaterTokens.space2Xl,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Stillwater Security Mark
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: StillwaterColors.darkOnSecInk.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: StillwaterColors.darkOnSecInk.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: FinanceFlowMark(
                      size: 44,
                      variant: MarkVariant.monochrome,
                    ),
                  ),
                ),
                const SizedBox(height: StillwaterTokens.spaceLg),

                const Text(
                  'FinanceFlow Locked',
                  style: TextStyle(
                    color: StillwaterColors.darkOnSecInk,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: StillwaterTokens.spaceXs),
                Text(
                  'Your financial data is protected on this device.',
                  style: TextStyle(
                    color: StillwaterColors.darkOnSecInk.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: StillwaterTokens.space2Xl),

                if (isPin) ...[
                  // PIN Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      6,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              index < _enteredPin.length
                                  ? StillwaterColors.darkOnSecInk
                                  : StillwaterColors.darkOnSecInk.withValues(
                                    alpha: 0.2,
                                  ),
                          border: Border.all(
                            color: StillwaterColors.darkOnSecInk.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: StillwaterTokens.spaceMd),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: StillwaterColors.darkError,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  const SizedBox(height: StillwaterTokens.space2Xl),

                  // PIN Pad Grid
                  SizedBox(
                    width: 260,
                    child: Column(
                      children: [
                        _buildPadRow(['1', '2', '3']),
                        const SizedBox(height: StillwaterTokens.spaceSm),
                        _buildPadRow(['4', '5', '6']),
                        const SizedBox(height: StillwaterTokens.spaceSm),
                        _buildPadRow(['7', '8', '9']),
                        const SizedBox(height: StillwaterTokens.spaceSm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (isBiometric)
                              _buildBiometricButton()
                            else
                              const SizedBox(width: 64, height: 64),
                            _buildPadKey('0'),
                            _buildDeleteKey(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else if (isBiometric) ...[
                  const SizedBox(height: StillwaterTokens.space2Xl),
                  FfButton(
                    label: 'Unlock with Biometrics',
                    onPressed: _tryBiometricUnlock,
                    width: 240,
                  ),
                ] else ...[
                  const SizedBox(height: StillwaterTokens.space2Xl),
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
    );
  }

  Widget _buildPadRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: digits.map(_buildPadKey).toList(),
    );
  }

  Widget _buildPadKey(String digit) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Material(
        color: StillwaterColors.darkOnSecInk.withValues(alpha: 0.08),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _onDigitPressed(digit),
          child: Center(
            child: Text(
              digit,
              style: const TextStyle(
                color: StillwaterColors.darkOnSecInk,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    return SizedBox(
      width: 64,
      height: 64,
      child: IconButton(
        icon: const Icon(
          Icons.fingerprint_rounded,
          color: StillwaterColors.darkOnSecInk,
          size: 32,
        ),
        onPressed: _tryBiometricUnlock,
      ),
    );
  }

  Widget _buildDeleteKey() {
    return SizedBox(
      width: 64,
      height: 64,
      child: IconButton(
        icon: const Icon(
          Icons.backspace_outlined,
          color: StillwaterColors.darkOnSecInk,
          size: 24,
        ),
        onPressed: _onDeletePressed,
      ),
    );
  }
}
