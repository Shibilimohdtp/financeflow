import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/ff.dart';
import 'ff_round_buttons.dart';

/// The canonical non-sticky top header for FinanceFlow's primary tab screens.
///
/// Follows Stillwater Bloom:
/// - Clean typography: Title in [FfTypography.headline], Subtitle in [FfTypography.label]
/// - No visual shield clutter: No on-device icons taking up header space
/// - Standardized action buttons: Uses [FfCircleButton] with uniform 8 dp spacing
/// - Smooth animated transitions for integrated dynamic search and multi-select modes
class FfPageHeader extends StatelessWidget {
  const FfPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.titleStyle,
    this.titleWidget,
    this.onBack,
    this.actions,
    this.isSearchOpen = false,
    this.searchController,
    this.searchFocusNode,
    this.searchHint = 'Search…',
    this.onSearchChanged,
    this.onSearchClear,
    this.onCloseSearch,
    this.selecting = false,
    this.selectedCount = 0,
    this.onCancelSelection,
    this.selectionActions,
    this.padding,
    this.backgroundColor,
  });

  final String title;
  final String? subtitle;
  final TextStyle? titleStyle;
  final Widget? titleWidget;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  // Search mode properties
  final bool isSearchOpen;
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;
  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchClear;
  final VoidCallback? onCloseSearch;

  // Selection mode properties
  final bool selecting;
  final int selectedCount;
  final VoidCallback? onCancelSelection;
  final List<Widget>? selectionActions;

  final EdgeInsetsDirectional? padding;
  final Color? backgroundColor;

  static const double contentHeight = FfTouch.minTarget; // 48 dp
  static const double topPadding = FfSpace.xs; // 4 dp
  static const double bottomPadding = FfSpace.x2s; // 8 dp
  static const double totalHeight =
      contentHeight + topPadding + bottomPadding; // 60 dp

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultPadding = EdgeInsetsDirectional.only(
      start: FfSpace.pageMargin,
      end:
          FfSpace.pageMargin -
          (FfTouch.minTarget - FfRoundButtonTokens.size) / 2,
      top: topPadding,
      bottom: bottomPadding,
    );

    Widget content = Container(
      color: backgroundColor ?? Colors.transparent,
      padding: padding ?? defaultPadding,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: contentHeight),
        child: AnimatedSwitcher(
          duration: FfMotion.fast,
          child:
              selecting
                  ? _buildSelection(context, ff)
                  : isSearchOpen
                  ? _buildSearch(context, ff)
                  : _buildNormal(context, ff),
        ),
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: content,
    );
  }

  Widget _buildNormal(BuildContext context, FfThemeData ff) {
    return Row(
      key: const ValueKey('ff_page_header_normal'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (onBack != null) ...[
          FfCircleButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Back',
            soft: true,
            onPressed: onBack,
          ),
          const SizedBox(width: FfSpace.xs),
        ],
        Expanded(
          child:
              titleWidget ??
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style:
                        titleStyle ??
                        ff.text.headline.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: FfSpace.x3s),
                    Text(
                      subtitle!,
                      style: ff.text.label.copyWith(
                        color: ff.color.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
        ),
        if (actions != null && actions!.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < actions!.length; i++) ...[
                if (i > 0) const SizedBox(width: FfSpace.x2s),
                actions![i],
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildSearch(BuildContext context, FfThemeData ff) {
    final controller = searchController;
    return Row(
      key: const ValueKey('ff_page_header_search'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FfCircleButton(
          icon: Icons.arrow_back_rounded,
          tooltip: 'Close search',
          soft: true,
          onPressed: onCloseSearch,
        ),
        const SizedBox(width: FfSpace.xs),
        Expanded(
          child: Container(
            height: FfRoundButtonTokens.size,
            decoration: ShapeDecoration(
              color: ff.color.surfaceCard.withValues(alpha: FfOpacity.high),
              shape: FfShape.of(
                FfRadius.full,
                side: BorderSide(
                  color: ff.color.borderSubtle,
                  width: FfBorderWidth.hairline,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: FfSpace.md),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: FfIconSize.md,
                  color: ff.color.textSecondary,
                ),
                const SizedBox(width: FfSpace.xs),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: searchFocusNode,
                    textInputAction: TextInputAction.search,
                    style: ff.text.body,
                    decoration: InputDecoration(
                      hintText: searchHint,
                      hintStyle: ff.text.body.copyWith(
                        color: ff.color.textTertiary,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: onSearchChanged,
                  ),
                ),
                if (controller != null)
                  ListenableBuilder(
                    listenable: controller,
                    builder:
                        (context, _) =>
                            controller.text.isEmpty
                                ? const SizedBox.shrink()
                                : IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  tooltip: 'Clear search text',
                                  iconSize: FfIconSize.md,
                                  visualDensity: VisualDensity.compact,
                                  onPressed:
                                      onSearchClear ?? () => controller.clear(),
                                ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelection(BuildContext context, FfThemeData ff) {
    return Row(
      key: const ValueKey('ff_page_header_selection'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FfCircleButton(
          icon: Icons.close_rounded,
          tooltip: 'Cancel selection',
          soft: true,
          onPressed: onCancelSelection,
        ),
        const SizedBox(width: FfSpace.sm),
        Expanded(
          child: Text(
            '$selectedCount selected',
            style: ff.text.titleLg,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (selectionActions != null) ...selectionActions!,
      ],
    );
  }
}

/// A [SliverPersistentHeaderDelegate] wrapper for [FfPageHeader] to allow
/// non-sticky or dynamic pinning inside a [CustomScrollView].
class FfPageHeaderSliverDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  final bool isPinned;
  final Color? backgroundColor;

  FfPageHeaderSliverDelegate({
    required this.child,
    required this.height,
    this.isPinned = false,
    this.backgroundColor,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final ff = context.ff;
    final showBackdrop = isPinned && (shrinkOffset > 0 || overlapsContent);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color:
            showBackdrop
                ? (backgroundColor ??
                    ff.color.surfacePage.withValues(alpha: 0.94))
                : Colors.transparent,
        border:
            showBackdrop
                ? Border(
                  bottom: BorderSide(
                    color: ff.color.borderSubtle,
                    width: FfBorderWidth.hairline,
                  ),
                )
                : null,
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant FfPageHeaderSliverDelegate oldDelegate) {
    return oldDelegate.height != height ||
        oldDelegate.isPinned != isPinned ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.child != child;
  }
}
