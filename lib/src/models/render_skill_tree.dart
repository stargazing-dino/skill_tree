part of '../skill_tree.dart';

/// This class can be considered a sort of [MultiChildLayoutDelegate]. However,
/// it is not for technical reasons. One of them being that using a
/// [MultChildCustomLayout] doesn't allow for setting the layout size based
/// on the sizes of the children. Instead of that, therefore, we just define new
/// layouts by implementing this class and creating a custom [RenderBox]
abstract class RenderSkillTree<EdgeType, NodeType extends Object,
        IdType extends Object> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SkillParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SkillParentData> {
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
    // child.metaData.
    // child.metaData.widget
    if (child.parentData is! SkillParentData) {
      child.parentData = SkillParentData();
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
    return nodeChildren.singleWhere((child) {
      final parentData = child.parentData as SkillNodeParentData<IdType>;
      return parentData.id == node.id;
    });
  }

  List<RenderBox> get nodeChildren {
    return getChildrenAsList().where((child) {
      return child.parentData is SkillNodeParentData<IdType>;
    }).toList();
  }

  List<RenderBox> get edgeChildren {
    return getChildrenAsList().where((child) {
      return child.parentData is SkillEdgeParentData;
    }).toList();
  }

  // TODO: This is not yet implemented because I currently don't know how I'm
  // going to handle edges and their painting.
}
