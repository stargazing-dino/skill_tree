import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:skill_tree/skill_tree.dart';
import 'package:skill_tree/src/delegates/layered_tree_delegate.dart';
import 'package:skill_tree/src/models/graph.dart';

// GraphView describes it here
// https://pub.dev/packages/graphview#layered-graph
class RenderLayeredLayout<EdgeType, NodeType>
    extends RenderSkillTree<EdgeType, NodeType> {
  RenderLayeredLayout({
    required Graph<EdgeType, NodeType> graph,
    required this.delegate,
  }) : super(graph: graph, delegate: delegate);

  @override
  final LayeredTreeDelegate delegate;

  /// First, we get the max node count in layer from each root. Those act as
  /// flex's. For example, if a rootNode has a maxLayerCount of 4 and
  /// another has one of 2, we would distribute 4/6 of the space to the first
  /// (including constraints)  and 2/6 to the second.
  @override
  void performLayout() {
    final rootLayer = graph.breadthFirstSearch.first;
    final maxBreadths = Map<Node, int>.fromEntries(
      rootLayer.map<MapEntry<Node, int>>((rootNode) {
        return MapEntry(rootNode, graph.maxBreadth(rootNode));
      }),
    );
    final maxBreadth = maxBreadths.values.fold<int>(0, (acc, element) {
      acc += element;
      return acc;
    });

    double layerHeight = 0.0;
    final layerHeights = <double>[];

    /// We iterate through the layer and get an approximate layer height based
    /// on the flex of that tree.
    for (final node in rootLayer) {
      // This is a tree
      final flex = maxBreadths[node]! / maxBreadth;
      final child = childForNode(node);
      final maxWidth = constraints.maxWidth * flex;
      final height = child.computeMaxIntrinsicHeight(maxWidth);

      layerHeight = max(height, layerHeight);
    }

    layerHeights.add(layerHeight);

    /// Layout the children of this layer
    for (final node in rootLayer) {
      final flex = maxBreadths[node]! / maxBreadth;
      final child = childForNode(node);
      final maxWidth = constraints.maxWidth * flex;

      child.layout(
        constraints.copyWith(maxWidth: maxWidth, maxHeight: layerHeight),
        parentUsesSize: true,
      );
    }

    for (final rootNode in rootLayer) {
      final flex = maxBreadths[rootNode]! / maxBreadth;

      for (final layer in graph.nodeBreadthFirstSearch(rootNode)) {
        double layerHeight = 0.0;

        for (final node in layer) {
          // This is a tree
          final child = childForNode(node);
          final maxWidth = constraints.maxWidth * flex;
          final height = child.computeMaxIntrinsicHeight(maxWidth);

          layerHeight = max(height, layerHeight);
        }

        layerHeights.add(layerHeight);

        for (final node in layer) {
          final child = childForNode(node);
          final maxWidth = constraints.maxWidth * flex;

          child.layout(
            constraints.copyWith(maxWidth: maxWidth, maxHeight: layerHeight),
            parentUsesSize: true,
          );
        }
      }
    }

    // POSITIONING

    var dy = 0.0;
    var dx = 0.0;

    for (final node in rootLayer) {
      // This is a tree
      final flex = maxBreadths[node]! / maxBreadth;
      final child = childForNode(node);
      final childParentData = child.parentData as SkillNodeParentData;
      final maxWidth = constraints.maxWidth * flex;
      final childSize = child.size;

      childParentData.offset = Offset(
        dx + (maxWidth / 2) - (childSize.width / 2),
        dy,
      );

      dx += maxWidth;
    }

    dy += layerHeights[0];

    for (final rootNode in rootLayer) {
      var dx = 0.0;

      final treeFlex = maxBreadths[rootNode]! / maxBreadth;

      for (final layer in graph.nodeBreadthFirstSearch(rootNode)) {
        for (final node in layer) {
          final flex = treeFlex / layer.length;
          final child = childForNode(node);
          final childParentData = child.parentData as SkillNodeParentData;
          final maxWidth = constraints.maxWidth * flex;
          final childSize = child.size;

          childParentData.offset = Offset(
            dx + (maxWidth / 2) - (childSize.width / 2),
            dy,
          );

          dx += maxWidth;
        }

        dy += layerHeights[1];
      }
    }

    size = Size(
      constraints.maxWidth,
      layerHeights.fold(0.0, (acc, element) => acc += element),
    );
  }
}
