import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/ff.dart';
import 'ff_chip.dart';
import 'ff_surfaces.dart';

// ---------------------------------------------------------------------------
// Pill bar
// ---------------------------------------------------------------------------

/// A horizontally scrolling row of filter pills: "All · Expenses · Income".
/// The selected pill is solid ink; the others are outlined.
class FfPillBar<T> extends StatelessWidget {
  const FfPillBar({
    super.key,
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
  });

  final List<T> values;
  final T selected;
  final String Function(T value) label;
  final ValueChanged<T> onSelected;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (final (i, v) in values.indexed) ...[
            if (i > 0) const SizedBox(width: FfPillTokens.gap),
            FfChip(
              label: label(v),
              isSelected: v == selected,
              onSelected: () {
                if (v != selected) HapticFeedback.selectionClick();
                onSelected(v);
              },
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dock
// ---------------------------------------------------------------------------

/// One destination in the [FfDock].
class FfDockItem {
  const FfDockItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badgeCount = 0,
    this.showDot = false,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  /// A number badge (pending reviews).
  final int badgeCount;

  /// A small dot badge (unread alerts).
  final bool showDot;
}

/// The floating navigation dock. The selected destination expands into an
/// ink pill with its label; the others are 48 dp circles with tooltips and
/// screen-reader labels. Floats over content on glass.
///
/// Becomes a full-width bar with a label under every icon when the text
/// scale is large (`FfDockTokens.barTextScale`), and a solid surface when
/// effects are reduced. Pages leave room for it with [FfDock.insetOf].
class FfDock extends StatelessWidget {
  const FfDock({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<FfDockItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// A floating action button location that floats in the bottom-right corner
  /// cleanly above the dock.
  static const FloatingActionButtonLocation fabLocation = _FfDockFabLocation();

  /// Bottom padding a page needs so its last item clears the dock.
  static double insetOf(BuildContext context) {
    final media = MediaQuery.of(context);
    if (useBar(context)) return 0; // a Scaffold bottom bar takes its space
    return FfDockTokens.height +
        FfDockTokens.bottomMargin +
        media.padding.bottom +
        FfSpace.sm;
  }

  /// Whether the dock falls back to a full-width bottom bar.
  static bool useBar(BuildContext context) => _useBar(context);

  static bool _useBar(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(10) / 10 >=
      FfDockTokens.barTextScale;

  void _select(int i) {
    if (i != selectedIndex) HapticFeedback.selectionClick();
    onSelected(i);
  }

  @override
  Widget build(BuildContext context) {
    if (_useBar(context)) return _bar(context);
    final c = context.ff.color;
    final brightness = Theme.of(context).brightness;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: FfDockTokens.bottomMargin),
      child: Center(
        heightFactor: 1,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: const StadiumBorder(),
            shadows: FfElevation.float(c.shadow, brightness),
          ),
          child: FfGlass(
            blur: FfBlur.dock,
            padding: const EdgeInsets.all(FfDockTokens.padding),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (i, item) in items.indexed) ...[
                  if (i > 0) const SizedBox(width: FfDockTokens.gap),
                  _DockButton(
                    item: item,
                    selected: i == selectedIndex,
                    onTap: () => _select(i),
                    position: '${i + 1} of ${items.length}',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bar(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: _select,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        for (final item in items)
          NavigationDestination(
            icon: _badged(context, item, Icon(item.icon)),
            selectedIcon: _badged(
              context,
              item,
              Icon(item.selectedIcon ?? item.icon),
            ),
            label: item.label,
          ),
      ],
    );
  }

  static Widget _badged(BuildContext context, FfDockItem item, Widget icon) {
    final c = context.ff.color;
    if (item.badgeCount > 0) {
      return Badge.count(
        count: item.badgeCount,
        backgroundColor: c.spark,
        textColor: c.onSpark,
        child: icon,
      );
    }
    if (item.showDot) {
      return Badge(smallSize: 8, backgroundColor: c.spark, child: icon);
    }
    return icon;
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.position,
  });

  final FfDockItem item;
  final bool selected;
  final VoidCallback onTap;
  final String position;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final c = ff.color;
    final fg = selected ? c.onActionPrimary : c.textPrimary;
    final icon = FfDock._badged(
      context,
      item,
      Icon(
        selected ? (item.selectedIcon ?? item.icon) : item.icon,
        size: FfDockTokens.iconSize,
        color: fg,
      ),
    );
    final badgeText =
        item.badgeCount > 0
            ? ', ${item.badgeCount} new'
            : item.showDot
            ? ', new'
            : '';
    return Tooltip(
      message: item.label,
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        selected: selected,
        label: '${item.label}$badgeText, tab $position',
        excludeSemantics: true,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            customBorder: const StadiumBorder(),
            child: AnimatedContainer(
              duration: FfMotion.base,
              curve: FfMotion.emphasized,
              height: FfDockTokens.itemSize,
              constraints: const BoxConstraints(
                minWidth: FfDockTokens.itemSize,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: selected ? FfSpace.md : 0,
              ),
              decoration: ShapeDecoration(
                shape: const StadiumBorder(),
                color: selected ? c.actionPrimary : Colors.transparent,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  if (selected) ...[
                    const SizedBox(width: FfSpace.xs),
                    Text(
                      item.label,
                      style: ff.text.labelLg.copyWith(color: fg),
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

// ---------------------------------------------------------------------------
// Carousel
// ---------------------------------------------------------------------------

/// A row of cards that snaps one at a time, with the next card peeking from
/// the end edge. Each card is announced with its position ("2 of 4").
class FfCarousel extends StatefulWidget {
  const FfCarousel({
    super.key,
    required this.height,
    required this.children,
    this.viewportFraction = FfCarouselTokens.viewportFraction,
    this.onPageChanged,
  });

  final double height;
  final List<Widget> children;
  final double viewportFraction;
  final ValueChanged<int>? onPageChanged;

  @override
  State<FfCarousel> createState() => _FfCarouselState();
}

class _FfCarouselState extends State<FfCarousel> {
  late final PageController _controller = PageController(
    viewportFraction: widget.viewportFraction,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.children.length;
    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _controller,
        padEnds: false,
        itemCount: n,
        onPageChanged: widget.onPageChanged,
        itemBuilder:
            (context, i) => Padding(
              padding: EdgeInsetsDirectional.only(
                start: i == 0 ? FfSpace.pageMargin : FfCarouselTokens.gap / 2,
                end: i == n - 1 ? FfSpace.pageMargin : FfCarouselTokens.gap / 2,
              ),
              child: Semantics(
                label: '${i + 1} of $n',
                container: true,
                child: widget.children[i],
              ),
            ),
      ),
    );
  }
}

class _FfDockFabLocation extends StandardFabLocation with FabEndOffsetX {
  const _FfDockFabLocation();

  @override
  double getOffsetY(
    ScaffoldPrelayoutGeometry scaffoldGeometry,
    double adjustment,
  ) {
    final double fabHeight = scaffoldGeometry.floatingActionButtonSize.height;
    final double dockClearance =
        FfDockTokens.height +
        FfDockTokens.bottomMargin +
        scaffoldGeometry.minViewPadding.bottom +
        FfSpace.md;
    double fabY =
        scaffoldGeometry.scaffoldSize.height - dockClearance - fabHeight;
    final double snackBarHeight = scaffoldGeometry.snackBarSize.height;
    if (snackBarHeight > 0.0) {
      fabY = math.min(
        fabY,
        scaffoldGeometry.scaffoldSize.height -
            snackBarHeight -
            fabHeight -
            kFloatingActionButtonMargin,
      );
    }
    return fabY + adjustment;
  }

  @override
  String toString() => 'FfDock.fabLocation';
}
