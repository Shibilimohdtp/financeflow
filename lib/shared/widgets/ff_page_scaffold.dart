import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import 'ff_round_buttons.dart';
import 'ff_surfaces.dart';

/// A pushed screen whose app bar scrolls away with its content.
///
/// The bar is not sticky (it never pins or floats) and it sits on the same
/// surface as the body, so the title area and the page read as one connected
/// piece. Use it for every sub-screen (for example the More tab's screens)
/// instead of `Scaffold(appBar: FfAppBar(…))`.
///
/// Pass [children] for a plain list, or [slivers] when the body needs its own
/// sliver layout. [onAurora] puts the page on the aurora backdrop, as the
/// hero-style screens do; the bar then stays transparent over it.
class FfPageScaffold extends StatelessWidget {
  const FfPageScaffold({
    super.key,
    this.title,
    this.subtitle,
    this.titleWidget,
    this.leading,
    this.actions,
    this.onAurora = false,
    this.padding = const EdgeInsets.fromLTRB(
      FfSpace.pageMargin,
      FfSpace.xs,
      FfSpace.pageMargin,
      FfSpace.x4l,
    ),
    this.children = const [],
    this.slivers,
    this.body,
    this.floatingActionButton,
  });

  final String? title;
  final String? subtitle;

  /// Replaces the text title for headers that need their own layout.
  final Widget? titleWidget;

  final Widget? leading;
  final List<Widget>? actions;

  /// Paint the page on [FfAurora] and keep the bar transparent over it.
  final bool onAurora;

  /// Padding around [children]; ignored when [slivers] is given.
  final EdgeInsetsGeometry padding;

  /// Body widgets, laid out in one padded column.
  final List<Widget> children;

  /// A custom sliver body. When given, [children] and [padding] are ignored.
  final List<Widget>? slivers;

  /// An existing scrollable body (a ListView, SingleChildScrollView, …). The
  /// bar becomes the nested header, so it scrolls away with the body. Takes
  /// precedence over [children] and [slivers].
  final Widget? body;

  /// Floating action button, shown above the page as on any Scaffold.
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final barBackground = onAurora ? Colors.transparent : ff.color.surfacePage;
    final canPop = Navigator.canPop(context);
    final header = SliverAppBar(
      pinned: false,
      floating: false,
      snap: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: barBackground,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      leading:
          leading ??
          (canPop
              ? FfCircleButton(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
              )
              : null),
      titleSpacing:
          leading == null && !canPop ? FfSpace.pageMargin : FfSpace.xs,
      title: _buildTitle(ff),
      actions: _buildActions(),
    );

    final Widget scroll;
    if (body != null) {
      scroll = NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [header],
        body: body!,
      );
    } else {
      final sliverBody =
          slivers ??
          [
            SliverPadding(
              padding: padding,
              sliver: SliverList(delegate: SliverChildListDelegate(children)),
            ),
          ];
      scroll = CustomScrollView(slivers: [header, ...sliverBody]);
    }

    final scaffold = Scaffold(
      backgroundColor: barBackground,
      floatingActionButton: floatingActionButton,
      body: scroll,
    );
    return onAurora ? FfAurora(child: scaffold) : scaffold;
  }

  /// Actions sit in one row of round 44 dp buttons, spaced the same everywhere.
  List<Widget>? _buildActions() {
    final items = actions;
    if (items == null || items.isEmpty) return null;
    return [
      Padding(
        padding: const EdgeInsets.only(right: FfSpace.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: FfSpace.x2s),
              items[i],
            ],
          ],
        ),
      ),
    ];
  }

  Widget? _buildTitle(FfThemeData ff) {
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
}
