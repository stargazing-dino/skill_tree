import 'package:skill_tree/skill_tree.dart';
import 'package:skill_tree/src/delegates/directed_tree_delegate.dart';
import 'package:skill_tree/src/models/graph.dart';

/// A graph whose nodes are repulsed from others
/// See here https://pub.dev/packages/graphview#directed-graph
///
/// This RenderObject works by layers. It passes each layer (including the
/// min intrinsic width and height of each node) to the [LayoutDelegate]
/// `layoutLayer` where the sizes and postions of each node must be returned.
class RenderDirectedTree<EdgeType, NodeType, IdType extends Object>
    extends RenderSkillTree<EdgeType, NodeType, IdType> {
  RenderDirectedTree({
    required Graph<EdgeType, NodeType, IdType> graph,
    required DirectedTreeDelegate<IdType> delegate,
  })  : _delegate = delegate,
        super(graph: graph);

  @override
  DirectedTreeDelegate<IdType> get delegate => _delegate;
  DirectedTreeDelegate<IdType> _delegate;
  set delegate(DirectedTreeDelegate<IdType> delegate) {
    if (delegate == _delegate) return;
    _delegate = delegate;
    markNeedsLayout();
  }

  @override
  void layoutNodes() {
    // TODO: implement layoutNodes
  }
}
