import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:skill_tree/src/models/edge.dart';
import 'package:skill_tree/src/models/node.dart';

// TODO: I swear I've seen a typdef similar to this
typedef ValueUpdater<T> = T Function(T value);

/// This a class to hold logic related to an abstract graph and its operations
/// and should NOT be in any way related to UI or rendering.
@immutable
abstract class Graph<EdgeType, NodeType, IdType extends Object> {
  const Graph();

  // TODO:
  // void Function(Node<NodeType, IdType> a, Node<NodeType, IdType> b) get swap;

  // TODO: This can have extra validation that if the node id is changed, the
  // corresponding edge is removed etc.
  Graph<EdgeType, NodeType, IdType> updateNode(
    Node<NodeType, IdType> node,
    ValueUpdater<Node<NodeType, IdType>> updater,
  );

  List<Node<NodeType, IdType>> get nodes;

  List<Edge<EdgeType, IdType>> get edges;

  // TODO: I'm not sure how I'm going to better handle (de)serialization
  // dynamic Function(Graph<EdgeType, NodeType, IdType> graph)? get serialize;

  // Graph<EdgeType, NodeType, IdType> Function(dynamic value)? get deserialize;

  Node<NodeType, IdType> getNodeFromIdType(IdType id) {
    return nodes.singleWhere((node) {
      return id == node.id;
    });
  }

  /// Checks the validity of the graph in a specific graph model
  bool get debugCheckGraph;

  Iterable<Node<NodeType, IdType>> getNeighbors(Node<NodeType, IdType> node) {
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

  List<Edge<EdgeType, IdType>> nodesBefore(
    Node<NodeType, IdType> node,
  );

  List<Edge<EdgeType, IdType>> edgesForNode(
    Node<NodeType, IdType> node,
  ) {
    final edgesForNode = <Edge<EdgeType, IdType>>[];

    for (final edge in edges) {
      if (edge.from == node.id) {
        edgesForNode.add(edge);
        continue;
      }

      if (edge.to == node.id) {
        edgesForNode.add(edge);
        continue;
      }
    }

    return edgesForNode;
  }

  /// Returns a layer of the graph at a time
  Iterable<Iterable<Node<NodeType, IdType>>> get breadthFirstSearch sync* {
    yield rootNodes;

    var hasMore = true;

    Iterable<Node<NodeType, IdType>> currentNodes =
        rootNodes.cast<Node<NodeType, IdType>>();

    while (hasMore) {
      final edgesOut = edges.where((edge) => currentNodes.contains(edge.from));
      currentNodes = edgesOut.map((edge) {
        return getNodeFromIdType(edge.to);
      }).toList();

      if (currentNodes.isEmpty) hasMore = false;

      yield currentNodes;
    }
  }

  Iterable<Node<NodeType, IdType>> get depthFirstSearch sync* {
    throw UnimplementedError();
  }

  bool nodeHasDescendents(Node<NodeType, IdType> node) {
    return edges.any((edge) => edge.from == node);
  }

  Iterable<Node<NodeType, IdType>> nodeDescendents(
    Node<NodeType, IdType> node,
  ) {
    return edges.where((edge) => edge.from == node).map((edge) {
      return getNodeFromIdType(edge.to);
    });
  }

  Iterable<Iterable<Node<NodeType, IdType>>> nodeBreadthFirstSearch(
    Node<NodeType, IdType> rootNode,
  ) sync* {
    bool hasDescendents = true;
    var descendents = nodeDescendents(rootNode);

    yield descendents;

    while (hasDescendents) {
      final nextLayer =
          descendents.fold<List<Iterable<Node<NodeType, IdType>>>>(
        [],
        (acc, node) {
          acc.add(nodeDescendents(node));
          return acc;
        },
      ).expand((edges) => edges);

      if (nextLayer.isEmpty) {
        hasDescendents = false;
      } else {
        yield nextLayer;
      }
    }
  }

  Iterable<Iterable<Iterable<Node<NodeType, IdType>>>>
      get treeBreadthFirstSearch sync* {
    for (final rootNode in rootNodes) {
      yield nodeBreadthFirstSearch(rootNode);
    }
  }

  /// Given a root node, traverses the tree and returns the max breadth of the
  /// tree.
  int maxBreadth(Node<NodeType, IdType> rootNode) {
    int maxNodes = 1;

    for (final layer in nodeBreadthFirstSearch(rootNode)) {
      maxNodes = max(layer.length, maxNodes);
    }

    return maxNodes;
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
