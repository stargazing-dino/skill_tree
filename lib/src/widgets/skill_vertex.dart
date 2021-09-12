import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:skill_tree/src/widgets/draggable_edge.dart';

// TODO: Allow for builder to be passed in instead of this
class SkillVertex extends ParentDataWidget<VertexParentData> {
  const SkillVertex.to({
    Key? key,
    required Widget child,
  })  : isTo = true,
        super(key: key, child: child);

  const SkillVertex.from({
    Key? key,
    required Widget child,
  })  : isTo = false,
        super(key: key, child: child);

  final bool isTo;

  @override
  Type get debugTypicalAncestorWidgetClass => DraggableEdge;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is VertexParentData);
    final parentData = renderObject.parentData as VertexParentData;

    if (parentData.isTo != isTo) {
      parentData.isTo = isTo;
      final targetParent = renderObject.parent;
      if (targetParent is RenderObject) targetParent.markNeedsLayout();
    }
  }
}
