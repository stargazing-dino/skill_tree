import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:skill_tree/src/models/edge.dart';
import 'package:skill_tree/src/models/graph.dart';
import 'package:skill_tree/src/models/node.dart';

class LayeredGraph<EdgeType, NodeType, IdType extends Object>
    extends Graph<EdgeType, NodeType, IdType> {
  const LayeredGraph({
    required this.edges,
    required this.nodes,
    required this.layout,
  });

  // As layout is nested, to compare equality we'll need deep comparison
  final equality = const DeepCollectionEquality();

  // TODO: Should we have this here or as an onus to the user?
  // final int layerValue;

  final List<List<IdType?>> layout;

  @override
  final List<Edge<EdgeType, IdType>> edges;

  @override
  final List<Node<NodeType, IdType>> nodes;

  List<List<IdType?>> ancestorLayersForNode(Node<NodeType, IdType> node) {
    return layout.sublist(0, layerForNode(node));
  }

  int layerForNode(Node<NodeType, IdType> node) {
    int? layerOfNode;

    for (int i = 0; i < layout.length; i++) {
      final layer = layout[i];

      if (layer.contains(node.id)) {
        layerOfNode = i;
        break;
      }
    }

    if (layerOfNode == null) {
      throw ArgumentError('Node is not in graph');
    }

    return layerOfNode;
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

  LayeredGraph<EdgeType, NodeType, IdType> copyWith({
    List<List<IdType?>>? layout,
    List<Edge<EdgeType, IdType>>? edges,
    List<Node<NodeType, IdType>>? nodes,
  }) {
    return LayeredGraph<EdgeType, NodeType, IdType>(
      edges: edges ?? this.edges,
      nodes: nodes ?? this.nodes,
      layout: layout ?? this.layout,
    );
  }
}
