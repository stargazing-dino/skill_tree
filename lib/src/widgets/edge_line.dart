import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:skill_tree/src/models/skill_parent_data.dart';
import 'package:skill_tree/src/utils/get_parent_data_of_type.dart';
import 'package:skill_tree/src/widgets/skill_vertex.dart';

class VertexParentData extends ContainerBoxParentData<RenderBox> {
  void addPositionData(Rect rect) {
    this.rect = rect;
  }

  /// This is the rect of the node. The vertex should position and
  /// itself based off of this.
  ///
  /// This is initialized late
  Rect? rect;

  bool? isTo;

  // TODO:
  // Axis? preferredAxis;
}

class EdgeLine<EdgeType, NodeType, IdType extends Object>
    extends MultiChildRenderObjectWidget {
  EdgeLine({
    Key? key,
    required SkillVertex toVertex,
    required SkillVertex fromVertex,
  }) : super(key: key, children: [toVertex, fromVertex]);

  @override
  RenderBox createRenderObject(BuildContext context) {
    return RenderDraggableEdge<EdgeType, NodeType, IdType>();
  }
}

/// The fields of this [RenderObject] are initialized in the layout phase.
/// This is because we must first know the size of the node widgets.
class RenderDraggableEdge<EdgeType, NodeType, IdType extends Object>
    extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, VertexParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, VertexParentData>,
        DebugOverflowIndicatorMixin {
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! VertexParentData) {
      child.parentData = VertexParentData();
    }
  }

  Offset? fromCenter;

  Offset? toCenter;

  @override
  void performLayout() {
    final children = getChildrenAsList();
    final toChild = children.singleWhere((child) {
      final parentData = child.parentData as VertexParentData;

      return parentData.isTo!;
    });
    final fromChild = children.singleWhere((child) {
      final parentData = child.parentData as VertexParentData;

      return !parentData.isTo!;
    });
    final toChildParentData = toChild.parentData as VertexParentData;
    final fromChildParentData = fromChild.parentData as VertexParentData;
    final toRect = toChildParentData.rect!;
    final fromRect = fromChildParentData.rect!;

    // Specifies which way the the edge is pointing. For example, if the
    // axisDirection is AxisDirection.right, then the edge is pointing to the
    // right.
    final AxisDirection axisDirection;

    // TODO: Revisit this. I'm not sure what's pointing where
    if (toRect.left > fromRect.right) {
      axisDirection = AxisDirection.right;
    } else if (toRect.right < fromRect.left) {
      axisDirection = AxisDirection.left;
    } else if (toRect.bottom < fromRect.top) {
      axisDirection = AxisDirection.down;
    } else if (toRect.top > fromRect.bottom) {
      axisDirection = AxisDirection.up;
    } else {
      throw Exception('Unable to determine axis');
    }

    final axis = axisDirectionToAxis(axisDirection);

    final loosenedConstraints = constraints.loosen();

    switch (axis) {
      case Axis.horizontal:
        {
          final widthBetween =
              constraints.maxWidth - toRect.width - fromRect.width;
          final widthAvailable = widthBetween / 2;

          // from Layout
          final fromConstraints =
              loosenedConstraints.copyWith(maxWidth: widthAvailable);
          final fromChildSize = fromChild.getDryLayout(fromConstraints);

          fromChild.layout(
            fromConstraints.tighten(
              width: fromChildSize.width,
              height: fromChildSize.height,
            ),
          );

          // to Layout
          final toConstraints =
              loosenedConstraints.copyWith(maxWidth: widthAvailable);
          final toChildSize = toChild.getDryLayout(toConstraints);

          toChild.layout(
            toConstraints.tighten(
              width: toChildSize.width,
              height: toChildSize.height,
            ),
          );

          if (axisDirection == AxisDirection.left) {
            fromChildParentData.offset = fromRect.centerLeft.translate(
              -fromChildSize.width,
              -fromChildSize.height / 2,
            );

            toChildParentData.offset = toRect.centerRight.translate(
              0,
              -toChildSize.height / 2,
            );
          } else {
            // axisDirection == right
            fromChildParentData.offset = fromRect.centerRight.translate(
              0,
              -fromChildSize.height / 2,
            );

            toChildParentData.offset = toRect.centerLeft.translate(
              -toChildSize.width,
              -toChildSize.height / 2,
            );
          }

          fromCenter = (fromChildParentData.offset & fromChildSize).center;
          toCenter = (toChildParentData.offset & toChildSize).center;

          break;
        }
      case Axis.vertical:
        {
          final heightBetween =
              constraints.maxHeight - toRect.height - fromRect.height;
          final heightAvailable = heightBetween / 2;

          // from Layout
          final fromConstraints =
              loosenedConstraints.copyWith(maxHeight: heightAvailable);
          final fromChildSize = fromChild.getDryLayout(fromConstraints);

          fromChild.layout(
            fromConstraints.tighten(
              width: fromChildSize.width,
              height: fromChildSize.height,
            ),
          );

          // to Layout
          final toConstraints =
              loosenedConstraints.copyWith(maxHeight: heightAvailable);
          final toChildSize = toChild.getDryLayout(toConstraints);

          toChild.layout(
            toConstraints.tighten(
              width: toChildSize.width,
              height: toChildSize.height,
            ),
          );

          if (axisDirection == AxisDirection.up) {
            fromChildParentData.offset = fromRect.bottomCenter.translate(
              -fromChildSize.width / 2,
              0,
            );

            toChildParentData.offset = toRect.topCenter.translate(
              -toChildSize.width / 2,
              -toChildSize.height,
            );
          } else {
            fromChildParentData.offset = fromRect.topCenter.translate(
              -fromChildSize.width / 2,
              -fromChildSize.height,
            );

            toChildParentData.offset = toRect.bottomCenter.translate(
              -toChildSize.width / 2,
              0,
            );
          }

          fromCenter = (fromChildParentData.offset & fromChildSize).center;
          toCenter = (toChildParentData.offset & toChildSize).center;

          break;
        }
    }

    size = constraints.biggest;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final firstChild = getChildrenAsList().first;
    final skillEdgeParentData =
        getParentDataOfType<SkillEdgeParentData<EdgeType, NodeType, IdType>>(
      firstChild,
    );
    if (skillEdgeParentData == null) {
      throw StateError(
        'SkillEdgeParentData is null. Are you sure there is a SkillEdge above'
        'this EdgeLine?',
      );
    }

    final nodePositions = skillEdgeParentData.nodePositions;
    // TODO: Properly layout the edge with the knowledge of where the nodes are

    /// Draw the lines between the points
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    context.canvas.save();

    context.canvas.translate(offset.dx, offset.dy);

    // TODO: An edge needs to know the layout of the graph in order to correctly
    // avoid the nodes in its path from vertex to vertex.
    // final getNodesInPath =

    final path = Path()
      ..moveTo(fromCenter!.dx, fromCenter!.dy)
      ..lineTo(toCenter!.dx, toCenter!.dy);
    // ..quadraticBezierTo(
    //   toCenter!.dx - 20,
    //   toCenter!.dy + 20,
    //   toCenter!.dx,
    //   toCenter!.dy,
    // );

    context.canvas.drawPath(path, paint);

    context.canvas.restore();

    /// Draw the vertices
    defaultPaint(context, offset);
  }
}
