import 'package:flutter/material.dart';

/// The most basic edge painter that simply draws a line between two points.
void defaultEdgePainter({
  required Offset toNodeCenter,
  required Offset fromNodeCenter,
  required List<Rect> allNodeRects,
  required Canvas canvas,
}) {
  final paint = Paint()
    ..color = Colors.grey
    ..strokeWidth = 10
    ..style = PaintingStyle.stroke;

  final path = Path()
    ..moveTo(fromNodeCenter.dx, fromNodeCenter.dy)
    ..lineTo(toNodeCenter.dx, toNodeCenter.dy);

  canvas.drawPath(path, paint);
  canvas.drawShadow(
    path,
    Colors.grey,
    4,
    false,
  );
}
