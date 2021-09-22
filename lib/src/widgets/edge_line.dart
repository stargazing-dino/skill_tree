import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:skill_tree/src/models/skill_parent_data.dart';
import 'package:skill_tree/src/skill_tree.dart';
import 'package:skill_tree/src/utils/get_parent_data_of_type.dart';
import 'package:skill_tree/src/utils/get_parent_of_type.dart';
import 'package:skill_tree/src/widgets/skill_vertex.dart';

typedef EdgePainter = void Function({
  required Offset toNodeCenter,
  required Offset fromNodeCenter,
  required List<Rect> allNodeRects,
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

    // TODO: Provide proper constraints spacing with this same idea... maybe

    final _toAlignment = toChildParentData.alignment ?? Alignment.center;
    final _fromAlignment = fromChildParentData.alignment ?? Alignment.center;

    /// Specify in a 2d space where the "to" Node is relative to the "from"
    /// node. (This will be used to orient the edge line and better draw
    /// the vertex).
    ///
    /// We get a vector moving from "from" to "to" and get the direction of the
    /// vector.
    final angle =
        (_toAlignment.withinRect(fromRect) - _fromAlignment.withinRect(toRect))
            .direction;

    final toAlignment =
        (toChildParentData.alignment ?? getAlignmentForAngle(angle));
    final fromAlignment = fromChildParentData.alignment ?? (toAlignment * -1);

    final loosenedConstraints = constraints.loosen();
    final fromChildSize = fromChild.getDryLayout(loosenedConstraints);
    final toChildSize = toChild.getDryLayout(loosenedConstraints);

    fromChild.layout(
      loosenedConstraints.tighten(
        width: fromChildSize.width,
        height: fromChildSize.height,
      ),
    );

    toChild.layout(
      loosenedConstraints.tighten(
        width: toChildSize.width,
        height: toChildSize.height,
      ),
    );

    fromChildParentData.offset = fromAlignment.withinRect(fromRect);
    toChildParentData.offset = toAlignment.withinRect(toRect);

    fromCenter = (fromChildParentData.offset & fromChildSize).center;
    toCenter = (toChildParentData.offset & toChildSize).center;

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

    final allNodeRects = <Rect>[];

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
    }

    edgePainter(
      toNodeCenter: _toCenter,
      fromNodeCenter: _fromCenter,
      canvas: context.canvas,
      allNodeRects: allNodeRects,
    );

    /// Draw the vertices
    defaultPaint(context, offset);
  }
}

/// As
Alignment shiftAlignment(Alignment alignment) {
  final topLeftAlignment = Alignment.topLeft;

  if (alignment.x > 0) {
    return alignment + topLeftAlignment;
  } else if (alignment.x < 1) {
    return alignment + topLeftAlignment;
  }

  return alignment;
}

/// This goes clockwise starting at 0
///
///  -pi 3/4                   -pi/2                  -pi 1/4
///
///                               |
///                     -x -y     |    +x -y
///                               |
///  (+/-)pi         ---------------------------            0
///                               |
///                     -x +y     |    +x +y
///                               |
///
///  pi 3/4                     pi/2                   pi 1/4
///
Alignment getAlignmentForAngle(double angle) {
  // TODO: We should provide more arguments here to better define how we want
  // the alignment to come out.

  // Handle the corners
  // if (angle == -math.pi / 4) {
  //   return Alignment.topRight;
  // } else if (angle == -math.pi * 3 / 4) {
  //   return Alignment.topLeft;
  // } else if (angle == math.pi * 3 / 4) {
  //   return Alignment.bottomLeft;
  // } else if (angle == math.pi / 4) {
  //   return Alignment.bottomRight;
  // }

  // If we're between -pi 1/4 and pi 1/4 we're going right
  if (angle.abs() < math.pi / 4) {
    return Alignment.centerRight;
  }

  // If we're between -pi 3/4 and -pi 1/4 we're going up
  else if (angle > -math.pi * 3 / 4 && angle < -math.pi / 4) {
    return Alignment.topCenter;
  }

  // We're going left between -pi 3/4 and pi 3/4
  else if (angle.abs() > math.pi * 3 / 4) {
    return Alignment.centerLeft;
  }

  // We're going down
  else {
    return Alignment.bottomCenter;
  }
}
