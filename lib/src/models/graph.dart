import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:skill_tree/src/models/edge.dart';
import 'package:skill_tree/src/models/node.dart';

// TODO: Can this extend iterable so I iterate over all nodes. Would that be
// cool? No, instead of Iterable<Whatever> we should do Map<Node, Set<Node>>
// right?
/// This a class to hold logic related to an abstract graph and its operations
/// and should NOT be in any way related to UI or rendering.
abstract class Graph<EdgeType, NodeType> {
  List<Node<NodeType>> get nodes;

  List<Edge<EdgeType, Node<NodeType>>> get edges;

  Iterable<Node<NodeType>> getNeighbors(Node<NodeType> node) {
    return edges
        .where((edge) => edge.from == node || edge.to == node)
        .map((edge) => edge.to == node ? edge.from : edge.to);
  }

  /// A [Node] is a root node if there are no edges containing it or there
  /// are no edges with a `to` matching it.
  List<Node<NodeType>> get rootNodes {
    final result = <Node<NodeType>>[];

    for (final node in nodes) {
      if (!edges.any((edge) => edge.to == node)) {
        result.add(node);
      }
    }

    return result;
  }

  /// Returns a layer of the graph at a time
  Iterable<Iterable<Node<NodeType>>> get breadthFirstSearch sync* {
    yield rootNodes;

    var hasMore = true;

    Iterable<Node<NodeType>> currentNodes = rootNodes.cast<Node<NodeType>>();

    while (hasMore) {
      final edgesOut = edges.where((edge) => currentNodes.contains(edge.from));
      currentNodes = edgesOut.map((edge) => edge.to).toList();

      if (currentNodes.isEmpty) hasMore = false;

      yield currentNodes;
    }
  }

  Iterable<Node<NodeType>> get depthFirstSearch sync* {
    throw UnimplementedError();
  }

  bool nodeHasDescendents(Node<NodeType> node) {
    return edges.any((edge) => edge.from == node);
  }

  Iterable<Node<NodeType>> nodeDescendents(Node<NodeType> node) {
    return edges.where((edge) => edge.from == node).map((edge) => edge.to);
  }

  Iterable<Iterable<Node<NodeType>>> nodeBreadthFirstSearch(
    Node<NodeType> rootNode,
  ) sync* {
    bool hasDescendents = true;
    var descendents = nodeDescendents(rootNode);

    yield descendents;

    while (hasDescendents) {
      final nextLayer = descendents.fold<List<Iterable<Node<NodeType>>>>(
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

  Iterable<Iterable<Iterable<Node<NodeType>>>>
      get treeBreadthFirstSearch sync* {
    for (final rootNode in rootNodes) {
      yield nodeBreadthFirstSearch(rootNode);
    }
  }

  /// Given a root node, traverses the tree and returns the max breadth of the
  /// tree.
  int maxBreadth(Node<NodeType> rootNode) {
    int maxNodes = 1;

    for (final layer in nodeBreadthFirstSearch(rootNode)) {
      maxNodes = max(layer.length, maxNodes);
    }

    return maxNodes;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Graph<EdgeType, NodeType> &&
        listEquals(other.nodes, nodes) &&
        listEquals(other.edges, edges);
  }

  @override
  int get hashCode => nodes.hashCode ^ edges.hashCode;
}
