import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:skill_tree/src/models/edge.dart';
import 'package:skill_tree/src/models/node.dart';
import 'package:skill_tree/src/skill_node.dart';

enum EdgeStyle { bold, dotted }

typedef CreateCustomPainter<NodeType extends Object> = CustomPainter Function({
  required SkillNode<NodeType> from,
  required Offset fromOffset,
  required Size fromSize,
  required SkillNode<NodeType> to,
  required Offset toOffset,
  required Size toSize,
});

/// This widget is created AFTER the nodes have been laid out. It is given the
/// [from] and [to] nodes as well as their offsets and sizing.
class SkillEdge<EdgeType extends Object, NodeType extends Object>
    extends SingleChildRenderObjectWidget
    implements Edge<EdgeType, Node<NodeType>> {
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
    required Edge<EdgeType, Node<NodeType>> edge,
    required double thickness,
    required Color color,
    required CreateCustomPainter<NodeType> createPainter,
    required CreateCustomPainter<NodeType> createForegroundPainter,
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
  final Node<NodeType> from;

  @override
  final Node<NodeType> to;

  final bool willChange;

  final bool isComplex;

  final CreateCustomPainter<NodeType> createPainter;

  final CreateCustomPainter<NodeType> createForegroundPainter;

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
