import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:skill_tree/src/models/edge.dart';
import 'package:skill_tree/src/models/node.dart';
import 'package:skill_tree/src/models/skill_parent_data.dart';
import 'package:skill_tree/src/widgets/draggable_edge.dart';
import 'package:skill_tree/src/widgets/draggable_point.dart';

class SkillEdge<EdgeType extends Object, NodeType extends Object,
        IdType extends Object> extends StatelessWidget
    implements Edge<EdgeType, Node<NodeType, IdType>> {
  const SkillEdge({
    Key? key,
    required this.data,
    required this.from,
    required this.id,
    required this.to,
  }) : super(key: key);

  @override
  final EdgeType? data;

  @override
  final Node<NodeType, IdType> from;

  @override
  final String id;

  @override
  final Node<NodeType, IdType> to;

  @override
  Widget build(BuildContext context) {
    return SkillParentWidget(
      skillWidget: this,
      child: DraggableEdge<NodeType, IdType>(
        toPoint: DraggablePoint.to(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.green.withOpacity(.5),
            ),
            height: 12,
            width: 12,
          ),
        ),
        fromPoint: DraggablePoint.from(
          child: Container(
            color: Colors.red.withOpacity(.5),
            height: 12,
            width: 12,
          ),
        ),
      ),
    );
  }
}
