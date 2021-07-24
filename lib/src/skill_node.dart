import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:skill_tree/src/models/node.dart';
import 'package:skill_tree/src/widgets/draggable_skill_node.dart';

/// This contains information necessary for layout.
class SkillNodeParentData extends ContainerBoxParentData<RenderBox> {
  /// An override for the depth this node is at. This can be used to place
  /// a node at a specific "level" of the tree without needing N number
  /// ancestors.
  int? depth;

  /// Used to match the [RenderBox] to the [SkillNode] when laying out.
  String? id;
}

/// A representation of a node in the skill tree.
class SkillNode<T extends Object> extends ParentDataWidget<SkillNodeParentData>
    implements Node<T> {
  SkillNode({
    Key? key,
    required Widget child,
    required this.data,
    required this.id,
    required this.depth,
    this.name,
  }) : super(
          key: key,
          child: DragableSkillNode(
            data: data,
            id: id,
            child: child,
          ),
        );

  @override
  final T? data;

  @override
  final String id;

  @override
  final String? name;

  final int? depth;

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
