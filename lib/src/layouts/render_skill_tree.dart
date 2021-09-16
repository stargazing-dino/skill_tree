part of '../skill_tree.dart';

/// This class provides useful abstractions across both the graph theory model
/// and the render model.
///
/// This class can be considered a sort of [MultiChildLayoutDelegate]. However,
/// it is not for technical reasons. One of them being that using a
/// [MultChildCustomLayout] doesn't allow for setting the layout size based
/// on the sizes of the children. Instead of that, therefore, we just define new
/// layouts by implementing this class and creating a custom [RenderBox]
abstract class RenderSkillTree<EdgeType extends Object, NodeType extends Object,
        IdType extends Object> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SkillParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SkillParentData>,
        DebugOverflowIndicatorMixin {
  RenderSkillTree({
    required Graph<EdgeType, NodeType, IdType> graph,
    required SkillTreeDelegate<IdType> delegate,
  })  : _graph = graph,
        _delegate = delegate;

  Graph<EdgeType, NodeType, IdType> _graph;
  Graph<EdgeType, NodeType, IdType> get graph => _graph;
  set graph(Graph<EdgeType, NodeType, IdType> graph) {
    if (_graph == graph) return;
    _graph = graph;
    markNeedsLayout();
  }

  SkillTreeDelegate<IdType> _delegate;
  SkillTreeDelegate<IdType> get delegate => _delegate;
  set delegate(SkillTreeDelegate<IdType> delegate) {
    if (_delegate == delegate) return;
    _delegate = delegate;
    markNeedsLayout();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! SkillParentData) {
      child.parentData = SkillParentData();
    }
  }

  Offset? edgeOffset;

  void layoutNodes();

  @override
  void performLayout() {
    layoutNodes();

    for (final edge in graph.edges) {
      final draggableEdgeChild =
          childForEdge(edge) as RenderDraggableEdge<EdgeType, NodeType, IdType>;
      final draggableEdgeParentData =
          draggableEdgeChild.parentData as SkillEdgeParentData;

      /// The positions of every node are needed
      draggableEdgeParentData.nodePositions = nodeChildren;

      final children = draggableEdgeChild.getChildrenAsList();
      final toChildParentData = children.singleWhere((child) {
        final parentData = child.parentData as VertexParentData;

        return parentData.isTo!;
      }).parentData as VertexParentData;
      final fromChildParentData = children.singleWhere((child) {
        final parentData = child.parentData as VertexParentData;

        return !parentData.isTo!;
      }).parentData as VertexParentData;
      final to = childForNode(edge.to);
      final toParentData = to.parentData as SkillParentData;
      final toRect = toParentData.offset & to.size;
      final from = childForNode(edge.from);
      final fromParentData = from.parentData as SkillParentData;
      final fromRect = fromParentData.offset & from.size;
      assert(toRect.intersect(fromRect).isEmpty);

      final boundingRect = getLargestBoundingRect(toRect, fromRect);

      // Right now toRect and fromRect are in global coordinates from inside
      // this render object. We need to convert them to local coordinates by
      // subtracting the largest bounding box top-left corner.

      final edgeOffset = boundingRect.topLeft;

      toChildParentData.addPositionData(toRect.shift(-edgeOffset));
      fromChildParentData.addPositionData(fromRect.shift(-edgeOffset));

      draggableEdgeParentData.offset = edgeOffset;

      draggableEdgeChild.layout(BoxConstraints.tight(boundingRect.size));
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
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

  RenderBox childForEdge(Edge<EdgeType, Node<NodeType, IdType>> edge) {
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
