import 'package:flutter/material.dart';
import 'package:skill_tree/src/models/base_node.dart';

// TODO: Their should be base class above skill_node and empty_skill node
// that handles serialization and all that. That was skill_node can have it's
// data be non-null in a not weird and hacky way

@immutable
class SkillNode<T extends Object, R extends Object> extends BaseNode<T, R> {
  SkillNode({
    required T key,
    required List<BaseNode<T, R>> children,
    required R data,
    bool isLocked = false,
    T? parentKey,
  }) : super(
          key: key,
          children: children,
          data: data,
          parentKey: parentKey,
          isLocked: isLocked,
        );
}
