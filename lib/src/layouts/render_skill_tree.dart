part of '../skill_tree.dart';

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
  // TODO: Different graph types will not auto update layout unless we specify
  // that in their respective renderObject thing.
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

  Offset? paintOffset;

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! SkillParentData) {
      child.parentData = SkillParentData();
    }
  }

  void layoutNodes();

  @override
  void performLayout() {
    layoutNodes();

    /// We need to layout edges. However, an edge is not a direct RenderObject.
    /// Instead, it is a MultiChildRenderObject. Therefore, we must position
    /// the edges first based off the nodes.
    ///
    /// We'll do so by getting the size and position of both node boxes
    /// and then creating a bounding box based off those.
    for (final edge in graph.edges) {
      /// The positions of both terminal nodes are needed to layout the edge.
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

      final draggableEdgeChild =
          childForEdge(edge) as RenderDraggableEdge<EdgeType, NodeType, IdType>;
      final draggableEdgeParentData =
          draggableEdgeChild.parentData as SkillEdgeParentData;
      final boundingRect = getLargestBoundingRect(toRect, fromRect);
      final edgeOffset = boundingRect.topLeft;

      draggableEdgeParentData.offset = edgeOffset;

      /// We need to manually set the sizes of the nodePositions to be used by
      /// the edge's parentData.
      final children = draggableEdgeChild.getChildrenAsList();
      final toChildParentData = children.singleWhere((child) {
        return child.parentData is SkillVertexToParentData;
      }).parentData as SkillVertexToParentData;
      final fromChildParentData = children.singleWhere((child) {
        return child.parentData is SkillVertexFromParentData;
      }).parentData as SkillVertexFromParentData;

      // Right now toRect and fromRect are in global coordinates from inside
      // this render object. We need to convert them to local coordinates by
      // subtracting the largest bounding box top-left corner.
      toChildParentData.addPositionData(toRect.shift(-edgeOffset));
      fromChildParentData.addPositionData(fromRect.shift(-edgeOffset));

      draggableEdgeChild.layout(BoxConstraints.tight(boundingRect.size));
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    paintOffset = offset;

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
