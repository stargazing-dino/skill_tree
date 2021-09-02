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
import 'package:skill_tree/src/models/skill_parent_data.dart';
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
class SkillTree<EdgeType extends Object, NodeType extends Object,
    IdType extends Object> extends MultiChildRenderObjectWidget {
  SkillTree({
    Key? key,
    required List<Edge<EdgeType, IdType>> edges,
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
        _edges = _castEdges(edges, nodes),
        super(
          key: key,
          children: [
            ...nodes.map(nodeBuilder?.call ?? defaultSkillNodeBuilder),
            ..._castEdges(edges, nodes).map(
              edgeBuilder?.call ?? defaultSkillEdgeBuilder,
            ),
          ],
        );

  final List<Edge<EdgeType, Node<NodeType, IdType>>> _edges;

  final List<Node<NodeType, IdType>> nodes;

  final SkillTreeDelegate<IdType> delegate;

  final Function(Map<IdType, dynamic> json)? onSave;

  final Map<IdType, dynamic> Function(NodeType value)? serializeNode;

  final Map<IdType, dynamic> Function(EdgeType value)? serializeEdge;

  final NodeType Function(Map<IdType, dynamic> json)? deserializeNode;

  final EdgeType Function(Map<IdType, dynamic> json)? deserializeEdge;

  final SkillEdge<EdgeType, NodeType, IdType> Function(
    Edge<EdgeType, Node<NodeType, IdType>> edge,
  )? edgeBuilder;

  final SkillNode<NodeType, IdType> Function(Node<NodeType, IdType> node)?
      nodeBuilder;

  final int? value;

  final int? maxValue;

  static SkillNode<NodeType, IdType>
      defaultSkillNodeBuilder<NodeType extends Object, IdType extends Object>(
    Node<NodeType, IdType> node,
  ) {
    if (node is SkillNode<NodeType, IdType>) {
      return node;
    }

    return SkillNode<NodeType, IdType>.fromNode(
      child: Text(node.id.toString()),
      node: node,
      depth: null,
      name: '',
    );
  }

  static SkillEdge<EdgeType, NodeType, IdType> defaultSkillEdgeBuilder<
      EdgeType extends Object, NodeType extends Object, IdType extends Object>(
    Edge<EdgeType, Node<NodeType, IdType>> edge,
  ) {
    if (edge is SkillEdge<EdgeType, NodeType, IdType>) {
      return edge;
    }

    return SkillEdge<EdgeType, NodeType, IdType>.fromEdge(
      edge: edge,
      color: Colors.pink,
      createForegroundPainter: (
        SkillNode<NodeType, IdType> from,
        Offset fromOffset,
        Size fromSize,
        SkillNode<NodeType, IdType> to,
        Offset toOffset,
        Size toSize,
      ) {
        throw UnimplementedError();
      },
      createPainter: (
        SkillNode<NodeType, IdType> from,
        Offset fromOffset,
        Size fromSize,
        SkillNode<NodeType, IdType> to,
        Offset toOffset,
        Size toSize,
      ) {
        throw UnimplementedError();
      },
      key: Key('${edge.from.id},${edge.to.id}'),
      thickness: 2.0,
      willChange: false,
    );
  }

  /// Takes a list of edges with IdTypes and maps those ids to nodes. This
  /// is a convenience method to make things easier to work with.
  static List<Edge<EdgeType, Node<NodeType, IdType>>>
      _castEdges<EdgeType, NodeType extends Object, IdType extends Object>(
    List<Edge<EdgeType, IdType>> edges,
    List<Node<NodeType, IdType>> nodes,
  ) {
    return edges.map<Edge<EdgeType, Node<NodeType, IdType>>>(
      (edge) {
        return edge.cast(
          data: edge.data,
          from: nodes.singleWhere((node) => node.id == edge.from),
          to: nodes.singleWhere((node) => node.id == edge.to),
        );
      },
    ).toList();
  }

  // TODO: Switch on delegate type and provide right graph
  Graph<EdgeType, NodeType, IdType> get graph {
    return DirectedGraph<EdgeType, NodeType, IdType>(
      nodes: nodes,
      edges: _edges,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) {
    (renderObject as RenderSkillTree<EdgeType, NodeType, IdType>)
      .._graph = graph
      .._delegate = delegate;
  }

  // We create a render object instead of a [CustomMultiChildLayout]
  // because we want to define our own ParentData necessary for the layout.
  @override
  RenderObject createRenderObject(BuildContext context) {
    // TODO: How do I wrap this render object with a theme?
    // final skillThemeData = SkillTreeTheme.of(context);

    final _delegate = delegate;

    if (_delegate is DirectedTreeDelegate<IdType>) {
      return RenderDirectedTree<EdgeType, NodeType, IdType>(
        graph: graph,
        delegate: _delegate,
      );
    } else if (_delegate is RadialTreeDelegate<IdType>) {
      return RenderRadialLayout<EdgeType, NodeType, IdType>(
        graph: graph,
        delegate: _delegate,
      );
    } else if (_delegate is LayeredTreeDelegate<IdType>) {
      return RenderLayeredLayout<EdgeType, NodeType, IdType>(
        graph: graph,
        delegate: _delegate,
      );
    } else {
      throw ArgumentError('Delegate $_delegate is not a supported type.');
    }
  }
}
