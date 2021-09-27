import 'package:collection/collection.dart';
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
    // TODO: In the future, I'd like these to be optional. The blocking issue is
    // that we set a rect on the SkillVertexParentData and we then use that rect
    // center in the drawEdge. We'd need another way to pass the rect as we'll
    // always need a center despite the wiget child.

    // TODO: Control points ... This should be able to be a list of
    // [SkillVertex] or control points.
    required SkillVertexTo toVertex,
    required SkillVertexFrom fromVertex,
    required this.edgePainter,
  }) : super(
          key: key,
          children: [
            // ignore: unnecessary_null_comparison
            if (toVertex != null) toVertex,
            // ignore: unnecessary_null_comparison
            if (fromVertex != null) fromVertex,
          ],
        );

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
    // TODO: Fix constraints or double check them.
    final loosenedConstraints = constraints.loosen();
    final children = getChildrenAsList();
    final toChild = children.singleWhereOrNull((child) {
      return child.parentData is SkillVertexToParentData;
    });

    Rect? toChildRect;
    Rect? fromChildRect;

    if (toChild != null) {
      final toChildParentData = toChild.parentData as SkillVertexToParentData;
      toChildRect = toChildParentData.rect!;
      final toChildSize = toChildRect.size;

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

      size = toChildRect.size;
    }

    final fromChild = children.singleWhereOrNull((child) {
      return child.parentData is SkillVertexFromParentData;
    });

    if (fromChild != null) {
      final fromChildParentData =
          fromChild.parentData as SkillVertexFromParentData;
      fromChildRect = fromChildParentData.rect!;
      final fromChildSize = fromChildRect.size;

      fromChild.layout(
        loosenedConstraints.tighten(
          width: fromChildSize.width,
          height: fromChildSize.height,
        ),
      );

      fromChildParentData.offset = Offset(
        fromChildRect.left,
        fromChildRect.top,
      );

      size = fromChildRect.size;
    }

    if (toChildRect != null && fromChildRect != null) {
      size = fromChildRect.expandToInclude(toChildRect).size;
    }
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

    final toChildParentData = children.singleWhereOrNull((child) {
      return child.parentData is SkillVertexToParentData;
    })?.parentData as SkillVertexToParentData?;

    Offset? _toCenter;
    Offset? _fromCenter;

    if (toChildParentData != null) {
      _toCenter = toChildParentData.rect!.center + offset;
    }

    final fromChildParentData = children.singleWhereOrNull((child) {
      return child.parentData is SkillVertexFromParentData;
    })?.parentData as SkillVertexFromParentData?;

    if (fromChildParentData != null) {
      _fromCenter = fromChildParentData.rect!.center + offset;
    }

    final allNodeRects = <Rect>[];
    final skillTreeParent =
        getParentOfType<RenderSkillTree<EdgeType, NodeType, IdType>>(
      this,
    );

    if (skillTreeParent == null) {
      throw StateError(
        'SkillTreeParent is null. Are you sure there is a RenderSkillTree above'
        ' this EdgeLine?',
      );
    }

    final skillEdgeParentData =
        getParentDataOfType<SkillEdgeParentData<EdgeType, IdType>>(
      this,
    );

    if (skillEdgeParentData == null) {
      throw StateError(
        'SkillEdgeParentData is null. Are you sure there is a SkillEdge above'
        ' this EdgeLine?',
      );
    }

    for (final nodeBox in skillTreeParent.nodeChildren) {
      final nodeParentData =
          nodeBox.parentData as SkillNodeParentData<NodeType, IdType>;

      if (nodeParentData.id == skillEdgeParentData.to! ||
          nodeParentData.id == skillEdgeParentData.from!) {
        continue;
      }

      final nodeRect = (nodeParentData.offset & nodeBox.size);

      allNodeRects.add(nodeRect);
    }

    // TODO: This should somehow recieve the node data of all nodes too
    edgePainter(
      toNodeCenter: _toCenter!,
      fromNodeCenter: _fromCenter!,
      canvas: context.canvas,
      allNodeRects: allNodeRects,
    );
  }
}
