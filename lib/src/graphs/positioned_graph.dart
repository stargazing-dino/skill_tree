import 'package:flutter/foundation.dart';
import 'package:skill_tree/src/models/edge.dart';
import 'package:skill_tree/src/models/graph.dart';
import 'package:skill_tree/src/models/node.dart';

@immutable
class PositionedGraph<EdgeType, NodeType, IdType extends Object>
    extends Graph<EdgeType, NodeType, IdType> {
  const PositionedGraph({
    required this.edges,
    required this.nodes,
  });

  @override
  final List<Edge<EdgeType, IdType>> edges;

  @override
  final List<Node<NodeType, IdType>> nodes;

  @override
  PositionedGraph<EdgeType, NodeType, IdType> updateNode(
    Node<NodeType, IdType> node,
    ValueUpdater<Node<NodeType, IdType>> updater,
  ) {
    return PositionedGraph(
      edges: edges,
      nodes: nodes.map((n) => n.id == node.id ? updater(n) : n).toList(),
    );
  }

  @override
  PositionedGraph<EdgeType, NodeType, IdType> updateEdge(
    Edge<EdgeType, IdType> edge,
    ValueUpdater<Edge<EdgeType, IdType>> updater,
  ) {
    return PositionedGraph(
      edges: edges.map((e) => e.id == edge.id ? updater(e) : e).toList(),
      nodes: nodes,
    );
  }

  @override
  List<Edge<EdgeType, IdType>> nodesBefore(
    Node<NodeType, IdType> node,
  ) {
    // TODO
    return [];
  }

  @override
  bool get debugCheckGraph {
    // TODO
    return true;
  }

  PositionedGraph<EdgeType, NodeType, IdType> copyWith({
    List<Edge<EdgeType, IdType>>? edges,
    List<Node<NodeType, IdType>>? nodes,
  }) {
    return PositionedGraph<EdgeType, NodeType, IdType>(
      edges: edges ?? this.edges,
      nodes: nodes ?? this.nodes,
    );
  }

  @override
  PositionedGraph<EdgeType, NodeType, IdType> swap(IdType idOne, IdType idTwo) {
    // TODO implement swap
    throw UnimplementedError();
  }
}
