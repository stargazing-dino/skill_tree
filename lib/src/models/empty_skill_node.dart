import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skill_tree/src/models/base_node.dart';

@immutable
class EmptySkillNode<T extends Object> extends BaseNode<T> {
  EmptySkillNode({
    required T key,
    required List<BaseNode<T>> children,
    T? parentKey,
    bool isLocked = false,
  }) : super(
          key: key,
          children: children,
          parentKey: parentKey,
          isLocked: isLocked,
        );

  @override
  EmptySkillNode<T> copyWith({
    T? key,
    List<BaseNode<T>>? children,
    bool? isLocked,
    T? parentKey,
  }) {
    return EmptySkillNode<T>(
      key: key ?? this.key,
      children: children ?? this.children,
      isLocked: isLocked ?? this.isLocked,
      parentKey: parentKey ?? this.parentKey,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'children': children.map((data) => data.toMap()).toList(),
      'isLocked': isLocked,
      'parentKey': parentKey,
    };
  }

  factory EmptySkillNode.fromMap(Map<String, dynamic> map) {
    return EmptySkillNode<T>(
      key: map['key'],
      children: List<BaseNode<T>>.from(
        (map['children'] as List<Map<String, dynamic>>).map(
          (map) {
            if (map['data'] == null) {
              return EmptySkillNode.fromMap(map);
            } else {
              return BaseNode.fromMap(map);
            }
          },
        ),
      ),
      parentKey: map['parentKey'],
    );
  }

  @override
  String toJson() => json.encode(toMap());

  @override
  factory EmptySkillNode.fromJson(String source) =>
      EmptySkillNode.fromMap(json.decode(source));

  @override
  String toString() {
    return 'EmptySkillNode(key: $key, children: $children, isLocked: $isLocked, parentKey: $parentKey)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return o is EmptySkillNode<T> &&
        o.key == key &&
        listEquals(o.children, children) &&
        o.isLocked == isLocked &&
        o.parentKey == parentKey;
  }

  @override
  int get hashCode {
    return key.hashCode ^
        children.hashCode ^
        isLocked.hashCode ^
        parentKey.hashCode;
  }
}
