import 'dart:math';
import 'dart:ui';

Rect getLargestBoundingRect(Rect rect, Rect other) {
  return Rect.fromLTRB(
    min(rect.left, other.left),
    min(rect.top, other.top),
    max(rect.right, other.right),
    max(rect.bottom, other.bottom),
  );
}
