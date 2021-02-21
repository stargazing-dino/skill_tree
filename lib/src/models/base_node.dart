import 'package:flutter/material.dart';

@immutable
abstract class BaseNode<T extends Object> {
  final T key;

  final List<BaseNode<T>> children;

  final bool isLocked;

  final T? parentKey;

  final GlobalObjectKey globalKey;

  BaseNode({
    required this.key,
    required this.children,
    required this.isLocked,
    this.parentKey,
  }) : globalKey = GlobalObjectKey(key);

  BaseNode<T> copyWith({
    T? key,
    List<BaseNode<T>>? children,
    bool? isLocked,
    T? parentKey,
  });

  Map<String, dynamic> toMap();

  factory BaseNode.fromMap(Map<String, dynamic> json) {
    throw UnimplementedError();
  }

  String toJson();

  factory BaseNode.fromJson(String source) {
    throw UnimplementedError();
  }
}
