import 'package:flutter/material.dart';

import '../../theme/ff.dart';

/// The single collapsible "More details" group at the end of a form. A
/// 48 dp row with a chevron; when open, its [children] follow, spaced like
/// the rest of the sheet.
class FfDisclosureRow extends StatefulWidget {
  const FfDisclosureRow({
    super.key,
    this.title = 'More details',
    this.subtitle,
    required this.children,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
  });

  final String title;

  /// What is inside, while closed ("Units, account, notes").
  final String? subtitle;
  final List<Widget> children;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;

  @override
  State<FfDisclosureRow> createState() => _FfDisclosureRowState();
}

class _FfDisclosureRowState extends State<FfDisclosureRow> {
  late bool _open = widget.initiallyExpanded;

  void _toggle() {
    setState(() => _open = !_open);
    widget.onExpansionChanged?.call(_open);
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final c = ff.color;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: _open,
          child: InkWell(
            onTap: _toggle,
            customBorder: FfShape.of(FfRadius.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: FfTouch.minTarget),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: FfSpace.xs),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.title, style: ff.text.title),
                          if (widget.subtitle != null && !_open)
                            Text(
                              widget.subtitle!,
                              style: ff.text.bodySm.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0,
                      duration: reduceMotion ? Duration.zero : FfMotion.fast,
                      child: Icon(
                        Icons.expand_more_rounded,
                        size: FfIconSize.xl,
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: reduceMotion ? Duration.zero : FfMotion.base,
          curve: FfMotion.emphasized,
          alignment: AlignmentDirectional.topStart,
          child:
              _open
                  ? Padding(
                    padding: const EdgeInsets.only(top: FfSpace.sm),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < widget.children.length; i++) ...[
                          if (i > 0)
                            const SizedBox(height: FfSheetTokens.itemGap),
                          widget.children[i],
                        ],
                      ],
                    ),
                  )
                  : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
