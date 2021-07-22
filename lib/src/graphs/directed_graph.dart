import 'package:skill_tree/src/models/edge.dart';
import 'package:skill_tree/src/models/graph.dart';
import 'package:skill_tree/src/models/node.dart';

/// This a class to hold logic related to a graph and its operations and should
/// NOT be in any way related to UI or rendering.
class DirectedGraph<EdgeType, NodeType> extends Graph<EdgeType, NodeType> {
  DirectedGraph({
    required this.edges,
    required this.nodes,
  });

  @override
  final List<Edge<EdgeType, Node<NodeType>>> edges;

  @override
  final List<Node<NodeType>> nodes;
}
