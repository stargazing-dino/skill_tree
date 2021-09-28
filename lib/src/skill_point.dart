import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:skill_tree/src/skill_edge.dart';

// TODO: Justify the use of ParentData like this. In fact, rethink all of this.

class SkillPointParentData extends ContainerBoxParentData<RenderBox> {
  /// This is the rect of the child in relative to the parent's Offset.
  Rect? rect;
}

class SkillPointToParentData extends SkillPointParentData {}

class SkillPointFromParentData extends SkillPointParentData {}

abstract class SkillPoint<ParentType extends SkillPointParentData>
    extends ParentDataWidget<SkillPointParentData> {
  const SkillPoint({
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

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
  const SkillPointTo({
    Key? key,
    required Widget child,
  }) : super(
          key: key,
          child: child,
        );

  @override
  SkillPointToParentData createParentData() {
    return SkillPointToParentData();
  }
}

class SkillPointFrom extends SkillPoint<SkillPointFromParentData> {
  const SkillPointFrom({
    Key? key,
    required Widget child,
  }) : super(
          key: key,
          child: child,
        );

  @override
  SkillPointFromParentData createParentData() {
    return SkillPointFromParentData();
  }
}
