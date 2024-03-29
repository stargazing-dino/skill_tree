import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:skill_tree/skill_tree.dart';

// TODO I need to rethink how I size node. They should shrink if they don't fit.
class LayeredTreeDelegate<EdgeType, NodeType, IdType extends Object>
    extends SkillTreeDelegate<EdgeType, NodeType, IdType,
        LayeredGraph<EdgeType, NodeType, IdType>> {
  LayeredTreeDelegate({
    Listenable? relayout,
    this.crossAxisSpacing = 0,
    this.mainAxisSpacing = 0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  }) : super(relayout: relayout);

  final double crossAxisSpacing;

  final double mainAxisSpacing;

  final CrossAxisAlignment crossAxisAlignment;

  @override
  SkillNodeLayout<NodeType, IdType> layoutNodes(
    BoxConstraints constraints,
    LayeredGraph<EdgeType, NodeType, IdType> graph,
    List<NodeDetails<NodeType, IdType>> nodeChildrenDetails,
  ) {
    // Each child will have 1 / maxLayerFlex of the space
    final layerSizes = graph.layout.map((layer) => layer.length).toList();
    final layerMaxWidths = graph.layout.mapIndexed((index, layer) {
      final layerSize = layerSizes[index];

      return constraints.maxWidth - (crossAxisSpacing * (layerSize - 1));
    }).toList();
    final maxChildWidths = layerMaxWidths.mapIndexed((index, layerMaxWidth) {
      final layerSize = layerSizes[index];
      final layerMaxWidth = layerMaxWidths[index];

      return layerMaxWidth / layerSize;
    }).toList();

    final layerHeights = <double>[];

    for (int i = 0; i < graph.layout.length; i++) {
      final layer = graph.layout[i];
      final maxChildWidth = maxChildWidths[i];

      var layerHeight = 0.0;

      /// We iterate through the layer and get the approximate layer height
      /// based on the largest child height.
      for (final id in layer) {
        if (id == null) continue;

        final nodeDetails = nodeChildrenDetails.singleWhere((nodeDetails) {
          return nodeDetails.node.id == id;
        });
        final child = nodeDetails.child;
        final height = child.getMaxIntrinsicHeight(maxChildWidth);

        layerHeight = max(height, layerHeight);
      }

      layerHeights.add(layerHeight + mainAxisSpacing);

      /// Layout the children of this layer
      for (final id in layer) {
        if (id == null) continue;

        final nodeDetails = nodeChildrenDetails.singleWhere((nodeDetails) {
          return nodeDetails.node.id == id;
        });
        final childConstraints = constraints.copyWith(
          maxWidth: maxChildWidth,
          maxHeight: layerHeight,
        );

        // TODO Should this be moved to delegate like `layoutChild`?
        // TODO Similar to [MultiChildLayoutDelegate] I should probably have
        // debug asserts that ensure every child was laid out.
        nodeDetails.child.layout(childConstraints, parentUsesSize: true);
      }
    }

    // POSITIONING
    var dy = 0.0;

    for (var i = 0; i < graph.layout.length; i++) {
      var dx = 0.0;
      final layer = graph.layout[i];
      final layerHeight = layerHeights[i];
      final maxChildWidth = maxChildWidths[i];

      for (var j = 0; j < layer.length; j++) {
        dx = maxChildWidth * j;
        dx += crossAxisSpacing * j;

        final id = layer[j];

        if (id == null) continue;

        final nodeDetails = nodeChildrenDetails.singleWhere((nodeDetails) {
          return nodeDetails.node.id == id;
        });
        final childParentData = nodeDetails.parentData;

        childParentData.offset = Offset(dx, dy);
      }

      dy += layerHeight;
    }

    return SkillNodeLayout(
      size: Size(
        constraints.maxWidth,
        layerHeights.fold(0.0, (acc, element) => acc += element),
      ),
    );
  }

  @override
  bool shouldRelayout(
    covariant LayeredTreeDelegate<EdgeType, NodeType, IdType> oldDelegate,
  ) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(other) =>
      other is LayeredTreeDelegate<EdgeType, NodeType, IdType> &&
      crossAxisSpacing == other.crossAxisSpacing &&
      mainAxisSpacing == other.mainAxisSpacing &&
      crossAxisAlignment == other.crossAxisAlignment;

  @override
  int get hashCode =>
      crossAxisSpacing.hashCode ^
      mainAxisSpacing.hashCode ^
      crossAxisAlignment.hashCode;
}
