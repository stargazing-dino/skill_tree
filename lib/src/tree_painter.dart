import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skill_tree/skill_tree.dart';
import 'package:skill_tree/src/models/base_node.dart';

import 'models/parent_children.dart';

class TreePainter<T extends Object, R extends Object> extends CustomPainter {
  final List<BaseNode<T>> nodes;

  final BuildContext context;

  final Paint brush;

  TreePainter({required this.context, required this.nodes})
      : brush = Paint()
          ..strokeWidth = 4
          ..color = Colors.white
          ..style = PaintingStyle.stroke;

  // TODO: Move into utils and make generic
  Iterable<ParentChildren<BaseNode<T>>> traverseByLineage(
    BaseNode<T> node,
  ) sync* {
    if (node.children.isNotEmpty) {
      yield ParentChildren(parent: node, children: node.children);

      for (final childNode in node.children) {
        yield* traverseByLineage(childNode);
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: Move to field
    // TODO: Lines should be differently colored if the node their going to is
    // unlocked
    final lineType = LineType.angle;

    final relativePosition = context.findRenderObject() as RenderBox?;

    if (relativePosition == null) return;

    final startPoint = relativePosition.globalToLocal(Offset.zero);

    for (final rootNode in nodes) {
      for (final parentChildren in traverseByLineage(rootNode)) {
        final parentRenderBox = parentChildren.parent.globalKey.currentContext
            ?.findRenderObject() as RenderBox?;

        if (parentRenderBox == null) break;

        for (final child in parentChildren.children) {
          final childRenderBox =
              child.globalKey.currentContext?.findRenderObject() as RenderBox?;

          if (childRenderBox == null) continue;

          final parentPosition = parentRenderBox.localToGlobal(startPoint);
          final childPosition = childRenderBox.localToGlobal(startPoint);
          final bottomOfParent = parentPosition.translate(
            parentRenderBox.size.width / 2,
            parentRenderBox.size.height,
          );
          final topOfChild =
              childPosition.translate(childRenderBox.size.width / 2, 0);

          final verticalDx = topOfChild.dy - bottomOfParent.dy;
          final verticalHalfDx = verticalDx / 2;
          final horizontalDx = topOfChild.dx - bottomOfParent.dx;
          final horizontalHalfDx = horizontalDx / 2;

          switch (lineType) {
            case LineType.angle:
              final path = Path();

              path.moveTo(bottomOfParent.dx, bottomOfParent.dy);
              path.relativeLineTo(0, verticalHalfDx);
              path.relativeLineTo(horizontalDx, 0);
              path.relativeLineTo(0, verticalHalfDx);

              canvas.drawPath(path, brush);
              break;
            case LineType.curved:
              // TODO: This is whack. We should research how to do this
              // correctly
              final path = Path();
              final multiplier = 7;

              path.moveTo(bottomOfParent.dx, bottomOfParent.dy);
              path.relativeArcToPoint(
                Offset(horizontalHalfDx, verticalHalfDx),
                radius: Radius.circular(verticalHalfDx * multiplier),
                clockwise: horizontalHalfDx.isNegative,
              );
              path.relativeArcToPoint(
                Offset(horizontalHalfDx, verticalHalfDx),
                radius: Radius.circular(verticalHalfDx * multiplier),
                clockwise: !horizontalHalfDx.isNegative,
              );

              canvas.drawPath(path, brush);

              break;
            case LineType.straight:
              canvas.drawLine(
                bottomOfParent,
                topOfChild,
                brush,
              );

              break;
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(TreePainter<T, R> oldDelegate) {
    return !listEquals(oldDelegate.nodes, nodes);
  }
}
