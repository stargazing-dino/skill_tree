import 'package:skill_tree/skill_tree.dart';
import 'package:skill_tree/src/delegates/positioned_tree_delegate.dart';
import 'package:skill_tree/src/models/graph.dart';

// A circular skill tree. I know there's a game that does this, but I'm not
// sure which.
class RenderPositionedLayout<EdgeType, NodeType, IdType extends Object>
    extends RenderSkillTree<EdgeType, NodeType, IdType> {
  RenderPositionedLayout({
    required Graph<EdgeType, NodeType, IdType> graph,
    required PositionedTreeDelegate<IdType> delegate,
  })  : _delegate = delegate,
        super(graph: graph);

  @override
  PositionedTreeDelegate<IdType> get delegate => _delegate;
  PositionedTreeDelegate<IdType> _delegate;
  set delegate(PositionedTreeDelegate<IdType> delegate) {
    if (delegate == _delegate) return;
    _delegate = delegate;
    markNeedsLayout();
  }

  @override
  void layoutNodes() {
    // TODO: implement layoutNodes
  }
}
