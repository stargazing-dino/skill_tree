import 'package:skill_tree/src/models/edge.dart';
import 'package:skill_tree/src/models/graph.dart';
import 'package:skill_tree/src/models/node.dart';

class RadialGraph<EdgeType, NodeType extends Object, IdType extends Object>
    extends Graph<EdgeType, NodeType, IdType> {
  RadialGraph({
    required this.edges,
    required this.nodes,
  });

  @override
  final List<Edge<EdgeType, Node<NodeType, IdType>>> edges;

  @override
  final List<Node<NodeType, IdType>> nodes;

  @override
  bool debugCheckGraph({
    required List<Edge<EdgeType, Node<NodeType, IdType>>> edges,
    required List<Node<NodeType, IdType>> nodes,
  }) {
    return true;
  }
}
