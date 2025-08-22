
import 'dart:math';

import 'package:flutter/material.dart';

class MaterialButtonHelper {
  static BorderRadiusGeometry borderRadiusOf(OutlinedBorder shape) {
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius;
    }
    if (shape is StadiumBorder) {
      return const BorderRadius.all(Radius.circular(9999));
    }
    if (shape is ContinuousRectangleBorder) {
      return shape.borderRadius;
    }
    return BorderRadius.zero;
  }

  static double fillButtonOpacityWithStates(Set<WidgetState> states) {
    final opacityMap = {
      WidgetState.pressed: 0.7,
      WidgetState.hovered: 0.08,
      WidgetState.focused: 0.1,
    };
    double layerOpacity = states.isEmpty ? 1.0: 0.0;
    for (final s in states) {
      layerOpacity = max(layerOpacity, opacityMap[s] ?? 1.0);
    }
    return layerOpacity;
  }
}