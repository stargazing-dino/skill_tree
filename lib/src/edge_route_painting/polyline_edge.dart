import 'package:flutter/material.dart';

/// The most basic edge painter that returns a line between two points.
Path defaultEdgePathBuilder({
  required Offset toNodeCenter,
  required Offset fromNodeCenter,
  required List<Rect> allNodeRects,
  required List<Offset> controlPointCenters,
}) {
  final path = Path()
    ..moveTo(fromNodeCenter.dx, fromNodeCenter.dy)
    ..lineTo(toNodeCenter.dx, toNodeCenter.dy);

  return path;
}

/// Draws a line with a small shadow between two nodes
void defaultEdgePathPainter({
  required Path path,
  required Canvas canvas,
}) {
  final paint = Paint()
    ..color = Colors.grey
    ..strokeWidth = 6
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  canvas.drawPath(path, paint);
  canvas.drawShadow(path, Colors.grey, 4, false);
}
