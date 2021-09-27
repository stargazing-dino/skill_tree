import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:skill_tree/skill_tree.dart';
import 'package:skill_tree/src/edge_route_painting/spline_edge.dart';
import 'package:skill_tree/src/graphs/layered_graph.dart';
import 'package:skill_tree/src/graphs/radial_graph.dart';
import 'package:skill_tree/src/models/edge.dart';
import 'package:skill_tree/src/models/graph.dart';
import 'package:skill_tree/src/models/node.dart';
import 'package:skill_tree/src/skill_edge.dart';
import 'package:skill_tree/src/skill_node.dart';
import 'package:skill_tree/src/utils/get_alignment_for_angle.dart';
import 'package:skill_tree/src/widgets/edge_line.dart';
import 'package:skill_tree/src/widgets/skill_vertex.dart';

part './models/delegate.dart';

typedef EdgeBuilder<EdgeType, NodeType, IdType extends Object,
        GraphType extends Graph<EdgeType, NodeType, IdType>>
    = SkillEdge<EdgeType, NodeType, IdType> Function(
  Edge<EdgeType, IdType> edge,
  GraphType graph,
);

typedef NodeBuilder<EdgeType, NodeType, IdType extends Object,
        GraphType extends Graph<EdgeType, NodeType, IdType>>
    = SkillNode<NodeType, IdType> Function(
  Node<NodeType, IdType> node,
  GraphType graph,
);

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
class SkillTree<EdgeType, NodeType, IdType extends Object>
    extends MultiChildRenderObjectWidget {
  /// Defines a graph and delegate specific to a LayeredGraph.
  SkillTree.layered({
    Key? key,
    required LayeredGraph<EdgeType, NodeType, IdType> graph,
    required LayeredTreeDelegate<EdgeType, NodeType, IdType> delegate,
    NodeBuilder<EdgeType, NodeType, IdType,
            LayeredGraph<EdgeType, NodeType, IdType>>?
        nodeBuilder,
    EdgeBuilder<EdgeType, NodeType, IdType,
            LayeredGraph<EdgeType, NodeType, IdType>>?
        edgeBuilder,
  })  : _graph = graph,
        _delegate = delegate,
        super(
          key: key,
          children: <Widget>[
            ...graph.nodes.map((node) {
              return nodeBuilder?.call(node, graph) ??
                  defaultSkillNodeBuilder(node, graph);
            }),
            ...graph.edges.map(
              (edge) {
                return edgeBuilder?.call(edge, graph) ??
                    defaultSkillEdgeBuilder<EdgeType, NodeType, IdType>(
                      edge,
                      graph,
                    );
              },
            ),
          ],
        );

  SkillTree.radial({
    Key? key,
    required RadialGraph<EdgeType, NodeType, IdType> graph,
    required RadialTreeDelegate<EdgeType, NodeType, IdType> delegate,
    NodeBuilder<EdgeType, NodeType, IdType,
            RadialGraph<EdgeType, NodeType, IdType>>?
        nodeBuilder,
    EdgeBuilder<EdgeType, NodeType, IdType,
            RadialGraph<EdgeType, NodeType, IdType>>?
        edgeBuilder,
  })  : _graph = graph,
        _delegate = delegate,
        super(
          key: key,
          children: <Widget>[
            ...graph.nodes.map((node) {
              return nodeBuilder?.call(node, graph) ??
                  defaultSkillNodeBuilder(node, graph);
            }),
            ...graph.edges.map(
              (edge) {
                return edgeBuilder?.call(edge, graph) ??
                    defaultSkillEdgeBuilder<EdgeType, NodeType, IdType>(
                      edge,
                      graph,
                    );
              },
            ),
          ],
        );

  final Graph<EdgeType, NodeType, IdType> _graph;

  final SkillTreeDelegate<EdgeType, NodeType, IdType,
      Graph<EdgeType, NodeType, IdType>> _delegate;

  static SkillNode<NodeType, IdType>
      defaultSkillNodeBuilder<NodeType, EdgeType, IdType extends Object>(
    Node<NodeType, IdType> node,
    Graph<EdgeType, NodeType, IdType> graph,
  ) {
    if (node is SkillNode<NodeType, IdType>) {
      return node;
    }

    assert(node is! SkillNode);

    // TODO: the four sides of the node should have
    // a DragTarget for the [EdgePoint] to be connected to.
    // I would honestly like to do four triangles whose
    // inner vertices meet in the center
    // https://stackoverflow.com/questions/56930636/flutter-button-with-custom-shape-triangle
    return SkillNode<NodeType, IdType>.fromNode(
      child: Text(node.id.toString()),
      node: node,
      name: '',
    );
  }

  static SkillEdge<EdgeType, NodeType, IdType>
      defaultSkillEdgeBuilder<EdgeType, NodeType, IdType extends Object>(
    Edge<EdgeType, IdType> edge,
    Graph<EdgeType, NodeType, IdType> graph,
  ) {
    if (edge is SkillEdge<EdgeType, NodeType, IdType>) {
      return edge;
    }

    return SkillEdge<EdgeType, NodeType, IdType>(
      edgePainter: defaultCubicEdgePainter,
      fromChild: const SizedBox.shrink(),
      toChild: const SizedBox.shrink(),
      name: edge.name,
      data: edge.data,
      id: edge.id,
      from: edge.from,
      to: edge.to,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) {
    renderObject as RenderSkillTree<EdgeType, NodeType, IdType>
      ..graph = _graph
      ..delegate = _delegate;
  }

  // We create a render object instead of a [CustomMultiChildLayout]
  // because we want to define our own ParentData necessary for the layout.
  @override
  RenderObject createRenderObject(BuildContext context) {
    assert(_graph.debugCheckGraph);

    return RenderSkillTree<EdgeType, NodeType, IdType>(
      delegate: _delegate,
      graph: _graph,
    );
  }
}

/// A super parent data class that is temporarily initialized in
/// [RenderSkillTree] to later then be converted to [SkillNodeParentData] or
/// [SkillEdgeParentData] respective of the type of the child.
class SkillParentData extends ContainerBoxParentData<RenderBox> {}

/// This class provides useful abstractions across both the graph theory model
/// and the render model.
///
/// This class can be considered a sort of [MultiChildLayoutDelegate]. However,
/// it is not for technical reasons. One of them being that using a
/// [MultChildCustomLayout] doesn't allow for setting the layout size based
/// on the sizes of the children.
///
/// This class abstracts down to two operations. One for drawing nodes and the
/// other for drawing edges.
class RenderSkillTree<EdgeType, NodeType, IdType extends Object>
    extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SkillParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SkillParentData>,
        DebugOverflowIndicatorMixin {
  /// Creates a render object that lays out both nodes and edges.
  RenderSkillTree({
    required Graph<EdgeType, NodeType, IdType> graph,
    required SkillTreeDelegate<EdgeType, NodeType, IdType,
            Graph<EdgeType, NodeType, IdType>>
        delegate,
  })  : _graph = graph,
        _delegate = delegate;

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! SkillParentData) {
      child.parentData = SkillParentData();
    }
  }

  Graph<EdgeType, NodeType, IdType> _graph;
  Graph<EdgeType, NodeType, IdType> get graph => _graph;
  set graph(Graph<EdgeType, NodeType, IdType> graph) {
    if (_graph == graph) return;
    _graph = graph;
    markNeedsLayout();
  }

  // TODO: I don't like how I'm handling Graph type here...
  SkillTreeDelegate<EdgeType, NodeType, IdType,
      Graph<EdgeType, NodeType, IdType>> _delegate;
  SkillTreeDelegate<EdgeType, NodeType, IdType,
      Graph<EdgeType, NodeType, IdType>> get delegate => _delegate;
  set delegate(
    SkillTreeDelegate<EdgeType, NodeType, IdType,
            Graph<EdgeType, NodeType, IdType>>
        delegate,
  ) {
    if (_delegate == delegate) return;
    if (delegate.runtimeType != _delegate.runtimeType ||
        delegate.shouldRelayout(_delegate)) {
      markNeedsLayout();
    }
    _delegate = delegate;
    if (attached) {
      _delegate._relayout?.removeListener(markNeedsLayout);
      delegate._relayout?.addListener(markNeedsLayout);
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _delegate._relayout?.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    _delegate._relayout?.removeListener(markNeedsLayout);
    super.detach();
  }

  @override
  void performLayout() {
    final loosenedConstraints = constraints.loosen();
    final nodeChildrenDetails = graph.nodes.map((node) {
      final child = childForNode(node);
      final parentData =
          child.parentData as SkillNodeParentData<NodeType, IdType>;

      return NodeDetails(
        child: child,
        parentData: parentData,
        node: node,
      );
    }).toList();
    final skillNodeLayout = delegate.layoutNodes(
      loosenedConstraints,
      graph,
      nodeChildrenDetails,
    );

    // addAll();

    size = skillNodeLayout.size;

    final edgeChildrenDetails = graph.edges.map((edge) {
      final child =
          childForEdge(edge) as RenderEdgeLine<EdgeType, NodeType, IdType>;
      final parentData =
          child.parentData as SkillEdgeParentData<EdgeType, IdType>;

      return EdgeDetails<EdgeType, NodeType, IdType>(
        child: child,
        parentData: parentData,
        edge: edge,
      );
    }).toList();

    delegate.layoutEdges(
      loosenedConstraints,
      skillNodeLayout,
      graph,
      edgeChildrenDetails,
      nodeChildrenDetails,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // TODO: Should I use composite layers? What is their benefit?
    // TODO: Draw paintOverflows here.
    final constraintsRect = offset & constraints.biggest;
    final treeRect = offset & size;

    if (constraintsRect.expandToInclude(treeRect) != constraintsRect) {
      paintOverflowIndicator(
        context,
        offset,
        constraintsRect,
        treeRect,
      );
    }

    /// Draw the edges lines
    for (final edge in graph.edges) {
      final child =
          childForEdge(edge) as RenderEdgeLine<EdgeType, NodeType, IdType>;
      final childParentData =
          child.parentData as SkillEdgeParentData<EdgeType, IdType>;

      context.paintChild(
        child,
        childParentData.offset + offset,
      );
    }

    for (final node in graph.nodes) {
      final child = childForNode(node);
      final childParentData =
          child.parentData as SkillNodeParentData<NodeType, IdType>;

      context.paintChild(
        child,
        childParentData.offset + offset,
      );
    }

    /// Draw the edges ends.
    for (final edge in graph.edges) {
      final child =
          childForEdge(edge) as RenderEdgeLine<EdgeType, NodeType, IdType>;
      final childParentData =
          child.parentData as SkillEdgeParentData<EdgeType, IdType>;

      child.defaultPaint(context, childParentData.offset + offset);
    }
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  RenderBox childForNode(Node<NodeType, IdType> node) {
    return nodeChildren.singleWhere((child) {
      final parentData =
          child.parentData as SkillNodeParentData<NodeType, IdType>;

      return parentData.id == node.id;
    });
  }

  RenderBox childForEdge(Edge<EdgeType, IdType> edge) {
    return edgeChildren.singleWhere((child) {
      final parentData =
          child.parentData as SkillEdgeParentData<EdgeType, IdType>;

      return parentData.id == edge.id;
    });
  }

  // TODO: memoize this or something. Don't want to getChildrenAsList every time
  List<RenderBox> get nodeChildren {
    return getChildrenAsList().where((child) {
      return child.parentData is SkillNodeParentData<NodeType, IdType>;
    }).toList();
  }

  List<RenderBox> get edgeChildren {
    return getChildrenAsList().where((child) {
      return child.parentData is SkillEdgeParentData<EdgeType, IdType>;
    }).toList();
  }
}

// TODO: I'm not a fan of these rather useless classes.
// Should I bring in tuple?
abstract class ChildDetails<ParentDataType extends ParentData> {
  const ChildDetails();

  RenderBox get child;

  ParentDataType get parentData;
}

class NodeDetails<NodeType, IdType extends Object>
    extends ChildDetails<SkillNodeParentData<NodeType, IdType>> {
  const NodeDetails({
    required this.child,
    required this.parentData,
    required this.node,
  });

  @override
  final RenderBox child;

  @override
  final SkillNodeParentData<NodeType, IdType> parentData;

  final Node<NodeType, IdType> node;
}

class EdgeDetails<EdgeType, NodeType, IdType extends Object>
    extends ChildDetails<SkillEdgeParentData<EdgeType, IdType>> {
  const EdgeDetails({
    required this.child,
    required this.parentData,
    required this.edge,
  });

  @override
  final RenderEdgeLine<EdgeType, NodeType, IdType> child;

  @override
  final SkillEdgeParentData<EdgeType, IdType> parentData;

  final Edge<EdgeType, IdType> edge;
}
