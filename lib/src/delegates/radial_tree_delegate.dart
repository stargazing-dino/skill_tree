import 'package:flutter/material.dart';
import 'package:skill_tree/src/graphs/radial_graph.dart';
import 'package:skill_tree/src/models/delegate.dart';

/// A skill tree that expands outward from a root node.
class RadialTreeDelegate<EdgeType, NodeType, IdType extends Object>
    extends SkillTreeDelegate<EdgeType, NodeType, IdType,
        RadialGraph<EdgeType, NodeType, IdType>> {
  @override
  SkillNodeLayout layoutNodes(
    BoxConstraints constraints,
    RadialGraph<EdgeType, NodeType, IdType> graph,
  ) {
    // TODO: implement layoutEdges
    throw UnimplementedError();
  }

  @override
  bool shouldRelayout(
    covariant RadialTreeDelegate<EdgeType, NodeType, IdType> oldDelegate,
  ) {
    // TODO: implement shouldRelayout
    throw UnimplementedError();
  }
}
