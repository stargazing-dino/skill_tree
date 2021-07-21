import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skill_tree/src/models/skill_node.dart';
import 'package:skill_tree/src/skill_tree.dart';

class NodeView<T> extends ParentDataWidget<NodeViewParentData>
    implements SkillNode<T> {
  @override
  final T data;

  @override
  final String id;

  @override
  final String label;

  @override
  final String? name;

  final int? depth;

  const NodeView({
    Key? key,
    required Widget child,
    required this.label,
    required this.data,
    required this.id,
    this.depth,
    this.name,
  }) : super(key: key, child: child);

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is NodeViewParentData);
    final parentData = renderObject.parentData! as NodeViewParentData;
    bool needsLayout = false;

    if (parentData.depth != depth) {
      parentData.depth = depth;
      needsLayout = true;
    }

    if (needsLayout) {
      final AbstractNode? targetParent = renderObject.parent;
      if (targetParent is RenderObject) targetParent.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => NodeView;
}
