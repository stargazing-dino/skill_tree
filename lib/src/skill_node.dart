import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:skill_tree/src/models/node.dart';

/// This contains information necessary for layout.
class SkillNodeParentData extends ContainerBoxParentData<RenderBox> {
  /// An override for the depth this node is at. This can be used to place
  /// a node at a specific "level" of the tree without needing N number
  /// ancestors.
  int? depth;

  /// Used to match the [RenderBox] to the [SkillNode] when laying out.
  String? id;
}

// TODO: This will likely need to be a DragNode/DragTarget as well

/// A representation of a node in the skill tree.
class SkillNode<T> extends ParentDataWidget<SkillNodeParentData>
    implements Node<T> {
  const SkillNode({
    Key? key,
    required Widget child,
    required this.id,
    this.data,
    this.depth,
    this.name,
    this.requirement,
  }) : super(key: key, child: child);

  @override
  final T? data;

  @override
  final String id;

  @override
  final String? name;

  /// Related to rendering. This is used to determine the placement of the node
  /// in the tree.
  final int? depth;

  /// Related to rendering. This is used to determine whether this node has
  /// been acquired or not.
  final int? requirement;

  factory SkillNode.fromNode({
    required Node<T> node,
    required Widget child,
    int? depth,
    String? name,
  }) {
    return SkillNode(
      data: node.data,
      id: node.id,
      child: child,
      depth: depth,
      name: name,
    );
  }

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is SkillNodeParentData);
    final parentData = renderObject.parentData! as SkillNodeParentData;
    bool needsLayout = false;

    if (parentData.depth != depth) {
      parentData.depth = depth;
      needsLayout = true;
    }

    if (parentData.id != id) {
      parentData.id = id;
      needsLayout = true;
    }

    if (needsLayout) {
      final AbstractNode? targetParent = renderObject.parent;
      if (targetParent is RenderObject) targetParent.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => SkillNode;
}
