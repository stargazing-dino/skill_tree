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

// GraphView describes it here
// https://pub.dev/packages/graphview#layered-graph
class RenderLayeredLayout<EdgeType, NodeType>
    extends RenderSkillTree<EdgeType, NodeType> {
  RenderLayeredLayout({
    required Graph<EdgeType, NodeType> graph,
    required this.delegate,
  }) : super(graph);

  final LayeredTreeDelegate delegate;

  @override
  void performLayout() {
    final children = getChildrenAsList();
    double height = 0;

    for (final nodeLayer in graph.breadthFirstSearch) {
      double layerHeight = 0.0;

      for (final node in nodeLayer) {
        final child = children.singleWhere((child) {
          final parentData = child.parentData as SkillNodeParentData;
          return parentData.id == node.id;
        });

        // FIXME: How can we do this? I rather not subclass RenderObject in this
        // layout because then I'd need to provide graph and all that when
        // constructing the skill tree.
        // Option 1: Ignore...
        // Option 2: Make this a RenderObject and graph late and apply it to the
        // instance.
        // Option 3: Precompute the sizes of the children and pass them in.
        final _width = child.computeMinIntrinsicWidth(constraints.maxHeight);
        final _height = child.computeMinIntrinsicHeight(constraints.maxWidth);
        final childSize = Size(_width, _height);

        // final childParentData = child.parentData as SkillNodeParentData;

        child.layout(
          constraints,
          parentUsesSize: true,
        );

        layerHeight = max(childSize.height, layerHeight);
      }

      height += layerHeight;
    }

    var dy = 0.0;

    for (final nodeLayer in graph.breadthFirstSearch) {
      // final overflowed = [];
      var dx = 0.0;

      for (final node in nodeLayer) {
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
