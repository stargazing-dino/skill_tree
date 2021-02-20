import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skill_tree/src/models/base_node.dart';
import 'package:skill_tree/src/models/empty_skill_node.dart';

@immutable
class SkillNode<T extends Object, R extends Object> extends BaseNode<T> {
  final R data;

  SkillNode({
    required T key,
    required List<BaseNode<T>> children,
    required this.data,
    bool isLocked = false,
    T? parentKey,
  }) : super(
          key: key,
          children: children,
          parentKey: parentKey,
          isLocked: isLocked,
        );

  @override
  SkillNode<T, R> copyWith({
    T? key,
    List<BaseNode<T>>? children,
    R? data,
    bool? isLocked,
    T? parentKey,
  }) {
    return SkillNode<T, R>(
      key: key ?? this.key,
      children: children ?? this.children,
      data: data ?? this.data,
      isLocked: isLocked ?? this.isLocked,
      parentKey: parentKey ?? this.parentKey,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'children': children.map((data) => data.toMap()).toList(),
      'data': data,
      'isLocked': isLocked,
      'parentKey': parentKey,
    };
  }

  @override
  factory SkillNode.fromMap(Map<String, dynamic> map) {
    return SkillNode<T, R>(
      key: map['key'],
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
      parentKey: map['parentKey'],
    );
  }

  @override
  String toJson() => json.encode(toMap());

  @override
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
