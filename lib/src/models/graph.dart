import 'package:flutter/foundation.dart';
import 'package:skill_tree/src/models/edge.dart';
import 'package:skill_tree/src/models/node.dart';

// TODO I swear I've seen a typdef similar to this
typedef ValueUpdater<T> = T Function(T value);

/// This a class to hold logic related to an abstract graph and its operations
/// and should NOT be in any way related to UI or rendering.
@immutable
abstract class Graph<EdgeType, NodeType, IdType extends Object> {
  const Graph();

  // TODO This can have extra validation that if the node id is changed, the
  // corresponding edge is removed etc.
  Graph<EdgeType, NodeType, IdType> updateNode(
    Node<NodeType, IdType> node,
    ValueUpdater<Node<NodeType, IdType>> updater,
  );

  Graph<EdgeType, NodeType, IdType> updateEdge(
    Edge<EdgeType, IdType> edge,
    ValueUpdater<Edge<EdgeType, IdType>> updater,
  );

  Graph<EdgeType, NodeType, IdType> swap(IdType idOne, IdType idTwo);

  List<Node<NodeType, IdType>> get nodes;

  List<Edge<EdgeType, IdType>> get edges;

  Node<NodeType, IdType> getNodeFromIdType(IdType id) {
    return nodes.singleWhere((node) => id == node.id);
  }

  Node<NodeType, IdType> getFromNodeFromEdge(Edge<EdgeType, IdType> edge) {
    return getNodeFromIdType(edge.from);
  }

  Node<NodeType, IdType> getToNodeFromEdge(Edge<EdgeType, IdType> edge) {
    return getNodeFromIdType(edge.to);
  }

  /// Checks the validity of the graph in a specific graph model
  bool get debugCheckGraph;

  Iterable<Node<NodeType, IdType>> getConnected(Node<NodeType, IdType> node) {
    return edges
        .where((edge) => edge.from == node || edge.to == node)
        .map((edge) {
      return getNodeFromIdType(edge.to == node ? edge.from : edge.to);
    });
  }

  /// A [Node] is a root node if there are no edges containing it or there
  /// are no edges with a `to` matching it.
  List<Node<NodeType, IdType>> get rootNodes {
    final result = <Node<NodeType, IdType>>[];

    for (final node in nodes) {
      if (!edges.any((edge) => edge.to == node)) {
        result.add(node);
      }
    }

    return result;
  }

  bool nodeHasToNodes(Node<NodeType, IdType> node) {
    return edges.any((edge) => edge.to == node);
  }

  /// Returns all of the nodes that are directly or indirectly attached via
  /// `to` edges.
  List<Node<NodeType, IdType>> allToNodes(Node<NodeType, IdType> node) {
    return toNodes(node).expand((nodeLayers) => nodeLayers).toList();
  }

  Iterable<List<Node<NodeType, IdType>>> toNodes(
    Node<NodeType, IdType> node,
  ) sync* {
    yield* travel(
      node,
      getToNodeFromEdge,
      (edge) => edge.from == node.id,
    );
  }

  bool nodeHasFromNodes(Node<NodeType, IdType> node) {
    return edges.any((edge) => edge.from == node);
  }

  /// Returns all of the nodes that are directly or indirectly attached via
  /// `from` edges.
  List<Node<NodeType, IdType>> allFromNodes(Node<NodeType, IdType> node) {
    return fromNodes(node).expand((nodeLayers) => nodeLayers).toList();
  }

  /// Retrieves the [Node]s that are descendants of the given [Node]. That means
  /// that the given [Node] has a `to` relationship with any of the other nodes.
  Iterable<List<Node<NodeType, IdType>>> fromNodes(
    Node<NodeType, IdType> node,
  ) sync* {
    yield* travel(
      node,
      getFromNodeFromEdge,
      (edge) => edge.to == node.id,
    );
  }

  /// Travels the graph a level or layer at a time.
  Iterable<List<Node<NodeType, IdType>>> travel(
    Node<NodeType, IdType> node,
    Node<NodeType, IdType> Function(Edge<EdgeType, IdType> edge) getNode,
    bool Function(Edge<EdgeType, IdType> edge) predicateNode,
  ) sync* {
    var layerNodes = edges.where(predicateNode).map(getNode).toList();

    while (layerNodes.isNotEmpty) {
      yield layerNodes;

      layerNodes = layerNodes
          .map(
            (node) {
              return edges
                  .where(predicateNode)
                  .map(getNode)
                  .where((node) => !layerNodes.contains(node));
            },
          )
          .expand((edges) => edges)
          .toList();
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Graph<EdgeType, NodeType, IdType> &&
        listEquals(other.nodes, nodes) &&
        listEquals(other.edges, edges);
  }

  @override
  int get hashCode => nodes.hashCode ^ edges.hashCode;
}
