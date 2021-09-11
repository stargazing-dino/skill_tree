import 'package:meta/meta.dart';

// TODO: This assumes a directed graph. Is that a problem? Aren't most skill
// trees directed? I can also make an undirected graph and have a super type of
// Edge.
/// T goes from being an `IdType` to being a `Node<NodeType, IdType>` when
/// imeplemented by `SkillEdge` hence the ambiguous T here.
@immutable
@sealed
class Edge<EdgeType, IdType> {
  const Edge({
    this.data,
    required this.from,
    required this.to,
  });

  final EdgeType? data;

  final IdType from;

  final IdType to;

  String get id => '$from-$to';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Edge<EdgeType, IdType> &&
        other.data == data &&
        other.from == from &&
        other.to == to;
  }

  @override
  int get hashCode => data.hashCode ^ from.hashCode ^ to.hashCode;

  @override
  String toString() => 'Edge(data: $data, from: $from, to: $to)';
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
