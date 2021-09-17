import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skill_tree/src/models/node.dart';
import 'package:skill_tree/src/models/skill_parent_data.dart';
import 'package:skill_tree/src/skill_tree.dart';

/// A representation of a node in the skill tree.
class SkillNode<NodeType, IdType extends Object>
    extends ParentDataWidget<SkillNodeParentData<NodeType, IdType>>
    implements Node<NodeType, IdType> {
  const SkillNode({
    Key? key,
    required Widget child,
    required this.data,
    required this.id,
    this.name,
  }) : super(key: key, child: child);

  factory SkillNode.fromNode({
    required Node<NodeType, IdType> node,
    required Widget child,
    int? depth,
    String? name,
  }) {
    return SkillNode(
      key: ValueKey(node.id),
      data: node.data,
      id: node.id,
      child: child,
    );
  }

  @override
  final NodeType? data;

  @override
  final IdType id;

  @override
  final String? name;

  @override
  void applyParentData(RenderObject renderObject) {
    if (renderObject.parentData is! SkillNodeParentData<NodeType, IdType>) {
      final parentData = renderObject.parentData as SkillParentData;

      renderObject.parentData = SkillNodeParentData<NodeType, IdType>()
        ..nextSibling = parentData.nextSibling
        ..offset = parentData.offset
        ..previousSibling = parentData.previousSibling;
    }

    final parentData =
        renderObject.parentData as SkillNodeParentData<NodeType, IdType>;

    bool needsLayout = false;
    bool needsPaint = false;

    if (parentData.data != data) {
      parentData.data = data;
      needsLayout = true;
    }

    if (parentData.id != id) {
      parentData.id = id;
      needsLayout = true;
    }

    if (parentData.name != name) {
      parentData.name = name;
      needsPaint = true;
    }

    final renderParent = renderObject.parent;

    if (needsLayout) {
      if (renderParent is RenderObject) {
        renderParent.markNeedsLayout();
      }
    }

    if (needsPaint) {
      if (renderParent is RenderObject) {
        renderParent.markNeedsPaint();
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
