import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:skill_tree/skill_tree.dart';
import 'package:skill_tree/src/models/delegate.dart';
import 'package:skill_tree/src/models/graph.dart';

class LayeredTreeDelegate extends SkillTreeDelegate {
  LayeredTreeDelegate({
    this.crossAxisSpacing = 0,
    this.mainAxisSpacing = 0,
  });

  final double crossAxisSpacing;

  final double mainAxisSpacing;
}

// TODO: Don't expose this class

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

  /// This goes through layer by layer and
  @override
  void performLayout() {
    final children = getChildrenAsList();
    double height = 0;

    // ---------------- Size the nodes ---------------
    var _constraints = constraints;

    for (final nodeLayer in graph.breadthFirstSearch) {
      double layerHeight = 0.0;

      for (final node in nodeLayer) {
        final child = children.singleWhere((child) {
          final parentData = child.parentData as SkillNodeParentData;
          return parentData.id == node.id;
        });

        final _width = child.computeMinIntrinsicWidth(_constraints.maxHeight);
        final _height = child.computeMinIntrinsicHeight(_constraints.maxWidth);
        final childSize = Size(_width, _height);

        // final childParentData = child.parentData as SkillNodeParentData;

        child.layout(
          _constraints,
          parentUsesSize: true,
        );

        layerHeight = max(childSize.height, layerHeight);
      }

      height += layerHeight;
      // FIXME: This can go beyond... Got to clip it.
      _constraints = _constraints.copyWith(
        maxHeight: _constraints.maxHeight - layerHeight,
      );
    }

    /// On the root layer, we need to know some things. Mainly, if a node has
    /// descedents, what is the maximum number of them. Based off that, that node
    /// will be placed in the center of the maximum number... What???
    var dy = 0.0;

    for (final nodeLayer in graph.breadthFirstSearch) {
      // final overflowed = [];
      var dx = 0.0;

      for (final node in nodeLayer) {
        // if node.hasDescendants

        final child = children.singleWhere((child) {
          final parentData = child.parentData as SkillNodeParentData;
          return parentData.id == node.id;
        });
        final childParentData = child.parentData as SkillNodeParentData;

        childParentData.offset = Offset(dx, dy);
        dx += child.size.width;
      }

      final layerHeight = nodeLayer.map((node) {
        return children.singleWhere((child) {
          final parentData = child.parentData as SkillNodeParentData;

          return parentData.id == node.id;
        });
      }).fold<double>(0.0, (acc, element) => max(acc, element.size.height));

      dy += layerHeight;
    }

    size = Size(
      constraints.maxWidth,
      height,
    );
  }
}
