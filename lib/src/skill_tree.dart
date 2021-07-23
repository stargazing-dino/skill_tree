import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:skill_tree/skill_tree.dart';
import 'package:skill_tree/src/graphs/directed_graph.dart';
import 'package:skill_tree/src/layouts/directed_tree.dart';
import 'package:skill_tree/src/layouts/radial_tree.dart';
import 'package:skill_tree/src/models/delegate.dart';
import 'package:skill_tree/src/models/edge.dart';
import 'package:skill_tree/src/models/graph.dart';
import 'package:skill_tree/src/models/node.dart';
import 'package:skill_tree/src/skill_edge.dart';
import 'package:skill_tree/src/skill_node.dart';

// Future note. If someone is not good with graph theory (like i was), they
// shouldn't make a flippin skill tree. You know how many of my brain cells
// committed suicide from this dumb ass package?

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
/// through to [RenderSkillsTree] where they are laid out and rendered.
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
          children: nodes
              .map<Widget>(nodeBuilder?.call ?? defaultNodeBuilder)
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

  static SkillNode<NodeType> defaultNodeBuilder<NodeType extends Object>(
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
      throw UnimplementedError('Delegate $_delegate is not a supported type.');
    }
  }
}

/// This takes inspiration from but does not extend or implement
/// [MultiChildLayoutDelegate] as that class is specific to a
/// [CustomMultiChildLayout] and its needs.
abstract class RenderSkillTree<EdgeType, NodeType> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SkillNodeParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SkillNodeParentData> {
  RenderSkillTree({
    required Graph<EdgeType, NodeType> graph,
    required SkillTreeDelegate delegate,
  })  : _graph = graph,
        _delegate = delegate;

  Graph<EdgeType, NodeType> _graph;
  Graph<EdgeType, NodeType> get graph => _graph;
  set graph(Graph<EdgeType, NodeType> graph) {
    if (_graph == graph) return;
    _graph = graph;
    markNeedsLayout();
  }

  SkillTreeDelegate _delegate;
  SkillTreeDelegate get delegate => _delegate;
  set delegate(SkillTreeDelegate delegate) {
    if (_delegate == delegate) return;
    _delegate = delegate;
    markNeedsLayout();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! SkillNodeParentData) {
      child.parentData = SkillNodeParentData();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  // TODO: memoize this or something. Don't want to getChildrenAsList every time
  RenderBox childForNode(Node<NodeType> node) {
    return getChildrenAsList().singleWhere((child) {
      final parentData = child.parentData as SkillNodeParentData;
      return parentData.id == node.id;
    });
  }

  // TODO: This is not yet implemented because I currently don't know how I'm
  // going to handle edges and their painting.
  static SkillEdge<EdgeType, NodeType>
      defaultEdgeBuilder<EdgeType extends Object, NodeType extends Object>(
    Edge<EdgeType, Node<NodeType>> edge,
  ) {
    if (edge is SkillEdge<EdgeType, NodeType>) {
      return edge;
    }

    throw UnimplementedError();
    // return SkillEdge<EdgeType, NodeType>.fromEdge(
    //   edge: edge,
    //   color: Colors.pink,
    //   createForegroundPainter: (
    //     SkillNode<NodeType> from,
    //     Offset fromOffset,
    //     Size fromSize,
    //     SkillNode<NodeType> to,
    //     Offset toOffset,
    //     Size toSize,
    //   ) {
    //     throw UnimplementedError();
    //   },
    //   createPainter: (
    //     SkillNode<NodeType> from,
    //     Offset fromOffset,
    //     Size fromSize,
    //     SkillNode<NodeType> to,
    //     Offset toOffset,
    //     Size toSize,
    //   ) {
    //     throw UnimplementedError();
    //   },
    //   key: Key('${edge.from.id},${edge.to.id}'),
    //   thickness: 2.0,
    //   willChange: false,
    // );
  }
}
