import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:skill_tree/skill_tree.dart';
import 'package:skill_tree/src/delegates/directed_tree_delegate.dart';
import 'package:skill_tree/src/delegates/layered_tree_delegate.dart';
import 'package:skill_tree/src/delegates/radial_tree_delegate.dart';
import 'package:skill_tree/src/graphs/directed_graph.dart';
import 'package:skill_tree/src/graphs/layered_graph.dart';
import 'package:skill_tree/src/graphs/radial_graph.dart';
import 'package:skill_tree/src/layouts/directed_tree.dart';
import 'package:skill_tree/src/layouts/layered_tree.dart';
import 'package:skill_tree/src/layouts/radial_tree.dart';
import 'package:skill_tree/src/models/delegate.dart';
import 'package:skill_tree/src/models/edge.dart';
import 'package:skill_tree/src/models/graph.dart';
import 'package:skill_tree/src/models/node.dart';
import 'package:skill_tree/src/models/skill_parent_data.dart';
import 'package:skill_tree/src/utils/get_largest_bounding_rect.dart';
import 'package:skill_tree/src/widgets/draggable_edge.dart';
import 'package:skill_tree/src/widgets/skill_edge.dart';
import 'package:skill_tree/src/widgets/skill_node.dart';

part 'models/render_skill_tree.dart';

// TODO: Column has it so it can nest itself because it itself is a Flex. We
// should have something like the same so we can nest skill trees.

// TODO: What do we do with self-directed edges? Do we allow them?

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
    this.nodeBuilder,
    this.edgeBuilder,
    this.value,
    this.maxValue,
  })  : assert((value == null || maxValue == null) || value <= maxValue),
        _edges = _castEdges(edges, nodes),
        super(
          key: key,
          children: <Widget>[
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

  final SkillNode<NodeType, IdType> Function(Node<NodeType, IdType> node)?
      nodeBuilder;

  final SkillEdge<EdgeType, NodeType, IdType> Function(
    Edge<EdgeType, Node<NodeType, IdType>> edge,
  )? edgeBuilder;

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

    return SkillEdge<EdgeType, NodeType, IdType>(
      data: edge.data,
      from: edge.from,
      id: edge.id,
      to: edge.to,
    );
  }

  /// Takes a list of edges with IdTypes and maps those ids to nodes. This
  /// is a convenience method to make things easier to work with.
  static List<Edge<EdgeType, Node<NodeType, IdType>>> _castEdges<
      EdgeType extends Object, NodeType extends Object, IdType extends Object>(
    List<Edge<EdgeType, IdType>> edges,
    List<Node<NodeType, IdType>> nodes,
  ) {
    return edges.map<Edge<EdgeType, Node<NodeType, IdType>>>(
      (edge) {
        return edge.cast(
          data: edge.data,
          from: nodes.singleWhere(
            (node) => node.id == edge.from,
            orElse: () => throw StateError(
              'No node with id ${edge.from} to construct edge $edge',
            ),
          ),
          to: nodes.singleWhere(
            (node) => node.id == edge.to,
            orElse: () => throw StateError(
              'No node with id ${edge.to} to construct edge $edge',
            ),
          ),
        );
      },
    ).toList();
  }

  // TODO: Switch on delegate type and provide right graph
  Graph<EdgeType, NodeType, IdType> get graph {
    if (delegate is DirectedTreeDelegate<IdType>) {
      return DirectedGraph<EdgeType, NodeType, IdType>(
        nodes: nodes,
        edges: _edges,
      );
    } else if (delegate is RadialTreeDelegate<IdType>) {
      return RadialGraph<EdgeType, NodeType, IdType>(
        nodes: nodes,
        edges: _edges,
      );
    } else if (delegate is LayeredTreeDelegate<IdType>) {
      return LayeredGraph<EdgeType, NodeType, IdType>(
        nodes: nodes,
        edges: _edges,
      );
    } else {
      throw ArgumentError(
        'No graph could be constructed from delegate $delegate',
      );
    }
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
