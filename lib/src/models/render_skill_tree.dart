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

  void layoutNodes();

  @override
  void performLayout() {
    layoutNodes();

    // We are going to create our [DraggableEdge]'s here with the proper layout.
    for (final edge in graph.edges) {
      final draggableEdgeChild =
          childForEdge(edge) as RenderDraggableEdge<NodeType, IdType>;
      final draggableEdgeParentData =
          draggableEdgeChild.parentData as SkillParentData;
      final children = draggableEdgeChild.getChildrenAsList();
      final toChildParentData = children.singleWhere((child) {
        final parentData =
            child.parentData as PointParentData<NodeType, IdType>;

        return parentData.isTo!;
      }).parentData as PointParentData<NodeType, IdType>;
      final fromChildParentData = children.singleWhere((child) {
        final parentData =
            child.parentData as PointParentData<NodeType, IdType>;

        return !parentData.isTo!;
      }).parentData as PointParentData<NodeType, IdType>;
      final to = childForNode(edge.to);
      final toParentData = to.parentData as SkillParentData;
      final toRect = toParentData.offset & to.size;
      final from = childForNode(edge.from);
      final fromParentData = from.parentData as SkillParentData;
      final fromRect = fromParentData.offset & from.size;
      final toSkillNode =
          toParentData.skillWidget as SkillNode<NodeType, IdType>;
      final fromSkillNode =
          fromParentData.skillWidget as SkillNode<NodeType, IdType>;
      assert(toRect.intersect(fromRect).isEmpty);

      toChildParentData.addPositionData(node: toSkillNode, rect: toRect);
      fromChildParentData.addPositionData(node: fromSkillNode, rect: fromRect);

      final boundingRect = getLargestBoundingRect(toRect, fromRect);

      draggableEdgeParentData.offset = boundingRect.topLeft;

      draggableEdgeChild.layout(BoxConstraints.tight(boundingRect.size));
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    for (final edge in graph.edges) {
      final child = childForEdge(edge);
      final childParentData = child.parentData as SkillParentData;

      context.paintChild(child, childParentData.offset + offset);
    }

    for (final node in graph.nodes) {
      final child = childForNode(node);
      final childParentData = child.parentData as SkillParentData;

      context.paintChild(child, childParentData.offset + offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  // TODO: memoize this or something. Don't want to getChildrenAsList every time
  RenderBox childForNode(Node<NodeType, IdType> node) {
    return nodeChildren.singleWhere((child) {
      final parentData = child.parentData as SkillParentData;
      final widget = parentData.skillWidget as SkillNode<NodeType, IdType>;

      return widget.id == node.id;
    });
  }

  RenderBox childForEdge(Edge<EdgeType, Node<NodeType, IdType>> edge) {
    return edgeChildren.singleWhere((child) {
      final parentData = child.parentData as SkillParentData;
      final widget =
          parentData.skillWidget as SkillEdge<EdgeType, NodeType, IdType>;

      return widget.id == edge.id;
    });
  }

  List<RenderBox> get nodeChildren {
    return getChildrenAsList().where((child) {
      final parentData = child.parentData as SkillParentData;

      return parentData.skillWidget is SkillNode<NodeType, IdType>;
    }).toList();
  }

  List<RenderBox> get edgeChildren {
    return getChildrenAsList().where((child) {
      final parentData = child.parentData as SkillParentData;

      return parentData.skillWidget is SkillEdge<EdgeType, NodeType, IdType>;
    }).toList();
  }
}
