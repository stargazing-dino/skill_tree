import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:skill_tree/src/models/empty_skill_node.dart';

// TODO: Their should be base class above skill_node and empty_skill node
// that handles serialization and all that. That was skill_node can have it's
// data be non-null in a not weird and hacky way

@immutable
class SkillNode<T, R> {
  final ValueKey<T> key;

  final List<SkillNode<T, R>> children;

  final R data;

  final bool isLocked;

  final ValueKey<T>? parentKey;

  const SkillNode({
    required this.key,
    required this.children,
    required this.data,
    this.isLocked = false,
    this.parentKey,
  });

  SkillNode<T, R> copyWith({
    ValueKey<T>? key,
    List<SkillNode<T, R>>? children,
    R? data,
    bool? isLocked,
    ValueKey<T>? parentKey,
  }) {
    return SkillNode<T, R>(
      key: key ?? this.key,
      children: children ?? this.children,
      data: data ?? this.data,
      isLocked: isLocked ?? this.isLocked,
      parentKey: parentKey ?? this.parentKey,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key.value,
      'children': children.map((data) => data.toMap()).toList(),
      'data': data,
      'isLocked': isLocked,
      'parentKey': parentKey?.value,
    };
  }

  factory SkillNode.fromMap(Map<String, dynamic> map) {
    return SkillNode<T, R>(
      key: ValueKey<T>(map['key']),
      children: List<SkillNode<T, R>>.from(
        (map['children'] as List<Map<String, dynamic>>).map(
          (map) {
            if (map['data'] == null) {
              return EmptySkillNode.fromMap(map);
            } else {
              return SkillNode.fromMap(map);
            }
          },
        ),
      ),
      data: map['data'],
      isLocked: map['isLocked'] ?? false,
      parentKey:
          map['parentKey'] == null ? null : ValueKey<T>(map['parentKey']),
    );
  }

  String toJson() => json.encode(toMap());

  factory SkillNode.fromJson(String source) =>
      SkillNode.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SkillNode(key: $key, children: $children, data: $data, isLocked: $isLocked, parentKey: $parentKey)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return o is SkillNode<T, R> &&
        o.key == key &&
        listEquals(o.children, children) &&
        o.data == data &&
        o.isLocked == isLocked &&
        o.parentKey == parentKey;
  }

  @override
  int get hashCode {
    return key.hashCode ^
        children.hashCode ^
        data.hashCode ^
        isLocked.hashCode ^
        parentKey.hashCode;
  }
}
