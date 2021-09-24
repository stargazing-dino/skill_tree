import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:skill_tree/src/models/edge.dart';
import 'package:skill_tree/src/models/graph.dart';
import 'package:skill_tree/src/models/node.dart';

class LayeredGraph<EdgeType, NodeType, IdType extends Object>
    extends Graph<EdgeType, NodeType, IdType> {
  LayeredGraph({
    required this.edges,
    required this.nodes,
    required this.layout,
  });

  // As layout is nested, to compare equality we'll need deep comparison
  final equality = const DeepCollectionEquality();

  final List<List<IdType?>> layout;

  @override
  final List<Edge<EdgeType, IdType>> edges;

  @override
  final List<Node<NodeType, IdType>> nodes;

  @override
  List<Edge<EdgeType, IdType>> nodesBefore(
    Node<NodeType, IdType> node,
  ) {
    return [];
  }

  @override
  bool debugCheckGraph({
    required List<Edge<EdgeType, IdType>> edges,
    required List<Node<NodeType, IdType>> nodes,
  }) {
    return true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LayeredGraph<EdgeType, NodeType, IdType> &&
        equality.equals(layout, other.layout) &&
        listEquals(other.nodes, nodes) &&
        listEquals(other.edges, edges);
  }

  @override
  int get hashCode => nodes.hashCode ^ edges.hashCode ^ layout.hashCode;
}
