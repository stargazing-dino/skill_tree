import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// This is the parent class of [SkillEdgeParentData] and [SkillNodeChildData].
/// It's an almost pointless class other than to provide a common base for
/// ParentDataWidget<T> which was not designed to work with mutliple types
/// of data.
class SkillParentData extends ContainerBoxParentData<RenderBox> {
  Widget? skillWidget;
}

class SkillParentWidget extends ParentDataWidget<SkillParentData> {
  const SkillParentWidget({
    Key? key,
    required Widget child,
    required this.skillWidget,
  }) : super(key: key, child: child);

  final Widget skillWidget;

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData! as SkillParentData;

    bool needsLayout = false;
    // bool needsPaint = false;

    if (parentData.skillWidget != skillWidget) {
      parentData.skillWidget = skillWidget;
      needsLayout = true;
    }

    if (needsLayout) {
      final AbstractNode? targetParent = renderObject.parent;
      if (targetParent is RenderObject) targetParent.markNeedsLayout();
    }

    // if (needsPaint) {
    //   final AbstractNode? targetParent = renderObject.parent;
    //   if (targetParent is RenderObject) targetParent.markNeedsPaint();
    // }
  }

  @override
  // TODO: implement debugTypicalAncestorWidgetClass
  Type get debugTypicalAncestorWidgetClass => SkillParentData;
}
