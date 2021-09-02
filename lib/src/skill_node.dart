import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:skill_tree/src/models/node.dart';
import 'package:skill_tree/src/models/skill_parent_data.dart';

/// This contains information necessary for layout.
class SkillNodeParentData<IdType extends Object> extends SkillParentData {
  /// An override for the depth this node is at. This can be used to place
  /// a node at a specific "level" of the tree without needing N number
  /// ancestors.
  int? depth;

  /// Used to match the [RenderBox] to the [SkillNode] when laying out.
  IdType? id;
}

/// A representation of a node in the skill tree.
class SkillNode<NodeType extends Object, IdType extends Object>
    extends ParentDataWidget<SkillNodeParentData<IdType>>
    implements Node<NodeType, IdType> {
  const SkillNode({
    Key? key,
    required Widget child,
    required this.data,
    required this.id,
    required this.depth,
    this.name,
  }) : super(
          key: key,
          child: child,
        );
  // This is applied elsewhere
  // child: DragableSkillNode(
  //   data: data,
  //   id: id,
  //   child: child,
  // ),

  factory SkillNode.fromNode({
    required Node<NodeType, IdType> node,
    required Widget child,
    int? depth,
    String? name,
  }) {
    return SkillNode(
      data: node.data,
      id: node.id,
      child: child,
      depth: depth,
    );
  }

  @override
  final NodeType? data;

  @override
  final IdType id;

  @override
  final String? name;

  final int? depth;

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData! as SkillNodeParentData<IdType>;

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
