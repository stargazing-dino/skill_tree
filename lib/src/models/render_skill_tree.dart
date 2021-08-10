part of '../skill_tree.dart';

/// This class can be considered a sort of [MultiChildLayoutDelegate]. However, it
/// is not for technical reasons. One of them being that using a
/// [MultChildCustomLayout] doesn't allow for setting the layout size based
/// on the sizes of the children. Instead of that, therefore, we just define new
/// layouts by implementing this class and creating a custom [RenderBox]
abstract class RenderSkillTree<EdgeType, NodeType extends Object,
        IdType extends Object> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SkillNodeParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SkillNodeParentData> {
  RenderSkillTree({
    required Graph<EdgeType, NodeType, IdType> graph,
    required SkillTreeDelegate delegate,
  })  : _graph = graph,
        _delegate = delegate;

  Graph<EdgeType, NodeType, IdType> _graph;
  Graph<EdgeType, NodeType, IdType> get graph => _graph;
  set graph(Graph<EdgeType, NodeType, IdType> graph) {
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
  RenderBox childForNode(Node<NodeType, IdType> node) {
    return getChildrenAsList().singleWhere((child) {
      final parentData = child.parentData as SkillNodeParentData;
      return parentData.id == node.id;
    });
  }

  // TODO: This is not yet implemented because I currently don't know how I'm
  // going to handle edges and their painting.
  static SkillEdge<EdgeType, NodeType, IdType> defaultEdgeBuilder<
      EdgeType extends Object, NodeType extends Object, IdType extends Object>(
    Edge<EdgeType, Node<NodeType, IdType>> edge,
  ) {
    if (edge is SkillEdge<EdgeType, NodeType, IdType>) {
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
