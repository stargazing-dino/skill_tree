import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SkillParentData extends ContainerBoxParentData<RenderBox> {}

class SkillEdgeParentData<EdgeType, NodeType, IdType extends Object>
    extends SkillParentData {
  EdgeType? data;

  String? name;

  IdType? from;

  String? id;

  IdType? to;
}

class SkillNodeParentData<NodeType, IdType extends Object>
    extends SkillParentData {
  NodeType? data;

  IdType? id;

  String? name;
}
