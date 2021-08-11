import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:skill_tree/skill_tree.dart';
import 'package:skill_tree/src/delegates/layered_tree_delegate.dart';
import 'package:skill_tree/src/models/graph.dart';

// GraphView describes it here
// https://pub.dev/packages/graphview#layered-graph
class RenderLayeredLayout<EdgeType, NodeType extends Object,
    IdType extends Object> extends RenderSkillTree<EdgeType, NodeType, IdType> {
  RenderLayeredLayout({
    required Graph<EdgeType, NodeType, IdType> graph,
    required this.delegate,
  }) : super(graph: graph, delegate: delegate);

  @override
  final LayeredTreeDelegate<IdType> delegate;

  @override
  void performLayout() {
    // Each child will have 1 / maxLayerFlex of the space
    final crossAxisSpacing = delegate.crossAxisSpacing;
    final mainAxisSpacing = delegate.mainAxisSpacing;
    final maxLayerSize = delegate.layout.first.length;
    final maxAvailableWidth =
        constraints.maxWidth - (crossAxisSpacing * (maxLayerSize - 1));
    final maxChildFraction = 1 / maxLayerSize;
    final maxChildWidth = maxAvailableWidth * maxChildFraction;
    final layerHeights = <double>[];

    for (final layer in delegate.layout) {
      var layerHeight = 0.0;

      /// We iterate through the layer and get the approximate layer height
      /// based on the largest child height.
      for (final id in layer) {
        final node = id == null
            ? null
            : graph.nodes.singleWhere((node) => node.id == id);

        if (node == null) {
          // Do nothing.
        } else {
          final child = childForNode(node);
          final maxWidth = maxChildWidth;
          final height = child.computeMaxIntrinsicHeight(maxWidth);

          layerHeight = max(height, layerHeight);
        }
      }

      layerHeights.add(layerHeight + mainAxisSpacing);

      /// Layout the children of this layer
      for (final id in layer) {
        final node = id == null
            ? null
            : graph.nodes.singleWhere((node) => node.id == id);

        if (node == null) {
          // Do Nothing.
        } else {
          final child = childForNode(node);

          child.layout(
            constraints.copyWith(
              maxWidth: maxChildWidth,
              maxHeight: layerHeight,
            ),
            parentUsesSize: true,
          );
        }
      }
    }

    // POSITIONING
    var dy = 0.0;

    for (var i = 0; i < delegate.layout.length; i++) {
      var dx = 0.0;
      final layer = delegate.layout[i];
      final layerHeight = layerHeights[i];

      for (var j = 0; j < layer.length; j++) {
        dx = maxChildWidth * j;
        dx += delegate.crossAxisSpacing * j;

        final id = layer[j];
        final node = id == null
            ? null
            : graph.nodes.singleWhere((node) => node.id == id);

        if (node != null) {
          final child = childForNode(node);
          final childParentData = child.parentData as SkillNodeParentData;
          // final childSize = child.size;

          childParentData.offset = Offset(dx, dy);
        }
      }

      dy += layerHeight;
    }

    size = Size(
      constraints.maxWidth,
      layerHeights.fold(0.0, (acc, element) => acc += element),
    );
  }
}
