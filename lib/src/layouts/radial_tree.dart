import 'package:skill_tree/skill_tree.dart';
import 'package:skill_tree/src/delegates/radial_tree_delegate.dart';
import 'package:skill_tree/src/models/graph.dart';

// A circular skill tree. I know there's a game that does this, but I'm not
// sure which.
class RenderRadialLayout<EdgeType, NodeType, IdType extends Object>
    extends RenderSkillTree<EdgeType, NodeType, IdType> {
  RenderRadialLayout({
    required Graph<EdgeType, NodeType, IdType> graph,
    required RadialTreeDelegate<IdType> delegate,
  })  : _delegate = delegate,
        super(graph: graph);

  @override
  RadialTreeDelegate<IdType> get delegate => _delegate;
  RadialTreeDelegate<IdType> _delegate;
  set delegate(RadialTreeDelegate<IdType> delegate) {
    if (delegate == _delegate) return;
    _delegate = delegate;
    markNeedsLayout();
  }

  @override
  void layoutNodes() {
    // TODO: implement layoutNodes
  }
}
