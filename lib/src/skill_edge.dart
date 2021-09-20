import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:skill_tree/src/models/edge.dart';
import 'package:skill_tree/src/models/node.dart';
import 'package:skill_tree/src/models/skill_parent_data.dart';
import 'package:skill_tree/src/skill_tree.dart';

class SkillEdge<EdgeType, NodeType, IdType extends Object>
    extends ParentDataWidget<SkillEdgeParentData<EdgeType, NodeType, IdType>>
    implements Edge<EdgeType, Node<NodeType, IdType>> {
  const SkillEdge({
    Key? key,
    required Widget child,
    required this.data,
    required this.name,
    required this.from,
    required this.id,
    required this.to,
  }) : super(key: key, child: child);

  @override
  final EdgeType data;

  @override
  final String? name;

  @override
  final Node<NodeType, IdType> from;

  @override
  final String id;

  @override
  final Node<NodeType, IdType> to;

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
