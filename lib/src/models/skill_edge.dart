abstract class BaseSkillEdge<EdgeType, NodeType> {
  EdgeType? get data;

  NodeType get from;

  NodeType get to;
}

class SkillEdge<EdgeType, NodeType> {
  final EdgeType? data;

  final NodeType from;

  final NodeType to;

  SkillEdge({
    this.data,
    required this.from,
    required this.to,
  });

  SkillEdge<EdgeType, NodeType> copyWith({
    EdgeType? data,
    NodeType? from,
    NodeType? to,
  }) {
    return SkillEdge<EdgeType, NodeType>(
      data: data ?? this.data,
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }

  SkillEdge<T, R> cast<T, R>({
    required T? data,
    required R from,
    required R to,
  }) {
    return SkillEdge<T, R>(
      data: data,
      from: from,
      to: to,
    );
  }
}
