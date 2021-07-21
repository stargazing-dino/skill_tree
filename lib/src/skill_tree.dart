import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:skill_tree/src/models/skill_edge.dart';
import 'package:skill_tree/src/models/skill_layout.dart';
import 'package:skill_tree/src/models/skill_node.dart';

// TODO: Column has it so it can nest itself because it itself is a Flex. We
// should have something like the same so we can nest skill trees.
class SkillTree<EdgeType, NodeType> extends MultiChildRenderObjectWidget {
  final List<SkillEdge<EdgeType, String>> edges;

  final List<SkillNode<NodeType>> nodes;

  final SkillLayout layout;

  final Function(Map<String, dynamic> json)? onSave;

  final Map<String, dynamic> Function(NodeType value)? serializeNode;

  final Map<String, dynamic> Function(EdgeType value)? serializeEdge;

  final NodeType Function(Map<String, dynamic> json)? deserializeNode;

  final EdgeType Function(Map<String, dynamic> json)? deserializeEdge;

  final Widget Function(
    SkillEdge<EdgeType, SkillNode<NodeType>> edge,
  )? edgeBuilder;

  final Widget Function(SkillNode<NodeType> node)? nodeBuilder;

  SkillTree({
    Key? key,
    required this.edges,
    required this.nodes,
    required this.layout,
    this.onSave,
    this.serializeNode,
    this.serializeEdge,
    this.deserializeNode,
    this.deserializeEdge,
    this.edgeBuilder,
    this.nodeBuilder,
  }) : super(
          key: key,
          children: nodes
              .map<Widget>(nodeBuilder?.call ?? defaultNodeBuilder)
              .toList(),
        );

  static Widget defaultEdgeBuilder<EdgeType, NodeType>(
    SkillEdge<EdgeType, NodeType> skillEdge,
  ) {
    return const Placeholder();
  }

  static Widget defaultNodeBuilder<NodeType>(SkillNode<NodeType> skillNode) {
    return Text(skillNode.id);
  }

  static List<SkillEdge<T, SkillNode<R>>> castEdges<T, R>(
    List<SkillEdge<T, String>> edges,
    List<SkillNode<R>> nodes,
  ) {
    return edges.map<SkillEdge<T, SkillNode<R>>>(
      (edge) {
        return edge.cast<T, SkillNode<R>>(
          data: edge.data,
          from: nodes.firstWhere((node) => node.id == edge.from),
          to: nodes.firstWhere((node) => node.id == edge.to),
        );
      },
    ).toList();
  }

  static void thing<T>() {}

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSkillsTree<EdgeType, NodeType>(castEdges(edges, nodes));
  }
}

class NodeViewParentData extends ContainerBoxParentData<RenderBox> {
  int? depth;
}

class RenderSkillsTree<EdgeType, NodeType> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, NodeViewParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, NodeViewParentData> {
  final List<SkillEdge<EdgeType, SkillNode<NodeType>>> edges;

  RenderSkillsTree(this.edges);

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! NodeViewParentData) {
      child.parentData = NodeViewParentData();
    }
  }

  @override
  void performLayout() {
    final children = getChildrenAsList();
    double width = 0, height = 0;

    for (final child in children) {
      child.layout(
        BoxConstraints(maxWidth: constraints.maxWidth),
        parentUsesSize: true,
      );

      height += child.size.height;
      width = max(width, child.size.width);
    }

    var childOffset = const Offset(0, 0);
    for (final child in children) {
      final childParentData = child.parentData as NodeViewParentData;
      childParentData.offset = Offset(0, childOffset.dx);
      childOffset += Offset(0, child.size.height);
    }

    size = Size(width, height);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
