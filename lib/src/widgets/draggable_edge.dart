import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:skill_tree/src/widgets/draggable_point.dart';
import 'package:skill_tree/src/widgets/skill_node.dart';

class PointParentData extends ContainerBoxParentData<RenderBox> {}

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
        ContainerRenderObjectMixin<RenderBox, PointParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, PointParentData>,
        DebugOverflowIndicatorMixin {
  /// This needs to be laid out after we have all the information available
  /// so we'll delay until then and call [initialize] at that time.
  void initialize({
    required SkillNode<NodeType, IdType> to,
    required Rect toRect,
    required SkillNode<NodeType, IdType> from,
    required Rect fromRect,
  }) {
    _to = to;
    _toRect = toRect;
    _from = from;
    _fromRect = fromRect;
  }

  SkillNode<NodeType, IdType>? _to;
  SkillNode<NodeType, IdType>? get to => _to;
  set to(SkillNode<NodeType, IdType>? to) {
    if (_to == to) return;
    _to = to;
    markNeedsLayout();
  }

  Rect? _toRect;
  Rect? get toRect => _toRect;
  set toRect(Rect? toRect) {
    if (_toRect == toRect) return;
    _toRect = toRect;
    markNeedsLayout();
  }

  SkillNode<NodeType, IdType>? _from;
  SkillNode<NodeType, IdType>? get from => _from;
  set from(SkillNode<NodeType, IdType>? from) {
    if (_from == from) return;
    _from = from;
    markNeedsLayout();
  }

  Rect? _fromRect;
  Rect? get fromRect => _fromRect;
  set fromRect(Rect? fromRect) {
    if (_fromRect == fromRect) return;
    _fromRect = fromRect;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! PointParentData) {
      child.parentData = PointParentData();
    }
  }

  @override
  void performLayout() {
    final children = getChildrenAsList();

    for (final child in children) {
      child.layout(constraints, parentUsesSize: false);
    }

    size = Size(
      constraints.maxWidth,
      constraints.maxHeight,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // TODO: Draw connection
    defaultPaint(context, offset);
  }
}
