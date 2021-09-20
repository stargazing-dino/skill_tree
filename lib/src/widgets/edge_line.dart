import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:skill_tree/src/models/skill_parent_data.dart';
import 'package:skill_tree/src/skill_tree.dart';
import 'package:skill_tree/src/utils/get_parent_data_of_type.dart';
import 'package:skill_tree/src/utils/get_parent_of_type.dart';
import 'package:skill_tree/src/utils/path_intersects_rect.dart';
import 'package:skill_tree/src/widgets/skill_vertex.dart';

typedef EdgePainter = void Function({
  required Offset toNodeCenter,
  required Offset fromNodeCenter,
  required List<Rect> allNodeRects,
  required List<Rect> intersectingNodeRects,
  required Canvas canvas,
});

class EdgeLine<EdgeType, NodeType, IdType extends Object>
    extends MultiChildRenderObjectWidget {
  EdgeLine({
    Key? key,
    // TODO: In the future, I'd like these to be optional
    required SkillVertexTo toVertex,
    required SkillVertexFrom fromVertex,
    required this.edgePainter,
  }) : super(key: key, children: [toVertex, fromVertex]);

  final EdgePainter edgePainter;

  @override
  RenderBox createRenderObject(BuildContext context) {
    return RenderDraggableEdge<EdgeType, NodeType, IdType>(
      edgePainter: edgePainter,
    );
  }
}

/// The fields of this [RenderObject] are initialized in the layout phase.
/// This is because we must first know the size of the node widgets.
class RenderDraggableEdge<EdgeType, NodeType, IdType extends Object>
    extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SkillVertexParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SkillVertexParentData>,
        DebugOverflowIndicatorMixin {
  RenderDraggableEdge({
    required EdgePainter edgePainter,
  }) : _edgePainter = edgePainter;

  EdgePainter _edgePainter;
  EdgePainter get edgePainter => _edgePainter;
  set edgePainter(EdgePainter edgePainter) {
    if (_edgePainter == edgePainter) return;
    _edgePainter = edgePainter;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! SkillVertexParentData) {
      child.parentData = SkillVertexParentData();
    }
  }

  Offset? fromCenter;

  Offset? toCenter;

  @override
  void performLayout() {
    final children = getChildrenAsList();
    final toChild = children.singleWhere((child) {
      return child.parentData is SkillVertexToParentData;
    });
    final fromChild = children.singleWhere((child) {
      return child.parentData is SkillVertexFromParentData;
    });
    final toChildParentData = toChild.parentData as SkillVertexToParentData;
    final fromChildParentData =
        fromChild.parentData as SkillVertexFromParentData;
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
    final _fromCenter = fromCenter! + offset;
    final _toCenter = toCenter! + offset;

    final firstChild = getChildrenAsList().first;
    final skillTreeParent =
        getParentOfType<RenderSkillTree<EdgeType, NodeType, IdType>>(
      firstChild,
    );
    if (skillTreeParent == null) {
      throw StateError(
        'skillTreeParent is null. Are you sure there is a RenderSkillTree above'
        'this EdgeLine?',
      );
    }
    final skillEdgeParentData =
        getParentDataOfType<SkillEdgeParentData<EdgeType, NodeType, IdType>>(
      firstChild,
    );

    final straightLinePath = Path()
      ..moveTo(_fromCenter.dx, _fromCenter.dy)
      ..lineTo(_toCenter.dx + 1, _toCenter.dy)
      ..lineTo(_toCenter.dx, _toCenter.dy)
      ..close();

    final intersectingNodeRects = <Rect>[];
    final allNodeRects = <Rect>[];
    final constraintsRect = offset & constraints.biggest;

    for (final nodeBox in skillTreeParent.nodeChildren) {
      final nodeParentData =
          nodeBox.parentData as SkillNodeParentData<NodeType, IdType>;

      if (nodeParentData.id == skillEdgeParentData!.to! ||
          nodeParentData.id == skillEdgeParentData.from!) {
        continue;
      }

      final nodeRect =
          (nodeParentData.offset + skillTreeParent.paintOffset! & nodeBox.size);

      allNodeRects.add(nodeRect);

      if (constraintsRect.overlaps(nodeRect)) {
        if (pathIntersectsRect(straightLinePath, nodeRect)) {
          intersectingNodeRects.add(nodeRect);
        }
      }
    }

    edgePainter(
      toNodeCenter: _toCenter,
      fromNodeCenter: _fromCenter,
      intersectingNodeRects: intersectingNodeRects,
      canvas: context.canvas,
      allNodeRects: allNodeRects,
    );

    /// Draw the vertices
    defaultPaint(context, offset);
  }
}
