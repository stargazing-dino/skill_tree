import 'package:flutter/rendering.dart';

/// A check to see if a path intersects a given rectangle.
bool pathIntersectsRect(Path path, Rect rect) {
  final rectPath = Path()..addRect(rect);
  final intersectionPath = Path.combine(
    PathOperation.intersect,
    path,
    rectPath,
  );

  if (intersectionPath.computeMetrics().any((metric) => metric.length > 0)) {
    return true;
  }

  return false;
}
