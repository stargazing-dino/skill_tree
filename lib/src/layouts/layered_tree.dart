import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:skill_tree/skill_tree.dart';
import 'package:skill_tree/src/delegates/layered_tree_delegate.dart';
import 'package:skill_tree/src/models/graph.dart';

// FIXME: I think this class should actually be called a delegate

// GraphView describes it here
// https://pub.dev/packages/graphview#layered-graph
class RenderLayeredLayout<EdgeType, NodeType, IdType extends Object>
    extends RenderSkillTree<EdgeType, NodeType, IdType> {
  RenderLayeredLayout({
    required Graph<EdgeType, NodeType, IdType> graph,
    required LayeredTreeDelegate<IdType> delegate,
  })  : _delegate = delegate,
        super(graph: graph);

  @override
  LayeredTreeDelegate<IdType> get delegate => _delegate;
  LayeredTreeDelegate<IdType> _delegate;
  set delegate(LayeredTreeDelegate<IdType> delegate) {
    if (delegate == _delegate) return;
    _delegate = delegate;
    markNeedsLayout();
  }

  @override
  void layoutNodes() {
    // Each child will have 1 / maxLayerFlex of the space
    final crossAxisSpacing = delegate.crossAxisSpacing;
    final mainAxisSpacing = delegate.mainAxisSpacing;
    final crossAxisAlignment = delegate.crossAxisAlignment;
    final layerSizes = delegate.layout.map((layer) => layer.length).toList();
    final layerMaxWidths = delegate.layout.mapIndexed((index, layer) {
      final layerSize = layerSizes[index];

      return constraints.maxWidth - (crossAxisSpacing * (layerSize - 1));
    }).toList();
    final maxChildWidths = layerMaxWidths.mapIndexed((index, layerMaxWidth) {
      final layerSize = layerSizes[index];
      final layerMaxWidth = layerMaxWidths[index];

      return layerMaxWidth / layerSize;
    }).toList();

    final layerHeights = <double>[];

    for (int i = 0; i < delegate.layout.length; i++) {
      final layer = delegate.layout[i];
      final maxChildWidth = maxChildWidths[i];

      var layerHeight = 0.0;

      /// We iterate through the layer and get the approximate layer height
      /// based on the largest child height.
      for (final id in layer) {
        if (id == null) continue;

        final node = graph.nodes.singleWhere((node) => node.id == id);
        final child = childForNode(node);
        final maxWidth = maxChildWidth;
        final height = child.computeMaxIntrinsicHeight(maxWidth);

        layerHeight = max(height, layerHeight);
      }

      layerHeights.add(layerHeight + mainAxisSpacing);

      /// Layout the children of this layer
      for (final id in layer) {
        if (id == null) continue;

        final node = graph.nodes.singleWhere((node) => node.id == id);
        final child = childForNode(node);
        final childConstraints = constraints.loosen().copyWith(
              maxWidth: maxChildWidth,
              maxHeight: layerHeight,
            );

        child.layout(childConstraints, parentUsesSize: true);
      }
    }

    // POSITIONING
    var dy = 0.0;

    for (var i = 0; i < delegate.layout.length; i++) {
      var dx = 0.0;
      final layer = delegate.layout[i];
      final layerHeight = layerHeights[i];
      final maxChildWidth = maxChildWidths[i];

      for (var j = 0; j < layer.length; j++) {
        dx = maxChildWidth * j;
        dx += delegate.crossAxisSpacing * j;

        final id = layer[j];

        if (id == null) continue;

        final node = graph.nodes.singleWhere((node) => node.id == id);
        final child = childForNode(node);
        final childParentData = child.parentData as SkillNodeParentData;

        childParentData.offset = Offset(dx, dy);
      }

      dy += layerHeight;
    }

    size = Size(
      constraints.maxWidth,
      layerHeights.fold(0.0, (acc, element) => acc += element),
    );
  }
}
