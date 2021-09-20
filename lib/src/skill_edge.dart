import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:skill_tree/src/models/edge.dart';
import 'package:skill_tree/src/models/skill_parent_data.dart';
import 'package:skill_tree/src/skill_tree.dart';
import 'package:skill_tree/src/widgets/edge_line.dart';
import 'package:skill_tree/src/widgets/skill_vertex.dart';

// TODO: Control points

class SkillEdge<EdgeType, NodeType, IdType extends Object>
    extends ParentDataWidget<SkillEdgeParentData<EdgeType, NodeType, IdType>>
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
    this.toPreferredAxisDirection,
    this.fromPreferredAxisDirection,
  }) : super(
          key: key,
          child: EdgeLine<EdgeType, NodeType, IdType>(
            toVertex: SkillVertexTo(
              // TODO: This will have a key that is similar to the nodes
              key: ValueKey(to),
              child: toChild,
            ),
            fromVertex: SkillVertexFrom(
              key: ValueKey(from),
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
  final IdType from;

  @override
  final String id;

  @override
  final IdType to;

  final AxisDirection? toPreferredAxisDirection;

  final AxisDirection? fromPreferredAxisDirection;

  @override
  void applyParentData(RenderObject renderObject) {
    if (renderObject.parentData
        is! SkillEdgeParentData<EdgeType, NodeType, IdType>) {
      final parentData = renderObject.parentData as SkillParentData;

      renderObject.parentData =
          SkillEdgeParentData<EdgeType, NodeType, IdType>()
            ..nextSibling = parentData.nextSibling
            ..offset = parentData.offset
            ..previousSibling = parentData.previousSibling;
    }

    final parentData = renderObject.parentData
        as SkillEdgeParentData<EdgeType, NodeType, IdType>;

    bool needsLayout = false;
    bool needsPaint = false;

    if (parentData.data != data) {
      parentData.data = data;
      needsLayout = true;
    }

    if (parentData.from != from) {
      parentData.from = from;
      needsLayout = true;
    }

    if (parentData.id != id) {
      parentData.id = id;
      needsLayout = true;
    }

    if (parentData.to != to) {
      parentData.to = to;
      needsLayout = true;
    }

    if (parentData.toPreferredAxisDirection != toPreferredAxisDirection) {
      parentData.toPreferredAxisDirection = toPreferredAxisDirection;
      needsLayout = true;
    }

    if (parentData.fromPreferredAxisDirection != fromPreferredAxisDirection) {
      parentData.fromPreferredAxisDirection = fromPreferredAxisDirection;
      needsLayout = true;
    }

    if (parentData.name != name) {
      parentData.name = name;
      needsPaint = true;
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
