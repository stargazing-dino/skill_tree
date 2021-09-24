import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:skill_tree/skill_tree.dart';
import 'package:skill_tree/src/models/delegate.dart';

class LayeredTreeDelegate<EdgeType, NodeType, IdType extends Object>
    extends SkillTreeDelegate<EdgeType, NodeType, IdType,
        LayeredGraph<EdgeType, NodeType, IdType>> {
  const LayeredTreeDelegate({
    this.crossAxisSpacing = 0,
    this.mainAxisSpacing = 0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final double crossAxisSpacing;

  final double mainAxisSpacing;

  final CrossAxisAlignment crossAxisAlignment;

  // final equality = const DeepCollectionEquality();

  @override
  SkillNodeLayout layoutNodes(
    BoxConstraints constraints,
    LayeredGraph<EdgeType, NodeType, IdType> graph,
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

        final node = graph.nodes.singleWhere((node) => node.id == id);
        final child = childForNode(node) as RenderBox;
        final maxWidth = maxChildWidth;
        final height = child.getDryLayout(constraints).height;

        layerHeight = max(height, layerHeight);
      }

      layerHeights.add(layerHeight + mainAxisSpacing);

      /// Layout the children of this layer
      for (final id in layer) {
        if (id == null) continue;

        final node = graph.nodes.singleWhere((node) => node.id == id);
        final child = childForNode(node);
        final childConstraints = constraints.copyWith(
          maxWidth: maxChildWidth,
          maxHeight: layerHeight,
        );

        child.layout(childConstraints, parentUsesSize: true);
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

  @override
  bool shouldRelayout(
    covariant LayeredTreeDelegate<EdgeType, NodeType, IdType> oldDelegate,
  ) {
    return oldDelegate == this;
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
