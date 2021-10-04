import 'dart:math';

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

  final List<List<IdType?>> layout;

  @override
  final List<Edge<EdgeType, IdType>> edges;

  @override
  final List<Node<NodeType, IdType>> nodes;

  @override
  LayeredGraph<EdgeType, NodeType, IdType> updateNode(
    Node<NodeType, IdType> node,
    ValueUpdater<Node<NodeType, IdType>> updater,
  ) {
    return LayeredGraph(
      edges: edges,
      nodes: nodes.map((n) => n.id == node.id ? updater(n) : n).toList(),
      layout: layout,
    );
  }

  @override
  LayeredGraph<EdgeType, NodeType, IdType> updateEdge(
    Edge<EdgeType, IdType> edge,
    ValueUpdater<Edge<EdgeType, IdType>> updater,
  ) {
    return LayeredGraph(
      edges: edges.map((e) => e.id == edge.id ? updater(e) : e).toList(),
      nodes: nodes,
      layout: layout,
    );
  }

  @override
  LayeredGraph<EdgeType, NodeType, IdType> swap(IdType idOne, IdType idTwo) {
    final pointOne = findIdInLayout(idOne);
    final pointTwo = findIdInLayout(idTwo);

    var layoutCopy = List<List<IdType?>>.from(
      layout.map<List<IdType?>>((layer) => List<IdType?>.from(layer)),
    );

    layoutCopy[pointOne.x][pointOne.y] = idTwo;
    layoutCopy[pointTwo.x][pointTwo.y] = idOne;

    return LayeredGraph(
      edges: edges,
      nodes: nodes,
      layout: layoutCopy,
    );
  }

  // Returns the (x, y) position of the id in the layout
  //
  // Was gonna try fancy modulo stuff but you can't assume rectangular layouts.
  Point<int> findIdInLayout(IdType id) {
    for (int i = 0; i < layout.length; i++) {
      final layer = layout[i];

      final j = layer.indexOf(id);

      if (j != -1) {
        return Point<int>(i, j);
      }
    }

    throw ArgumentError('Could not find $id in layout');
  }

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
  bool get debugCheckGraph {
    // TODO
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
