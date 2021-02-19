import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:skill_tree/skill_tree.dart';

@immutable
class SkillGroup<T, R extends Object> {
  final List<SkillNode<T, R>> nodes;

  final bool isLocked;

  const SkillGroup({
    required this.nodes,
    required this.isLocked,
  });

  SkillGroup<T, R> copyWith({
    List<SkillNode<T, R>>? nodes,
    bool? isLocked,
  }) {
    return SkillGroup<T, R>(
      nodes: nodes ?? this.nodes,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nodes': nodes.map((x) => x.toMap()).toList(),
      'isLocked': isLocked,
    };
  }

  factory SkillGroup.fromMap(Map<String, dynamic> map) {
    return SkillGroup<T, R>(
      nodes: List<SkillNode<T, R>>.from(
          map['nodes']?.map((x) => SkillNode<T, R>.fromMap(x))),
      isLocked: map['isLocked'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SkillGroup.fromJson(String source) =>
      SkillGroup.fromMap(json.decode(source));

  @override
  String toString() => 'SkillGroup(nodes: $nodes, isLocked: $isLocked)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return o is SkillGroup<T, R> &&
        listEquals(o.nodes, nodes) &&
        o.isLocked == isLocked;
  }

  @override
  int get hashCode => nodes.hashCode ^ isLocked.hashCode;
}
