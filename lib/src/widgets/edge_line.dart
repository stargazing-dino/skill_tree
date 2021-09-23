import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:skill_tree/src/skill_edge.dart';
import 'package:skill_tree/src/skill_node.dart';
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
    // TODO: Control points ... This should be able to be a list of
    // [SkillVertex] or control points.
    required SkillVertexTo toVertex,
    required SkillVertexFrom fromVertex,
    required this.edgePainter,
  }) : super(key: key, children: [toVertex, fromVertex]);

  final EdgePainter edgePainter;

  @override
  RenderBox createRenderObject(BuildContext context) {
    return RenderEdgeLine<EdgeType, NodeType, IdType>(
      edgePainter: edgePainter,
    );
  }
}

/// The fields of this [RenderObject] are initialized in the layout phase.
/// This is because we must first know the size of the node widgets.
class RenderEdgeLine<EdgeType, NodeType, IdType extends Object>
    extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SkillVertexParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SkillVertexParentData>,
        DebugOverflowIndicatorMixin {
  RenderEdgeLine({
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

    // TODO: Provide proper constraints spacing with this same idea... maybe
    final loosenedConstraints = constraints.loosen();
    final fromChildRect = fromChildParentData.rect!;
    final fromChildSize = fromChildRect.size;
    final toChildRect = toChildParentData.rect!;
    final toChildSize = toChildRect.size;

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

    toChildParentData.offset = Offset(
      toChildRect.left,
      toChildRect.top,
    );
    fromChildParentData.offset = Offset(
      fromChildRect.left,
      fromChildRect.top,
    );

    size = fromChildRect.expandToInclude(toChildRect).size;
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
    final children = getChildrenAsList();
    final toChildParentData = children.singleWhere((child) {
      return child.parentData is SkillVertexToParentData;
    }).parentData as SkillVertexToParentData;
    final fromChildParentData = children.singleWhere((child) {
      return child.parentData is SkillVertexFromParentData;
    }).parentData as SkillVertexFromParentData;
    final _fromCenter = fromChildParentData.rect!.center + offset;
    final _toCenter = toChildParentData.rect!.center + offset;

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

      final nodeRect = (nodeParentData.offset & nodeBox.size);

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
