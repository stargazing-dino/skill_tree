import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skill_tree/src/models/node.dart';
import 'package:skill_tree/src/models/skill_parent_data.dart';

// /// This contains information necessary for layout.
// class SkillNodeParentData<IdType extends Object> extends SkillParentData {
//   /// An override for the depth this node is at. This can be used to place
//   /// a node at a specific "level" of the tree without needing N number
//   /// ancestors.
//   int? depth;

//   /// Used to match the [RenderBox] to the [SkillNode] when laying out.
//   IdType? id;
// }

/// A representation of a node in the skill tree.
class SkillNode<NodeType extends Object, IdType extends Object>
    extends StatelessWidget implements Node<NodeType, IdType> {
  const SkillNode({
    Key? key,
    required this.child,
    required this.data,
    required this.id,
    required this.depth,
    this.name,
  }) : super(key: key);

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

  final Widget child;

  @override
  final NodeType? data;

  @override
  final IdType id;

  @override
  final String? name;

  final int? depth;

  @override
  Widget build(BuildContext context) {
    // TODO: the four sides of the node should have
    // a DragTarget for the [EdgePoint] to be connected to.
    // I would honestly like to do four triangles whose
    // inner vertices meet in the center
    // https://stackoverflow.com/questions/56930636/flutter-button-with-custom-shape-triangle

    return SkillParentWidget(
      child: child,
      skillWidget: this,
    );
  }
}
