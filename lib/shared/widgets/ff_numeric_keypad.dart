import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/ff.dart';

/// A shared, accessible tactile numeric keypad in Stillwater Bloom.
///
/// Provides 64x64 dp touch targets (well above the 48 dp minimum), Geist
/// numerals, haptic feedback, backspace, and an optional biometric action key.
class FfNumericKeypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final VoidCallback? onBiometric;
  final bool showBiometric;
  final Color? digitColor;

  const FfNumericKeypad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    this.onBiometric,
    this.showBiometric = false,
    this.digitColor,
  });

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final color = digitColor ?? ff.color.textPrimary;

    return SizedBox(
      width: 272,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(['1', '2', '3'], color, context),
          const SizedBox(height: FfSpace.sm),
          _buildRow(['4', '5', '6'], color, context),
          const SizedBox(height: FfSpace.sm),
          _buildRow(['7', '8', '9'], color, context),
          const SizedBox(height: FfSpace.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showBiometric && onBiometric != null)
                _buildActionKey(
                  icon: Icons.fingerprint_rounded,
                  tooltip: 'Unlock with biometrics',
                  color: color,
                  onTap: onBiometric!,
                )
              else
                const SizedBox(width: 64, height: 64),
              _buildDigitKey('0', color, context),
              _buildActionKey(
                icon: Icons.backspace_outlined,
                tooltip: 'Delete digit',
                color: color,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> digits, Color color, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: digits.map((d) => _buildDigitKey(d, color, context)).toList(),
    );
  }

  Widget _buildDigitKey(String digit, Color color, BuildContext context) {
    final ff = context.ff;

    return Semantics(
      button: true,
      label: digit,
      child: SizedBox(
        width: 64,
        height: 64,
        child: Material(
          color: ff.color.tint(color, FfTint.faint),
          shape: FfShape.of(FfRadius.full),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onDigit(digit);
            },
            child: Center(
              child: Text(
                digit,
                style: ff.text.headlineSm.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: tooltip,
      child: SizedBox(
        width: 64,
        height: 64,
        child: IconButton(
          icon: Icon(icon, color: color, size: 24),
          tooltip: tooltip,
          onPressed: () {
            HapticFeedback.selectionClick();
            onTap();
          },
        ),
      ),
    );
  }
}
