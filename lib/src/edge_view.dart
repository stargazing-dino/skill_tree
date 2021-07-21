import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:skill_tree/src/models/skill_edge.dart';
import 'package:skill_tree/src/node_view.dart';

enum EdgeStyle { bold, dotted }

class EdgeView<EdgeType, NodeType> extends MultiChildRenderObjectWidget
    implements BaseSkillEdge<EdgeType, NodeView<NodeType>> {
  final double thickness;

  final Color color;

  @override
  final EdgeType? data;

  @override
  final NodeView<NodeType> from;

  @override
  final NodeView<NodeType> to;

  EdgeView({
    required Key key,
    required this.thickness,
    required this.color,
    required this.from,
    required this.to,
    this.data,
  }) : super(key: key, children: [from, to]);

  @override
  RenderEdgeView createRenderObject(BuildContext context) {
    return RenderEdgeView<EdgeType, NodeType>(
      color: color,
      thickness: thickness,
      to: to,
      from: from,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderEdgeView renderObject) {
    renderObject
      ..color = color
      ..thickness = thickness
      ..to = to
      ..from = from;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('color', color));
    properties.add(DoubleProperty('thickness', thickness));
  }
}

class EdgeViewParentData extends ContainerBoxParentData<RenderBox> {}

// FIXME: Do I use EdgeType?
class RenderEdgeView<EdgeType, NodeType> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, EdgeViewParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, EdgeViewParentData> {
  RenderEdgeView({
    required Color color,
    required double thickness,
    required NodeView<NodeType> from,
    required NodeView<NodeType> to,
  })  : _color = color,
        _thickness = thickness,
        _from = from,
        _to = to,
        _paint = Paint()
          ..color = color
          ..strokeWidth = thickness;

  final Paint _paint;

  Color get color => _color;
  Color _color;
  set color(Color value) {
    if (_color == value) return;
    _color = value;
    markNeedsPaint();
  }

  double get thickness => _thickness;
  double _thickness;
  set thickness(double value) {
    if (_thickness == value) return;
    _thickness = value;
    markNeedsPaint();
  }

  NodeView<NodeType> get from => _from;
  NodeView<NodeType> _from;
  set from(NodeView<NodeType> value) {
    if (_from == value) return;
    _from = value;
    markNeedsLayout();
  }

  NodeView<NodeType> get to => _to;
  NodeView<NodeType> _to;
  set to(NodeView<NodeType> value) {
    if (_to == value) return;
    _to = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! EdgeViewParentData) {
      child.parentData = EdgeViewParentData()
        ..offset = Offset(
            Random().nextDouble() * 100.0, Random().nextDouble() * 100.0);
    }
  }

  @override
  void performLayout() {
    final children = getChildrenAsList();

    var highestChild = children.first.parentData as EdgeViewParentData;
    double? highestChildHeight;

    for (final child in children) {
      child.layout(
        BoxConstraints(maxWidth: constraints.maxWidth),
        parentUsesSize: true,
      );

      final childParentData = child.parentData as EdgeViewParentData;

      highestChildHeight ??= child.size.height;

      if (childParentData.offset.dy > highestChild.offset.dy) {
        highestChild = childParentData;
        highestChildHeight = child.size.height;
      }
    }

    final sizeHeight = highestChild.offset.dy + highestChildHeight!;

    size = Size(constraints.maxWidth, sizeHeight);
  }

  // @override
  // Size computeDryLayout(BoxConstraints constraints) {
  //   final desiredWidth = constraints.maxWidth;
  //   final children = getChildrenAsList();
  //   final height = children.fold<double>(
  //       0.0, (previousValue, child) => previousValue + child.size.height);
  //   final desiredSize = Size(desiredWidth, height);

  //   return constraints.constrain(desiredSize);
  // }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);

    // final children = getChildrenAsList();

    // for (final child in children) {
    //   child.
    // }
  }
}
