import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:skill_tree/src/models/empty_skill_node.dart';

class BaseNode<T extends Object, R> {
  final T key;

  final List<BaseNode<T, R>> children;

  final R data;

  final bool isLocked;

  final T? parentKey;

  final GlobalObjectKey globalKey;

  BaseNode({
    required this.key,
    required this.children,
    required this.data,
    required this.isLocked,
    this.parentKey,
  }) : globalKey = GlobalObjectKey(key.toString());

  BaseNode<T, R> copyWith({
    T? key,
    List<BaseNode<T, R>>? children,
    R? data,
    bool? isLocked,
    T? parentKey,
  }) {
    return BaseNode<T, R>(
      key: key ?? this.key,
      children: children ?? this.children,
      data: data ?? this.data,
      isLocked: isLocked ?? this.isLocked,
      parentKey: parentKey ?? this.parentKey,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'children': children.map((data) => data.toMap()).toList(),
      'data': data,
      'isLocked': isLocked,
      'parentKey': parentKey,
    };
  }

  factory BaseNode.fromMap(Map<String, dynamic> map) {
    return BaseNode<T, R>(
      key: map['key'],
      children: List<BaseNode<T, R>>.from(
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
      data: map['data'],
      isLocked: map['isLocked'] ?? false,
      parentKey: map['parentKey'],
    );
  }

  String toJson() => json.encode(toMap());

  factory BaseNode.fromJson(String source) =>
      BaseNode.fromMap(json.decode(source));

  @override
  String toString() {
    return 'BaseNode(key: $key, children: $children, data: $data, isLocked: $isLocked, parentKey: $parentKey)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return o is BaseNode<T, R> &&
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
