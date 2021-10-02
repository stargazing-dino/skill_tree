import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:skill_tree/src/skill_edge.dart';

// TODO: Justify the use of ParentData like this. In fact, rethink all of this.

class SkillPointParentData extends ContainerBoxParentData<RenderBox> {
  /// This is the rect of the child in relative to the parent's Offset.
  Rect? rect;

  /// An angle used to transform the child.
  double? angle;
}

class SkillPointToParentData extends SkillPointParentData {}

class SkillPointFromParentData extends SkillPointParentData {}

abstract class SkillPoint<ParentType extends SkillPointParentData>
    extends ParentDataWidget<SkillPointParentData> {
  SkillPoint({
    Key? key,
    required Widget child,
  }) : super(key: key, child: _SkillPointRotation(child: child));

  ParentType createParentData();

  @override
  void applyParentData(RenderObject renderObject) {
    // TODO: This looks like it can be abstracted into a util or extension or
    // something
    if (renderObject.parentData is! ParentType) {
      final parentData = renderObject.parentData as SkillPointParentData;

      renderObject.parentData = createParentData()
        ..nextSibling = parentData.nextSibling
        ..offset = parentData.offset
        ..previousSibling = parentData.previousSibling;
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => MultiChildEdge;

  @override
  bool debugIsValidRenderObject(RenderObject renderObject) {
    return renderObject.parentData is SkillPointParentData;
  }
}

class SkillPointTo extends SkillPoint<SkillPointToParentData> {
  SkillPointTo({Key? key, required Widget child})
      : super(key: key, child: child);

  @override
  SkillPointToParentData createParentData() {
    return SkillPointToParentData();
  }
}

class SkillPointFrom extends SkillPoint<SkillPointFromParentData> {
  SkillPointFrom({Key? key, required Widget child})
      : super(key: key, child: child);

  @override
  SkillPointFromParentData createParentData() {
    return SkillPointFromParentData();
  }
}

class _SkillPointRotation extends SingleChildRenderObjectWidget {
  const _SkillPointRotation({Key? key, required Widget child})
      : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSkillPointRotation();
  }
}

class _RenderSkillPointRotation extends RenderTransform {
  _RenderSkillPointRotation()
      : super(
          transform: Matrix4.identity(),
          alignment: Alignment.center,
        );

  @override
  void performLayout() {
    final skillPointParentData = parentData as SkillPointParentData;
    final angle = skillPointParentData.angle! - (pi / 2);

    transform = Matrix4.rotationZ(angle);

    super.performLayout();
  }
}
