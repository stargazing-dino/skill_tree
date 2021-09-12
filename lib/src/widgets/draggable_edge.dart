import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:skill_tree/src/widgets/draggable_point.dart';
import 'package:skill_tree/src/widgets/skill_node.dart';

class PointParentData<NodeType extends Object, IdType extends Object>
    extends ContainerBoxParentData<RenderBox> {
  void addPositionData({
    required SkillNode<NodeType, IdType> node,
    required Rect rect,
  }) {
    this.node = node;
    this.rect = rect;
  }

  /// In case of an advanced layout, you can query this node to perform
  /// additional layout logic.
  ///
  /// This is initialized late
  SkillNode<NodeType, IdType>? node;

  /// This is the rect of the node. The point should position and
  /// itself based off of this.
  ///
  /// This is initialized late
  Rect? rect;

  bool? isTo;

  // TODO:
  // Axis? preferredAxis;
}

class DraggableEdge<NodeType extends Object, IdType extends Object>
    extends MultiChildRenderObjectWidget {
  DraggableEdge({
    Key? key,
    required DraggablePoint toPoint,
    required DraggablePoint fromPoint,
  }) : super(key: key, children: [toPoint, fromPoint]);

  @override
  RenderBox createRenderObject(BuildContext context) {
    return RenderDraggableEdge<NodeType, IdType>();
  }
}

/// The fields of this [RenderObject] are initialized in the layout phase.
/// This is because we must first know the size of the node widgets.
class RenderDraggableEdge<NodeType extends Object, IdType extends Object>
    extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox,
            PointParentData<NodeType, IdType>>,
        RenderBoxContainerDefaultsMixin<RenderBox,
            PointParentData<NodeType, IdType>>,
        DebugOverflowIndicatorMixin {
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! PointParentData<NodeType, IdType>) {
      child.parentData = PointParentData<NodeType, IdType>();
    }
  }

  Offset? fromCenter;

  Offset? toCenter;

  @override
  void performLayout() {
    final children = getChildrenAsList();
    final toChild = children.singleWhere((child) {
      final parentData = child.parentData as PointParentData<NodeType, IdType>;

      return parentData.isTo!;
    });
    final fromChild = children.singleWhere((child) {
      final parentData = child.parentData as PointParentData<NodeType, IdType>;

      return !parentData.isTo!;
    });
    final toChildParentData =
        toChild.parentData as PointParentData<NodeType, IdType>;
    final fromChildParentData =
        fromChild.parentData as PointParentData<NodeType, IdType>;
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
  void paint(PaintingContext context, Offset offset) {
    /// Draw the lines between the points
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3;

    context.canvas.save();

    context.canvas.translate(offset.dx, offset.dy);

    // final path = Path()
    //   ..moveTo(fromCenter!.dx, fromCenter!.dy)
    //   ..lineTo(toCenter!.dx, toCenter!.dy);
    // // ..quadraticBezierTo(x1, y1, toCenter!.dx, toCenter!.dy);

    // context.canvas.drawPath(path, paint);

    context.canvas.drawLine(fromCenter!, toCenter!, paint);

    context.canvas.restore();

    /// Draw the points
    defaultPaint(context, offset);
  }
}
