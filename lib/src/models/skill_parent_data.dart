import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:skill_tree/src/models/node.dart';

class SkillParentData extends ContainerBoxParentData<RenderBox> {}

class SkillEdgeParentData<EdgeType, NodeType, IdType extends Object>
    extends SkillParentData {
  EdgeType? data;

  String? name;

  Node<NodeType, IdType>? from;

  String? id;

  Node<NodeType, IdType>? to;
}

class SkillNodeParentData<NodeType, IdType extends Object>
    extends SkillParentData {
  NodeType? data;

  IdType? id;

  String? name;
}
