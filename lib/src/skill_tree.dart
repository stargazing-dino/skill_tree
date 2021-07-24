import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:skill_tree/skill_tree.dart';
import 'package:skill_tree/src/delegates/directed_tree_delegate.dart';
import 'package:skill_tree/src/delegates/layered_tree_delegate.dart';
import 'package:skill_tree/src/delegates/radial_tree_delegate.dart';
import 'package:skill_tree/src/graphs/directed_graph.dart';
import 'package:skill_tree/src/layouts/directed_tree.dart';
import 'package:skill_tree/src/layouts/layered_tree.dart';
import 'package:skill_tree/src/layouts/radial_tree.dart';
import 'package:skill_tree/src/models/delegate.dart';
import 'package:skill_tree/src/models/edge.dart';
import 'package:skill_tree/src/models/graph.dart';
import 'package:skill_tree/src/models/node.dart';
import 'package:skill_tree/src/skill_edge.dart';
import 'package:skill_tree/src/skill_node.dart';

part 'models/render_skill_tree.dart';

// TODO: Column has it so it can nest itself because it itself is a Flex. We
// should have something like the same so we can nest skill trees.

// TODO: What do we do with self-directed edges? Do we allow them?

// TODO: In technical terms, isn't this a forest, which is a set of trees?
// Because I want to allow multiple root nodes and leaf nodes?

/// A widget to create a skill tree. This assumes a digraph structure. That is,
/// edges are directed.
///
/// Edges can be acyclic so long as the [LayoutDelegate] properly handles it. The
/// default layout does not as it's unidrected in a single axis. For acyclic
/// graphs, use the a [RadialLayout] instead.
///
/// Edges and nodes go through two representations. The first is unconnected to
/// the UI and are in the form of Edge and Node. They are then transformed into
/// [SkillEdge] and [SkillNode] via the `builders`. These are then passed
/// through to [RenderSkillTree] where they are laid out and rendered.
class SkillTree<EdgeType extends Object, NodeType extends Object>
    extends MultiChildRenderObjectWidget {
  SkillTree({
    Key? key,
    required this.edges,
    required this.nodes,
    required this.delegate,
    this.onSave,
    this.serializeNode,
    this.serializeEdge,
    this.deserializeNode,
    this.deserializeEdge,
    this.edgeBuilder,
    this.nodeBuilder,
    this.value,
    this.maxValue,
  })  : assert((value == null || maxValue == null) || value <= maxValue),
        super(
          key: key,
          // TODO: I think we should pass in the edges here too... We would then
          // figure out whats what in the RenderSkillTree. First we would layout
          // the nodes and then the nodes
          children: nodes
              .map<Widget>(nodeBuilder?.call ?? defaultSkillNodeBuilder)
              .toList(),
        );

  final List<Edge<EdgeType, String>> edges;

  final List<Node<NodeType>> nodes;

  final SkillTreeDelegate delegate;

  final Function(Map<String, dynamic> json)? onSave;

  final Map<String, dynamic> Function(NodeType value)? serializeNode;

  final Map<String, dynamic> Function(EdgeType value)? serializeEdge;

  final NodeType Function(Map<String, dynamic> json)? deserializeNode;

  final EdgeType Function(Map<String, dynamic> json)? deserializeEdge;

  final SkillEdge Function(
    Edge<EdgeType, SkillNode<NodeType>> edge,
  )? edgeBuilder;

  final SkillNode Function(Node<NodeType> node)? nodeBuilder;

  final int? value;

  final int? maxValue;

  static SkillNode<NodeType> defaultSkillNodeBuilder<NodeType extends Object>(
    Node<NodeType> node,
  ) {
    if (node is SkillNode<NodeType>) {
      return node;
    }

    return SkillNode<NodeType>.fromNode(
      child: Text(node.id),
      node: node,
      depth: null,
      name: '',
    );
  }

  /// Takes a list of edges with string ids and maps those ids to nodes. This
  /// is a convenience method to make things easier to work with.
  static List<Edge<T, Node<R>>> _castEdges<T, R>(
    List<Edge<T, String>> edges,
    List<Node<R>> nodes,
  ) {
    return edges.map<Edge<T, Node<R>>>(
      (edge) {
        return edge.cast(
          data: edge.data,
          from: nodes.singleWhere((node) => node.id == edge.from),
          to: nodes.singleWhere((node) => node.id == edge.to),
        );
      },
    ).toList();
  }

  // TODO: If we need end up creating different types of graphs, we should
  // do so by making factory constructors and initializing them in the
  // initializer list.
  Graph<EdgeType, NodeType> get graph {
    return DirectedGraph<EdgeType, NodeType>(
      nodes: nodes,
      edges: _castEdges(edges, nodes),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) {
    (renderObject as RenderSkillTree<EdgeType, NodeType>)
      .._graph = graph
      .._delegate = delegate;
  }

  /// We create a render object instead of a [CustomMultiChildLayout]
  /// because we want to define our own ParentData necessary for the layout.
  @override
  RenderObject createRenderObject(BuildContext context) {
    // TODO: How do I wrap this render object with a theme?
    // final skillThemeData = SkillTreeTheme.of(context);

    final _delegate = delegate;

    if (_delegate is DirectedTreeDelegate) {
      return RenderDirectedTree(graph: graph, delegate: _delegate);
    } else if (_delegate is RadialTreeDelegate) {
      return RenderRadialLayout(graph: graph, delegate: _delegate);
    } else if (_delegate is LayeredTreeDelegate) {
      return RenderLayeredLayout(graph: graph, delegate: _delegate);
    } else {
      throw ArgumentError('Delegate $_delegate is not a supported type.');
    }
  }
}
