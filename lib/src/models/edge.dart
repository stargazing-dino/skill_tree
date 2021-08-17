import 'package:meta/meta.dart';

// TODO: This assumes a directed graph. Is that a problem? Aren't most skill
// trees directed? I can also make an undirected graph and have a super type of
// Edge.
/// T goes from being an `IdType` to being a `Node<NodeType, IdType>` when
/// imeplemented by `SkillEdge` hence the ambiguous T here.
@sealed
class Edge<EdgeType, T> {
  Edge({
    this.data,
    required this.from,
    required this.to,
  });

  final EdgeType? data;

  final T from;

  final T to;
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
