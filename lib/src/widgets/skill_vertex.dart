import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:skill_tree/src/widgets/edge_line.dart';

class SkillVertexParentData extends ContainerBoxParentData<RenderBox> {
  void addPositionData(Rect rect) {
    this.rect = rect;
  }

  /// This is the rect of the node. The vertex should position and
  /// itself based off of this.
  ///
  /// This is initialized late
  Rect? rect;

  // TODO:
  // Axis? preferredAxis;
}

class SkillVertexToParentData extends SkillVertexParentData {}

class SkillVertexFromParentData extends SkillVertexParentData {}

// TODO: Allow for builder to be passed in instead of this
abstract class SkillVertex extends ParentDataWidget<SkillVertexParentData> {
  const SkillVertex({
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  Type get debugTypicalAncestorWidgetClass => EdgeLine;

  @override
  void applyParentData(RenderObject renderObject) {}
}

class SkillVertexTo extends SkillVertex {
  const SkillVertexTo({
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  Type get debugTypicalAncestorWidgetClass => EdgeLine;

  @override
  void applyParentData(RenderObject renderObject) {
    // TODO: This looks like it can be abstracted into a util or extension or
    // something
    if (renderObject.parentData is! SkillVertexToParentData) {
      final parentData = renderObject.parentData as SkillVertexParentData;

      renderObject.parentData = SkillVertexToParentData()
        ..nextSibling = parentData.nextSibling
        ..offset = parentData.offset
        ..previousSibling = parentData.previousSibling;
    }
  }

  @override
  bool debugIsValidRenderObject(RenderObject renderObject) {
    return renderObject.parentData is SkillVertexParentData;
  }
}

class SkillVertexFrom extends SkillVertex {
  const SkillVertexFrom({
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  Type get debugTypicalAncestorWidgetClass => EdgeLine;

  @override
  void applyParentData(RenderObject renderObject) {
    if (renderObject.parentData is! SkillVertexFromParentData) {
      final parentData = renderObject.parentData as SkillVertexParentData;

      renderObject.parentData = SkillVertexFromParentData()
        ..nextSibling = parentData.nextSibling
        ..offset = parentData.offset
        ..previousSibling = parentData.previousSibling;
    }
  }

  @override
  bool debugIsValidRenderObject(RenderObject renderObject) {
    return renderObject.parentData is SkillVertexParentData;
  }
}
