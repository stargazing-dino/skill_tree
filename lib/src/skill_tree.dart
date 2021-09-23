import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:skill_tree/skill_tree.dart';
import 'package:skill_tree/src/delegates/layered_tree_delegate.dart';
import 'package:skill_tree/src/delegates/positioned_tree_delegate.dart';
import 'package:skill_tree/src/delegates/radial_tree_delegate.dart';
import 'package:skill_tree/src/graphs/layered_graph.dart';
import 'package:skill_tree/src/graphs/positioned_graph.dart';
import 'package:skill_tree/src/graphs/radial_graph.dart';
import 'package:skill_tree/src/layouts/layered_tree.dart';
import 'package:skill_tree/src/layouts/positioned_tree.dart';
import 'package:skill_tree/src/layouts/radial_tree.dart';
import 'package:skill_tree/src/models/delegate.dart';
import 'package:skill_tree/src/models/edge.dart';
import 'package:skill_tree/src/models/graph.dart';
import 'package:skill_tree/src/models/node.dart';
import 'package:skill_tree/src/skill_edge.dart';
import 'package:skill_tree/src/skill_node.dart';
import 'package:skill_tree/src/utils/get_alignment_for_angle.dart';
import 'package:skill_tree/src/widgets/edge_line.dart';
import 'package:skill_tree/src/widgets/skill_vertex.dart';

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
    this.nodeBuilder,
    this.edgeBuilder,
  }) : super(
          key: key,
          children: <Widget>[
            ...nodes.map((node) {
              final graph = getGraph<EdgeType, NodeType, IdType>(
                nodes: nodes,
                edges: edges,
                delegate: delegate,
              );

              return nodeBuilder?.call(node, graph) ??
                  defaultSkillNodeBuilder(node, graph);
            }),
            ...edges.map(
              (edge) {
                return edgeBuilder?.call(edge) ??
                    defaultSkillEdgeBuilder<EdgeType, NodeType, IdType>(edge);
              },
            ),
          ],
        );

  final List<Node<NodeType, IdType>> nodes;

  final List<Edge<EdgeType, IdType>> edges;

  final SkillTreeDelegate<IdType> delegate;

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

  // TODO: This should be in its own class that handles all things drawing
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

  Graph<EdgeType, NodeType, IdType> get graph {
    return getGraph<EdgeType, NodeType, IdType>(
      nodes: nodes,
      edges: edges,
      delegate: delegate,
    );
  }

  static Graph<EdgeType, NodeType, IdType>
      getGraph<EdgeType, NodeType, IdType extends Object>({
    required List<Edge<EdgeType, IdType>> edges,
    required List<Node<NodeType, IdType>> nodes,
    required SkillTreeDelegate<IdType> delegate,
  }) {
    if (delegate is PositionedTreeDelegate<IdType>) {
      return PositionedGraph<EdgeType, NodeType, IdType>(
        nodes: nodes,
        edges: edges,
      );
    } else if (delegate is RadialTreeDelegate<IdType>) {
      return RadialGraph<EdgeType, NodeType, IdType>(
        nodes: nodes,
        edges: edges,
      );
    } else if (delegate is LayeredTreeDelegate<IdType>) {
      return LayeredGraph<EdgeType, NodeType, IdType>(
        nodes: nodes,
        edges: edges,
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
    if (renderObject is RenderPositionedLayout<EdgeType, NodeType, IdType>) {
      renderObject
        ..graph = graph
        ..delegate = delegate as PositionedTreeDelegate<IdType>;
    } else if (renderObject is RenderRadialLayout<EdgeType, NodeType, IdType>) {
      renderObject
        ..graph = graph
        ..delegate = delegate as RadialTreeDelegate<IdType>;
    } else if (renderObject
        is RenderLayeredLayout<EdgeType, NodeType, IdType>) {
      renderObject
        ..graph = graph
        ..delegate = delegate as LayeredTreeDelegate<IdType>;
    } else {
      throw ArgumentError(
        'Unknown renderObject $renderObject is not a supported type.',
      );
    }
  }

  // We create a render object instead of a [CustomMultiChildLayout]
  // because we want to define our own ParentData necessary for the layout.
  @override
  RenderObject createRenderObject(BuildContext context) {
    final _delegate = delegate;

    if (_delegate is PositionedTreeDelegate<IdType>) {
      return RenderPositionedLayout<EdgeType, NodeType, IdType>(
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

class SkillParentData extends ContainerBoxParentData<RenderBox> {}

/// This class provides useful abstractions across both the graph theory model
/// and the render model.
///
/// This class can be considered a sort of [MultiChildLayoutDelegate]. However,
/// it is not for technical reasons. One of them being that using a
/// [MultChildCustomLayout] doesn't allow for setting the layout size based
/// on the sizes of the children. Instead of that, therefore, we just define new
/// layouts by implementing this class and creating a custom [RenderBox]
abstract class RenderSkillTree<EdgeType, NodeType, IdType extends Object>
    extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SkillParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SkillParentData>,
        DebugOverflowIndicatorMixin {
  // TODO: Different sub type graph types will not auto update layout unless we
  // specify that in their respective renderObject thing.
  RenderSkillTree({required Graph<EdgeType, NodeType, IdType> graph})
      : _graph = graph;

  Graph<EdgeType, NodeType, IdType> _graph;
  Graph<EdgeType, NodeType, IdType> get graph => _graph;
  set graph(Graph<EdgeType, NodeType, IdType> graph) {
    if (_graph == graph) return;
    _graph = graph;
    markNeedsLayout();
  }

  SkillTreeDelegate<IdType> get delegate;

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! SkillParentData) {
      child.parentData = SkillParentData();
    }
  }

  void layoutNodes();

  @override
  void performLayout() {
    // TODO: Edges need to know the amount of space in the gutter available to
    // them. Using that information, we can better constrain them when it comes
    // to layout. I recommend we create a function template that takes in a node
    // and returns the amount of space around it like so:
    //  double getSpaceAroundNode(Node node) {
    //    return node.spaceAround;
    //  }
    layoutNodes();

    /// We need to layout edges. However, an edge is not a direct RenderObject.
    /// Instead, it is a MultiChildRenderObject. Therefore, we must position
    /// the edges first based off the nodes.
    ///
    /// The positions and sizes of both edge terminals are needed to layout
    /// this edge.
    for (final edge in graph.edges) {
      final edgeChild =
          childForEdge(edge) as RenderEdgeLine<EdgeType, NodeType, IdType>;
      final edgeParentData = edgeChild.parentData
          as SkillEdgeParentData<EdgeType, NodeType, IdType>;
      final to = childForNode(graph.getNodeFromIdType(edge.to));
      final toParentData = to.parentData as SkillParentData;
      final toRect = toParentData.offset & to.size;
      final from = childForNode(graph.getNodeFromIdType(edge.from));
      final fromParentData = from.parentData as SkillParentData;
      final fromRect = fromParentData.offset & from.size;

      assert(
        toRect.intersect(fromRect).isEmpty,
        'Two nodes must not intersect one another.',
      );

      /// Specify in a 2d space where the "to" Node is relative to the "from"
      /// node. (This will be used to orient the edge line and better draw
      /// the vertex).
      ///
      /// We get a vector moving from "from" to "to" and get the direction of the
      /// vector.
      final _toAlignment = edgeParentData.toAlignment ?? Alignment.center;
      final _fromAlignment = edgeParentData.fromAlignment ?? Alignment.center;
      final angle = (_toAlignment.withinRect(fromRect) -
              _fromAlignment.withinRect(toRect))
          .direction;
      final toAlignment =
          (edgeParentData.toAlignment ?? getAlignmentForAngle(angle));
      final fromAlignment = edgeParentData.fromAlignment ?? (toAlignment * -1);

      final children = edgeChild.getChildrenAsList();
      final toEdgeChild = children.singleWhere((child) {
        return child.parentData is SkillVertexToParentData;
      });
      final toEdgeChildParentData =
          toEdgeChild.parentData as SkillVertexParentData;
      final fromEdgeChild = children.singleWhere((child) {
        return child.parentData is SkillVertexFromParentData;
      });
      final fromEdgeChildParentData =
          fromEdgeChild.parentData as SkillVertexParentData;

      // TODO: I shouldn't use getDryLayout here as it has some issues.
      // Do same as tooltip package.
      final toEdgeSize = toEdgeChild.getDryLayout(constraints);
      final fromEdgeSize = fromEdgeChild.getDryLayout(constraints);
      final fromEdgeBox = fromAlignment
              .withinRect(fromRect)
              .translate(-fromEdgeSize.width / 2, -fromEdgeSize.height / 2) &
          fromEdgeSize;
      final toEdgeBox = toAlignment
              .withinRect(toRect)
              .translate(-toEdgeSize.width / 2, -toEdgeSize.height / 2) &
          toEdgeSize;
      final edgeBoundingBox = fromEdgeBox.expandToInclude(toEdgeBox);

      edgeParentData.offset = edgeBoundingBox.topLeft;

      toEdgeChildParentData.addPositionData(
        fromEdgeBox.shift(-edgeBoundingBox.topLeft),
      );
      fromEdgeChildParentData.addPositionData(
        toEdgeBox.shift(-edgeBoundingBox.topLeft),
      );

      // TODO: I'm not setting the constraints properly yet because the current
      // boundingRect does not account for the gutter spacing. Gutter spacing
      // seems dependent on layout type too...
      // draggableEdgeChild.layout(BoxConstraints.tight(boundingRect.size));
      // TODO: Prev todo might not be correct when dragging. A draggable should
      // not have constraints so it can reach even the furthest nodes.
      edgeChild.layout(constraints);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // TODO: Should I use composite layers? What is their benefit?
    // TODO: Draw paintOverflows here.

    for (final edge in graph.edges) {
      final child = childForEdge(edge);
      final childParentData =
          child.parentData as SkillEdgeParentData<EdgeType, NodeType, IdType>;

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

  // TODO: memoize this or something. Don't want to getChildrenAsList every time
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
          child.parentData as SkillEdgeParentData<EdgeType, NodeType, IdType>;

      return parentData.id == edge.id;
    });
  }

  List<RenderBox> get nodeChildren {
    return getChildrenAsList().where((child) {
      return child.parentData is SkillNodeParentData<NodeType, IdType>;
    }).toList();
  }

  List<RenderBox> get edgeChildren {
    return getChildrenAsList().where((child) {
      return child.parentData
          is SkillEdgeParentData<EdgeType, NodeType, IdType>;
    }).toList();
  }
}
