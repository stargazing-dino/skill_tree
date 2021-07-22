import 'package:meta/meta.dart';

// TODO: This assumes a directed graph. Is that a problem? Aren't most skill
// trees directed? I can also make an undirected graph and have a super type of
// Edge.
@sealed
class Edge<EdgeType, NodeType> {
  Edge({
    this.data,
    required this.from,
    required this.to,
  });

  final EdgeType? data;

  final NodeType from;

  final NodeType to;
}

extension CastEdge<EdgeType, NodeType> on Edge<EdgeType, NodeType> {
  Edge<T, R> cast<T, R>({
    required T? data,
    required R from,
    required R to,
  }) {
    return Edge<T, R>(
      data: data,
      from: from,
      to: to,
    );
  }
}
