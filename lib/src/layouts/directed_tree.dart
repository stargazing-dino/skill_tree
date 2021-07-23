import 'package:skill_tree/src/models/delegate.dart';
import 'package:skill_tree/src/models/graph.dart';
import 'package:skill_tree/src/skill_tree.dart';

class DirectedTreeDelegate extends SkillTreeDelegate {}

/// A graph whose nodes are repulsed from others
/// See here https://pub.dev/packages/graphview#directed-graph
class RenderDirectedTree<EdgeType, NodeType>
    extends RenderSkillTree<EdgeType, NodeType> {
  RenderDirectedTree({
    required Graph<EdgeType, NodeType> graph,
    required this.delegate,
  }) : super(graph);

  final DirectedTreeDelegate delegate;

  /// This RenderObject works by layers. It passes each layer (including the
  /// min intrinsic width and height of each node) to the [LayoutDelegate]
  /// `layoutLayer` where the sizes and postions of each node must be returned.
  @override
  void performLayout() {
    //
  }
}
