import 'package:flutter/foundation.dart';
import 'package:skill_tree/src/models/edge.dart';
import 'package:skill_tree/src/models/graph.dart';
import 'package:skill_tree/src/models/node.dart';

@immutable
class RadialGraph<EdgeType, NodeType, IdType extends Object>
    extends Graph<EdgeType, NodeType, IdType> {
  const RadialGraph({
    required this.edges,
    required this.nodes,
  });

  @override
  final List<Edge<EdgeType, IdType>> edges;

  @override
  final List<Node<NodeType, IdType>> nodes;

  @override
  RadialGraph<EdgeType, NodeType, IdType> updateNode(
    Node<NodeType, IdType> node,
    ValueUpdater<Node<NodeType, IdType>> updater,
  ) {
    return RadialGraph(
      edges: edges,
      nodes: nodes.map((n) => n.id == node.id ? updater(n) : n).toList(),
    );
  }

  @override
  List<Edge<EdgeType, IdType>> nodesBefore(
    Node<NodeType, IdType> node,
  ) {
    return [];
  }

  @override
  bool get debugCheckGraph {
    // TODO:
    return true;
  }

  RadialGraph<EdgeType, NodeType, IdType> copyWith({
    List<Edge<EdgeType, IdType>>? edges,
    List<Node<NodeType, IdType>>? nodes,
  }) {
    return RadialGraph<EdgeType, NodeType, IdType>(
      edges: edges ?? this.edges,
      nodes: nodes ?? this.nodes,
    );
  }
}
