part of '../skill_tree.dart';

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
