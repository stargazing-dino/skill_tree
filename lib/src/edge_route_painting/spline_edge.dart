import 'dart:ui';

import 'package:flutter/material.dart';

Path defaultCubicEdgePathBuilder({
  required Offset toNodeCenter,
  required Offset fromNodeCenter,
  required List<Rect> allNodeRects,
  required List<Offset> controlPointCenters,
}) {
  final rect = Rect.fromPoints(toNodeCenter, fromNodeCenter);
  final double xA, yA, xB, yB;

  // a cubic line looks better when it runs along the narrower side
  if (rect.width < rect.height) {
    xA = toNodeCenter.dx;
    yA = lerpDouble(fromNodeCenter.dy, toNodeCenter.dy, 0.25)!;
    xB = fromNodeCenter.dx;
    yB = lerpDouble(fromNodeCenter.dy, toNodeCenter.dy, 0.75)!;
  } else {
    xA = lerpDouble(fromNodeCenter.dx, toNodeCenter.dx, 0.25)!;
    yA = toNodeCenter.dy;
    xB = lerpDouble(fromNodeCenter.dx, toNodeCenter.dx, 0.75)!;
    yB = fromNodeCenter.dy;
  }

  return Path()
    ..moveTo(fromNodeCenter.dx, fromNodeCenter.dy)
    ..cubicTo(xA, yA, xB, yB, toNodeCenter.dx, toNodeCenter.dy);
}

void defaultCubicEdgePathPainter({
  required Path path,
  required Canvas canvas,
}) {
  final paint = Paint()
    ..color = Colors.grey
    ..strokeWidth = 5
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  canvas.drawPath(path, paint);
}
