import 'package:flutter/material.dart';
import 'package:skill_tree/skill_tree.dart';

// TODO: We need to decide the origin of the plane so our offsets can be
// calculated.

/// A skill tree that lays out its nodes free hand based off the relative
/// offsets of the nodes.
class PositionedTreeDelegate<EdgeType, NodeType, IdType extends Object>
    extends SkillTreeDelegate<EdgeType, NodeType, IdType,
        PositionedGraph<EdgeType, NodeType, IdType>> {
  PositionedTreeDelegate({
    required this.positions,
  });

  final Map<IdType?, Offset> positions;

  @override
  SkillNodeLayout<NodeType, IdType> layoutNodes(
    BoxConstraints constraints,
    PositionedGraph<EdgeType, NodeType, IdType> graph,
    List<NodeDetails<NodeType, IdType>> nodeChildrenDetails,
  ) {
    // TODO: implement layoutEdges
    throw UnimplementedError();
  }

  @override
  bool shouldRelayout(
    covariant PositionedTreeDelegate<EdgeType, NodeType, IdType> oldDelegate,
  ) {
    // TODO: implement shouldRelayout
    throw UnimplementedError();
  }
}
