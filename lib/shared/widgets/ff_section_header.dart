import 'package:flutter/material.dart';
import '../../theme/ff.dart';

/// A standard Stillwater section header with uppercase label style.
class FfSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final bool isUppercase;
  final EdgeInsetsGeometry padding;

  const FfSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.isUppercase = false,
    this.padding = const EdgeInsets.only(
      left: FfSpace.xs,
      right: FfSpace.xs,
      bottom: FfSpace.xs,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              isUppercase ? title.toUpperCase() : title,
              style:
                  isUppercase
                      ? context.ff.text.labelSm.copyWith(
                        color: context.ff.color.secondary,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                      )
                      : context.ff.text.title.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
