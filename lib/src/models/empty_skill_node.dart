import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skill_tree/src/models/skill_node.dart';

class EmptySkillNode<T> extends SkillNode<T, Null> {
  EmptySkillNode({
    required ValueKey<T> key,
    ValueKey<T>? parentKey,
  }) : super(
          key: key,
          children: [],
          data: null,
          parentKey: parentKey,
        );

  factory EmptySkillNode.fromMap(Map<String, dynamic> map) {
    return EmptySkillNode<T>(
      key: map['key'],
      parentKey: map['parentKey'],
    );
  }
}
