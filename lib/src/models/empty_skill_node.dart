import 'package:flutter/foundation.dart';
import 'package:skill_tree/src/models/base_node.dart';

@immutable
class EmptySkillNode<T extends Object> extends BaseNode<T, Null> {
  EmptySkillNode({
    required T key,
    T? parentKey,
    bool isLocked = false,
  }) : super(
          key: key,
          children: const [],
          data: null,
          parentKey: parentKey,
          isLocked: isLocked,
        );

  factory EmptySkillNode.fromMap(Map<String, dynamic> map) {
    return EmptySkillNode<T>(
      key: map['key'],
      parentKey: map['parentKey'],
    );
  }
}
