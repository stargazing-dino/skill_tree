import 'package:meta/meta.dart';

// TODO: This assumes a directed graph. Is that a problem? Aren't most skill
// trees directed? I can also make an undirected graph and have a super type of
// Edge.

/// T goes from being an `IdType` to being a `Node<NodeType, IdType>` when
/// imeplemented by `SkillEdge` hence the ambiguous T here.
@immutable
@sealed
class Edge<EdgeType, IdType extends Object> {
  const Edge({
    required this.data,
    required this.from,
    required this.to,
    this.name,
  });

  final EdgeType data;

  final IdType from;

  final IdType to;

  final String? name;

  String get id => '${from.toString()}-${to.toString()}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Edge<EdgeType, IdType> &&
        other.data == data &&
        other.name == name &&
        other.from == from &&
        other.to == to;
  }

  @override
  int get hashCode => data.hashCode ^ from.hashCode ^ to.hashCode;

  @override
  String toString() => 'Edge(data: $data, name: $name, from: $from, to: $to)';
}

extension CastEdge<EdgeType, IdType extends Object> on Edge<EdgeType, IdType> {
  Edge<T, R> cast<T, R extends Object>({
    required T data,
    required String? name,
    required R from,
    required R to,
  }) {
    return Edge<T, R>(
      data: data,
      name: name,
      from: from,
      to: to,
    );
  }
}
