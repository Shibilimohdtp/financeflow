import 'package:flutter/material.dart';

import '../../theme/ff.dart';

/// The top bar of every screen. Use [FfAppBar] for a titled screen,
/// [FfAppBar.search] while searching and [FfAppBar.selection] while items
/// are selected.
///
/// Titles are single-line and ellipsize; the style comes from the theme. On
/// screens without a back or close button the title lines up with the page
/// margin so it sits on the same edge as the content below.
class FfAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FfAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.titleWidget,
    this.leading,
    this.actions,
    this.bottom,
  }) : _searchController = null,
       _searchFocusNode = null,
       _searchHint = null,
       _onSearchChanged = null,
       _onSearchClear = null;

  /// Search mode: a back button that closes search, the search field in the
  /// title slot, and a clear button once there is text.
  FfAppBar.search({
    super.key,
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
    required VoidCallback onClose,
    VoidCallback? onClear,
    FocusNode? focusNode,
  }) : title = null,
       subtitle = null,
       titleWidget = null,
       leading = IconButton(
         icon: const Icon(Icons.arrow_back_rounded),
         tooltip: 'Close search',
         onPressed: onClose,
       ),
       actions = null,
       bottom = null,
       _searchController = controller,
       _searchFocusNode = focusNode,
       _searchHint = hint,
       _onSearchChanged = onChanged,
       _onSearchClear = onClear;

  /// Selection mode: a close button that cancels the selection, the count
  /// as the title, and bulk actions.
  FfAppBar.selection({
    super.key,
    required int count,
    required VoidCallback onCancel,
    this.actions,
  }) : title = '$count selected',
       subtitle = null,
       titleWidget = null,
       leading = IconButton(
         icon: const Icon(Icons.close_rounded),
         tooltip: 'Cancel selection',
         onPressed: onCancel,
       ),
       bottom = null,
       _searchController = null,
       _searchFocusNode = null,
       _searchHint = null,
       _onSearchChanged = null,
       _onSearchClear = null;

  final String? title;

  /// A second, smaller line under [title] (for example a lender's name).
  final String? subtitle;

  /// Replaces the text title for headers that need their own layout.
  /// Prefer [title] and [subtitle].
  final Widget? titleWidget;

  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  final TextEditingController? _searchController;
  final FocusNode? _searchFocusNode;
  final String? _searchHint;
  final ValueChanged<String>? _onSearchChanged;
  final VoidCallback? _onSearchClear;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final hasLeading =
        leading != null ||
        (ModalRoute.of(context)?.impliesAppBarDismissal ?? false);

    return AppBar(
      leading: leading,
      titleSpacing:
          hasLeading ? NavigationToolbar.kMiddleSpacing : FfSpace.pageMargin,
      title: _buildTitle(ff),
      actions: _searchController == null ? actions : [_clearAction()],
      bottom: bottom,
    );
  }

  Widget? _buildTitle(FfThemeData ff) {
    final controller = _searchController;
    if (controller != null) {
      return TextField(
        controller: controller,
        focusNode: _searchFocusNode,
        autofocus: _searchFocusNode == null,
        textInputAction: TextInputAction.search,
        style: ff.text.bodyLg,
        decoration: InputDecoration(
          hintText: _searchHint,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: _onSearchChanged,
      );
    }
    if (titleWidget != null) return titleWidget;
    if (title == null) return null;
    if (subtitle == null || subtitle!.isEmpty) {
      return Text(title!, maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title!,
          style: ff.text.titleLg,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          subtitle!,
          style: ff.text.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _clearAction() {
    final controller = _searchController!;
    return ListenableBuilder(
      listenable: controller,
      builder:
          (context, _) =>
              controller.text.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    tooltip: 'Clear search text',
                    onPressed: () {
                      controller.clear();
                      (_onSearchClear ?? () => _onSearchChanged?.call(''))();
                    },
                  ),
    );
  }
}
