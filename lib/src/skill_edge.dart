import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:skill_tree/src/models/edge.dart';
import 'package:skill_tree/src/models/node.dart';
import 'package:skill_tree/src/skill_node.dart';

enum EdgeStyle { bold, dotted }

// TODO: Not set in stone. I think it'd also be worth it to look into
// passing a RenderBox as that has offset and size.
typedef CreateCustomPainter<NodeType extends Object, IdType extends Object>
    = CustomPainter Function(
  SkillNode<NodeType, IdType> from,
  Offset fromOffset,
  Size fromSize,
  SkillNode<NodeType, IdType> to,
  Offset toOffset,
  Size toSize,
);

/// This widget is created AFTER the nodes have been laid out. It is given the
/// [from] and [to] nodes as well as their offsets and sizing.
class SkillEdge<EdgeType extends Object, NodeType extends Object,
        IdType extends Object> extends SingleChildRenderObjectWidget
    implements Edge<EdgeType, Node<NodeType, IdType>> {
  const SkillEdge({
    Widget? child,
    this.data,
    required Key key,
    required this.thickness,
    required this.color,
    required this.from,
    required this.to,
    required this.createPainter,
    required this.createForegroundPainter,
    required this.willChange,
    this.isComplex = false,
  }) : super(key: key, child: child);

  factory SkillEdge.fromEdge({
    required Key key,
    required Edge<EdgeType, Node<NodeType, IdType>> edge,
    required double thickness,
    required Color color,
    required CreateCustomPainter<NodeType, IdType> createPainter,
    required CreateCustomPainter<NodeType, IdType> createForegroundPainter,
    required bool willChange,
    bool isComplex = false,
  }) {
    return SkillEdge(
      key: key,
      thickness: thickness,
      color: color,
      from: edge.from,
      to: edge.to,
      createPainter: createPainter,
      createForegroundPainter: createForegroundPainter,
      willChange: willChange,
    );
  }

  final double thickness;

  final Color color;

  @override
  final EdgeType? data;

  @override
  final Node<NodeType, IdType> from;

  @override
  final Node<NodeType, IdType> to;

  final bool willChange;

  final bool isComplex;

  final CreateCustomPainter<NodeType, IdType> createPainter;

  final CreateCustomPainter<NodeType, IdType> createForegroundPainter;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('color', color));
    properties.add(DoubleProperty('thickness', thickness));
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    // TODO: implement createRenderObject
    throw UnimplementedError();
  }
}
