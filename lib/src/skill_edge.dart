import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:skill_tree/src/models/edge.dart';
import 'package:skill_tree/src/skill_node.dart';
import 'package:skill_tree/src/skill_point.dart';
import 'package:skill_tree/src/skill_tree.dart';
import 'package:skill_tree/src/utils/get_parent_data_of_type.dart';
import 'package:skill_tree/src/utils/get_parent_of_type.dart';

typedef EdgePainter = void Function({
  required Offset toNodeCenter,
  required Offset fromNodeCenter,
  required List<Rect> allNodeRects,
  required Canvas canvas,
});

class SkillEdgeParentData<EdgeType, IdType extends Object>
    extends SkillParentData {
  EdgeType? data;

  String? name;

  String? id;

  IdType? from;

  IdType? to;

  Alignment? fromAlignment;

  Alignment? toAlignment;

  Offset? fromCenter;

  // TODO: Implement
  // List<Offset>? controlPointCenters;

  Offset? toCenter;
}

// TODO: There is a way to combine SkillEdge and MultiChildEdge as a single
// widget but I'm not sure how.

/// An edge that will be rendered as a line between two widget vertices.
class SkillEdge<EdgeType, NodeType, IdType extends Object>
    extends ParentDataWidget<SkillEdgeParentData<EdgeType, IdType>>
    implements Edge<EdgeType, IdType> {
  SkillEdge({
    Key? key,
    required Widget fromChild,
    required Widget toChild,
    required EdgePainter edgePainter,
    required this.data,
    required this.name,
    required this.from,
    required this.id,
    required this.to,
    this.toAlignment,
    this.fromAlignment,
  }) : super(
          key: key,
          child: MultiChildEdge<EdgeType, NodeType, IdType>(
            toPoint: SkillPointTo(
              key: ValueKey(from),
              child: toChild,
            ),
            fromPoint: SkillPointFrom(
              key: ValueKey(to),
              child: fromChild,
            ),
            edgePainter: edgePainter,
          ),
        );

  @override
  final EdgeType data;

  @override
  final String? name;

  @override
  final String id;

  @override
  final IdType from;

  @override
  final IdType to;

  final Alignment? fromAlignment;

  final Alignment? toAlignment;

  @override
  void applyParentData(RenderObject renderObject) {
    if (renderObject.parentData is! SkillEdgeParentData<EdgeType, IdType>) {
      final parentData = renderObject.parentData as SkillParentData;

      renderObject.parentData = SkillEdgeParentData<EdgeType, IdType>()
        ..nextSibling = parentData.nextSibling
        ..offset = parentData.offset
        ..previousSibling = parentData.previousSibling;
    }

    final parentData =
        renderObject.parentData as SkillEdgeParentData<EdgeType, IdType>;

    bool needsLayout = false;
    bool needsPaint = false;

    if (parentData.data != data) {
      parentData.data = data;
      needsLayout = true;
    }

    if (parentData.name != name) {
      parentData.name = name;
      needsPaint = true;
    }

    if (parentData.id != id) {
      parentData.id = id;
      needsLayout = true;
    }

    if (parentData.from != from) {
      parentData.from = from;
      needsLayout = true;
    }

    if (parentData.to != to) {
      parentData.to = to;
      needsLayout = true;
    }

    if (parentData.fromAlignment != fromAlignment) {
      parentData.fromAlignment = fromAlignment;
      needsLayout = true;
    }

    if (parentData.toAlignment != toAlignment) {
      parentData.toAlignment = toAlignment;
      needsLayout = true;
    }

    final targetParent = renderObject.parent;

    if (needsLayout) {
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    }

    if (needsPaint) {
      if (targetParent is RenderObject) {
        targetParent.markNeedsPaint();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => SkillTree;

  @override
  bool debugIsValidRenderObject(RenderObject renderObject) {
    return renderObject.parentData is SkillParentData;
  }
}

class MultiChildEdge<EdgeType, NodeType, IdType extends Object>
    extends MultiChildRenderObjectWidget {
  MultiChildEdge({
    Key? key,
    // TODO: Control points ... This should be able to be a list of
    // [SkillPoint] or control points.
    required SkillPointTo toPoint,
    required SkillPointFrom fromPoint,
    required this.edgePainter,
  }) : super(
          key: key,
          children: [toPoint, fromPoint],
        );

  final EdgePainter edgePainter;

  @override
  RenderBox createRenderObject(BuildContext context) {
    return RenderMultiChildEdge<EdgeType, NodeType, IdType>(
      edgePainter: edgePainter,
    );
  }
}

// TODO: Draw paintOverflows

/// The fields of this [RenderObject] are initialized in the layout phase.
/// This is because we must first know the size of the node widgets.
class RenderMultiChildEdge<EdgeType, NodeType, IdType extends Object>
    extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SkillPointParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SkillPointParentData>,
        DebugOverflowIndicatorMixin {
  RenderMultiChildEdge({
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
    if (child.parentData is! SkillPointParentData) {
      child.parentData = SkillPointParentData();
    }
  }

  @override
  void performLayout() {
    // TODO: Fix constraints or double check them.
    final loosenedConstraints = constraints.loosen();
    final children = getChildrenAsList();
    final toChild = children.singleWhere((child) {
      return child.parentData is SkillPointToParentData;
    });

    final toChildParentData = toChild.parentData as SkillPointToParentData;
    final toChildRect = toChildParentData.rect!;
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

    final fromChild = children.singleWhere((child) {
      return child.parentData is SkillPointFromParentData;
    });

    final fromChildParentData =
        fromChild.parentData as SkillPointFromParentData;
    final fromChildRect = fromChildParentData.rect!;
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
    final skillEdgeParentData =
        getParentDataOfType<SkillEdgeParentData<EdgeType, IdType>>(
      this,
    );

    if (skillEdgeParentData == null) {
      throw StateError(
        'SkillEdgeParentData is null. Are you sure there is a SkillEdge above'
        ' this MultiChildEdge?',
      );
    }

    final toCenter = skillEdgeParentData.toCenter! + offset;
    final fromCenter = skillEdgeParentData.fromCenter! + offset;

    final allNodeRects = <Rect>[];
    final skillTreeParent =
        getParentOfType<RenderSkillTree<EdgeType, NodeType, IdType>>(
      this,
    );

    if (skillTreeParent == null) {
      throw StateError(
        'SkillTreeParent is null. Are you sure there is a RenderSkillTree above'
        ' this MultiChildEdge?',
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
      toNodeCenter: toCenter,
      fromNodeCenter: fromCenter,
      canvas: context.canvas,
      allNodeRects: allNodeRects,
    );
  }
}
