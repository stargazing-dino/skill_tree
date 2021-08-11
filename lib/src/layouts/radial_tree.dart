import 'package:skill_tree/skill_tree.dart';
import 'package:skill_tree/src/delegates/radial_tree_delegate.dart';
import 'package:skill_tree/src/models/graph.dart';

// A circular skill tree. I know there's a game that does this, but I'm not
// sure which.
class RenderRadialLayout<EdgeType, NodeType extends Object,
    IdType extends Object> extends RenderSkillTree<EdgeType, NodeType, IdType> {
  RenderRadialLayout({
    required Graph<EdgeType, NodeType, IdType> graph,
    required this.delegate,
  }) : super(graph: graph, delegate: delegate);

  @override
  final RadialTreeDelegate<IdType> delegate;

  @override
  void performLayout() {
    super.performLayout();
  }
}
