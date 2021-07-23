import 'package:skill_tree/src/models/edge.dart';
import 'package:skill_tree/src/models/graph.dart';
import 'package:skill_tree/src/models/node.dart';

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
