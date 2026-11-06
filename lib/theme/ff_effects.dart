import 'package:flutter/widgets.dart';

/// How much visual richness surfaces may use. Grain, blur and glass are
/// expensive on mid-range phones and can distract; [reduced] swaps them for
/// solid surfaces with the same colours, shapes and layout.
enum FfEffects {
  /// Grain on hero cards, blurred glass on the dock and hero pills.
  full,

  /// No blur and no grain. Glass becomes a solid raised surface.
  reduced;

  bool get allowsBlur => this == full;
  bool get allowsGrain => this == full;

  /// The effects level for [context]: reduced when the platform asks for
  /// less motion or more contrast, or when an [FfEffectsScope] above
  /// (the user's setting) says so.
  static FfEffects of(BuildContext context) {
    final scoped = FfEffectsScope.maybeOf(context);
    if (scoped == reduced) return reduced;
    final media = MediaQuery.maybeOf(context);
    if (media != null && (media.disableAnimations || media.highContrast)) {
      return reduced;
    }
    return scoped ?? full;
  }
}

/// Sets the effects level for a subtree, for the user's "Reduce effects"
/// setting or for tests. The platform can still reduce effects further.
class FfEffectsScope extends InheritedWidget {
  const FfEffectsScope({
    super.key,
    required this.effects,
    required super.child,
  });

  final FfEffects effects;

  static FfEffects? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FfEffectsScope>()?.effects;

  @override
  bool updateShouldNotify(FfEffectsScope oldWidget) =>
      effects != oldWidget.effects;
}
