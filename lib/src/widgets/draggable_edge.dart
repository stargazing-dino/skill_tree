import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:skill_tree/src/skill_node.dart';
import 'package:skill_tree/src/widgets/draggable_point.dart';

class DraggableEdge<NodeType extends Object, IdType extends Object>
    extends MultiChildRenderObjectWidget {
  DraggableEdge({
    Key? key,
    required DraggablePoint toPoint,
    required DraggablePoint fromPoint,
  }) : super(key: key, children: [toPoint, fromPoint]);

  @override
  RenderBox createRenderObject(BuildContext context) {
    return RenderDraggableEdge<NodeType, IdType>();
  }
}

/// The fields of this [RenderObject] are initialized in the layout phase.
/// This is because we must first know the size of the node widgets.
class RenderDraggableEdge<NodeType extends Object, IdType extends Object>
    extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox,
            ContainerBoxParentData<RenderBox>>,
        RenderBoxContainerDefaultsMixin<RenderBox,
            ContainerBoxParentData<RenderBox>> {
  late SkillNode<NodeType, IdType> _to;
  SkillNode<NodeType, IdType> get to => _to;
  set to(SkillNode<NodeType, IdType> to) {
    if (_to == to) return;
    _to = to;
    markNeedsLayout();
  }

  late Rect _toRect;
  Rect get toRect => _toRect;
  set toRect(Rect toRect) {
    if (_toRect == toRect) return;
    _toRect = toRect;
    markNeedsLayout();
  }

  late SkillNode<NodeType, IdType> _from;
  SkillNode<NodeType, IdType> get from => _from;
  set from(SkillNode<NodeType, IdType> from) {
    if (_from == from) return;
    _from = from;
    markNeedsLayout();
  }

  late Rect _fromRect;
  Rect get fromRect => _fromRect;
  set fromRect(Rect fromRect) {
    if (_fromRect == fromRect) return;
    _fromRect = fromRect;
    markNeedsLayout();
  }

  @override
  void debugAssertDoesMeetConstraints() {
    // TODO: implement debugAssertDoesMeetConstraints
  }

  @override
  // TODO: implement paintBounds
  Rect get paintBounds => throw UnimplementedError();

  @override
  void performLayout() {
    // TODO: implement performLayout
  }

  @override
  void performResize() {
    // TODO: implement performResize
  }

  @override
  // TODO: implement semanticBounds
  Rect get semanticBounds => throw UnimplementedError();

  @override
  void paint(PaintingContext context, Offset offset) {
    // TODO: Draw connection
    defaultPaint(context, offset);
  }
}
