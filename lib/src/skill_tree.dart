import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:skill_tree/skill_tree.dart';
import 'package:skill_tree/src/graphs/layered_graph.dart';
import 'package:skill_tree/src/graphs/radial_graph.dart';
import 'package:skill_tree/src/models/delegate.dart';
import 'package:skill_tree/src/models/edge.dart';
import 'package:skill_tree/src/models/graph.dart';
import 'package:skill_tree/src/models/node.dart';
import 'package:skill_tree/src/skill_edge.dart';
import 'package:skill_tree/src/skill_node.dart';

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
  SkillTree.layered({
    Key? key,
    required LayeredGraph<EdgeType, NodeType, IdType> graph,
    required this.delegate,
    this.onSave,
    this.serializeNode,
    this.serializeEdge,
    this.deserializeNode,
    this.deserializeEdge,
    this.nodeBuilder,
    this.edgeBuilder,
  })  : _graph = graph,
        super(
          key: key,
          children: <Widget>[
            ...graph.nodes.map((node) {
              return nodeBuilder?.call(node, graph) ??
                  defaultSkillNodeBuilder(node, graph);
            }),
            ...graph.edges.map(
              (edge) {
                return edgeBuilder?.call(edge) ??
                    defaultSkillEdgeBuilder<EdgeType, NodeType, IdType>(edge);
              },
            ),
          ],
        );

  SkillTree.radial({
    Key? key,
    required RadialGraph<EdgeType, NodeType, IdType> graph,
    required this.delegate,
    this.onSave,
    this.serializeNode,
    this.serializeEdge,
    this.deserializeNode,
    this.deserializeEdge,
    this.nodeBuilder,
    this.edgeBuilder,
  })  : _graph = graph,
        super(
          key: key,
          children: <Widget>[
            ...graph.nodes.map((node) {
              return nodeBuilder?.call(node, graph) ??
                  defaultSkillNodeBuilder(node, graph);
            }),
            ...graph.edges.map(
              (edge) {
                return edgeBuilder?.call(edge) ??
                    defaultSkillEdgeBuilder<EdgeType, NodeType, IdType>(edge);
              },
            ),
          ],
        );

  final Graph<EdgeType, NodeType, IdType> _graph;

  final SkillTreeDelegate<EdgeType, NodeType, IdType,
      Graph<EdgeType, NodeType, IdType>> delegate;

  final Function(Map<IdType, dynamic> json)? onSave;

  final Map<IdType, dynamic> Function(NodeType value)? serializeNode;

  final Map<IdType, dynamic> Function(EdgeType value)? serializeEdge;

  final NodeType Function(Map<IdType, dynamic> json)? deserializeNode;

  final EdgeType Function(Map<IdType, dynamic> json)? deserializeEdge;

  final SkillNode<NodeType, IdType> Function(
    Node<NodeType, IdType> node,
    Graph<EdgeType, NodeType, IdType> graph,
  )? nodeBuilder;

  final SkillEdge<EdgeType, NodeType, IdType> Function(
    Edge<EdgeType, IdType> edge,
  )? edgeBuilder;

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

  // TODO: This should be in its own class/mixin/extension that handles all
  // things drawing
  static void defaultEdgePainter({
    required Offset toNodeCenter,
    required Offset fromNodeCenter,
    required List<Rect> allNodeRects,
    required Canvas canvas,
  }) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(fromNodeCenter.dx, fromNodeCenter.dy)
      ..lineTo(toNodeCenter.dx, toNodeCenter.dy);

    canvas.drawPath(path, paint);
    canvas.drawShadow(
      path,
      Colors.grey,
      4,
      false,
    );
  }

  static void defaultCubicEdgePainter({
    required Offset toNodeCenter,
    required Offset fromNodeCenter,
    required List<Rect> allNodeRects,
    required Canvas canvas,
  }) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromPoints(toNodeCenter, fromNodeCenter);
    final double xA, yA, xB, yB;

    // a cubic line looks better when it runs along the narrower side
    if (rect.width < rect.height) {
      xA = toNodeCenter.dx;
      yA = lerpDouble(fromNodeCenter.dy, toNodeCenter.dy, 0.25)!;
      xB = fromNodeCenter.dx;
      yB = lerpDouble(fromNodeCenter.dy, toNodeCenter.dy, 0.75)!;
    } else {
      xA = lerpDouble(fromNodeCenter.dx, toNodeCenter.dx, 0.25)!;
      yA = toNodeCenter.dy;
      xB = lerpDouble(fromNodeCenter.dx, toNodeCenter.dx, 0.75)!;
      yB = fromNodeCenter.dy;
    }

    final path = Path()
      ..moveTo(fromNodeCenter.dx, fromNodeCenter.dy)
      ..cubicTo(xA, yA, xB, yB, toNodeCenter.dx, toNodeCenter.dy);

    canvas.drawPath(path, paint);
  }

  static SkillEdge<EdgeType, NodeType, IdType>
      defaultSkillEdgeBuilder<EdgeType, NodeType, IdType extends Object>(
    Edge<EdgeType, IdType> edge,
  ) {
    if (edge is SkillEdge<EdgeType, NodeType, IdType>) {
      return edge;
    }

    return SkillEdge<EdgeType, NodeType, IdType>(
      edgePainter: defaultCubicEdgePainter,
      toChild: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
        ),
        width: 20,
        height: 20,
      ),
      fromChild: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.yellow,
        ),
        height: 20,
        width: 20,
      ),
      name: edge.name,
      data: edge.data,
      from: edge.from,
      id: edge.id,
      to: edge.to,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) {
    renderObject as RenderSkillTree
      ..graph = _graph
      ..delegate = delegate;
  }

  // We create a render object instead of a [CustomMultiChildLayout]
  // because we want to define our own ParentData necessary for the layout.
  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSkillTree<EdgeType, NodeType, IdType>(
      delegate: delegate,
      graph: _graph,
    );
  }
}

class SkillParentData extends ContainerBoxParentData<RenderBox> {}

/// This class provides useful abstractions across both the graph theory model
/// and the render model.
///
/// This class can be considered a sort of [MultiChildLayoutDelegate]. However,
/// it is not for technical reasons. One of them being that using a
/// [MultChildCustomLayout] doesn't allow for setting the layout size based
/// on the sizes of the children. Instead of that, therefore, we just define new
/// layouts by implementing this class and creating a custom [RenderBox]
class RenderSkillTree<EdgeType, NodeType, IdType extends Object>
    extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SkillParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SkillParentData>,
        DebugOverflowIndicatorMixin {
  RenderSkillTree({
    required Graph<EdgeType, NodeType, IdType> graph,
    required SkillTreeDelegate<EdgeType, NodeType, IdType,
            Graph<EdgeType, NodeType, IdType>>
        delegate,
  })  : _graph = graph,
        _delegate = delegate;

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
    _delegate = delegate;

    if (delegate.runtimeType != _delegate.runtimeType ||
        delegate.shouldRelayout(_delegate)) {
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! SkillParentData) {
      child.parentData = SkillParentData();
    }
  }

  @override
  void performLayout() {
    final loosenedConstraints = constraints.loosen();

    final skillNodeLayout = delegate.layoutNodes(
      loosenedConstraints,
      graph,
    );

    delegate.layoutEdges(constraints, skillNodeLayout, graph);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // TODO: Should I use composite layers? What is their benefit?
    // TODO: Draw paintOverflows here.

    for (final edge in graph.edges) {
      final child = childForEdge(edge);
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

class EdgeDetails<EdgeType, IdType extends Object>
    extends ChildDetails<SkillEdgeParentData<EdgeType, IdType>> {
  const EdgeDetails({
    required this.child,
    required this.parentData,
    required this.edge,
  });

  @override
  final RenderBox child;

  @override
  final SkillEdgeParentData<EdgeType, IdType> parentData;

  final Edge<EdgeType, IdType> edge;
}
