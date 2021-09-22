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

  /// This defines where the child should be placed relative to the [rect].
  Alignment? alignment;
}

class SkillVertexToParentData extends SkillVertexParentData {}

class SkillVertexFromParentData extends SkillVertexParentData {}

abstract class SkillVertex<ParentType extends SkillVertexParentData>
    extends ParentDataWidget<SkillVertexParentData> {
  const SkillVertex({
    Key? key,
    required Widget child,
    required this.alignment,
  }) : super(key: key, child: child);

  final Alignment? alignment;

  ParentType createParentData();

  @override
  void applyParentData(RenderObject renderObject) {
    // TODO: This looks like it can be abstracted into a util or extension or
    // something
    if (renderObject.parentData is! ParentType) {
      final parentData = renderObject.parentData as SkillVertexParentData;

      renderObject.parentData = createParentData()
        ..nextSibling = parentData.nextSibling
        ..offset = parentData.offset
        ..previousSibling = parentData.previousSibling;
    }

    final parentData = renderObject.parentData as SkillVertexParentData;

    bool needsLayout = false;
    // bool needsPaint = false;

    if (parentData.alignment != alignment) {
      parentData.alignment = alignment;
      needsLayout = true;
    }

    final targetParent = renderObject.parent;

    if (needsLayout) {
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    }

    // if (needsPaint) {
    //   if (targetParent is RenderObject) {
    //     targetParent.markNeedsPaint();
    //   }
    // }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => EdgeLine;

  @override
  bool debugIsValidRenderObject(RenderObject renderObject) {
    return renderObject.parentData is SkillVertexParentData;
  }
}

class SkillVertexTo extends SkillVertex<SkillVertexToParentData> {
  const SkillVertexTo({
    Key? key,
    required Widget child,
    Alignment? alignment,
  }) : super(
          key: key,
          child: child,
          alignment: alignment,
        );

  @override
  SkillVertexToParentData createParentData() {
    return SkillVertexToParentData();
  }
}

class SkillVertexFrom extends SkillVertex<SkillVertexFromParentData> {
  const SkillVertexFrom({
    Key? key,
    required Widget child,
    Alignment? alignment,
  }) : super(
          key: key,
          child: child,
          alignment: alignment,
        );

  @override
  SkillVertexFromParentData createParentData() {
    return SkillVertexFromParentData();
  }
}
